#!/usr/bin/env bash
set -eo pipefail
# This file will need to be run in bash, for now.

# @(#)

echo "Hydra Cross-Compiler/Toolchain Build Script"

echo "Building to target: ${TARGET}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Current Directory: $DIR"
echo "Build Directory: $BUILD"
echo "Sysroot Directory: $SYSROOT"

ARCH=${ARCH:-"x86_64"}
TARGET="$ARCH-hydra"
PREFIX="$DIR/Local/$ARCH"
BUILD="$DIR/Build/$ARCH"
SYSROOT="$BUILD/Root"

MAKE="make"
MD5SUM="md5sum"
REALPATH="realpath"

PATCHPATH="$DIR/Patch"

if command -v ginstall &>/dev/null; then
    INSTALL=ginstall
else
    INSTALL=install
fi

SYSTEM_NAME="$(uname -s)"

if [ "$SYSTEM_NAME" != "Darwin" ]; then
	NPROC="nproc"
else
	NPROC="sysctl -n hw.logicalcpu"
	brew install coreutils && echo "Downloading GNU Coreutils..."
fi

export CFLAGS="-g0 -O2 -mtune=native"
export CXXFLAGS="-g0 -O2 -mtune=native"

BINUTILS_VERSION="2.39"
BINUTILS_MD5SUM="f430dff91bdc8772fcef06ffdc0656ab"
BINUTILS_NAME="binutils-$BINUTILS_VERSION"
BINUTILS_PKG="${BINUTILS_NAME}.tar.gz"
BINUTILS_BASE_URL="https://ftp.gnu.org/gnu/binutils"

GDB_VERSION="11.2"
GDB_MD5SUM="b5674bef1fbd6beead889f80afa6f269"
GDB_NAME="gdb-$GDB_VERSION"
GDB_PKG="${GDB_NAME}.tar.gz"
GDB_BASE_URL="https://gnu.mirror.constant.com/gdb"

GCC_VERSION="12.2.0"
GCC_MD5SUM="7854cdccc3a7988aa37fb0d0038b8096"
GCC_NAME="gcc-$GCC_VERSION"
GCC_PKG="${GCC_NAME}.tar.gz"
GCC_BASE_URL="https://gnu.mirror.constant.com/gcc"

buildstep() {
    NAME=$1
    shift
    "$@" 2>&1 | sed $'s|^|\x1b[34m['"${NAME}"$']\x1b[39m |'
}

mkdir -p $BUILD

pushd "$BUILD/"
echo "XXX echo libc and libm headers"
    mkdir -p $BUILD/Root/usr/include/
    SRC_ROOT=$($REALPATH "$DIR"/..)
    FILES=$(find "$SRC_ROOT"/lib/libc/include "$SRC_ROOT"/lib/libm -name '*.h' -print)
    for header in $FILES; do
        target=$(echo "$header" | sed -e "s@$SRC_ROOT/lib/libc/include@@" -e "s@$SRC_ROOT/Libraries/LibM@@")
        buildstep "system_headers" $INSTALL -D "$header" "Root/usr/include/$target"
    done
    OBJ_FILES=$(find "$SRC_ROOT"/lib/libc/build -name '*.o' -print)
    for object in $OBJ_FILES; do
	    obj_target=$(echo "$object" | sed -e "s@$SRC_ROOT/lib/libc/build@@")
	    buildstep "system_libraries" $INSTALL -D "$object" "Root/usr/lib/$obj_target"
    done
    LIB_FILES=$(find "$SRC_ROOT"/lib/libc/build -name '*.a' -print)
    for library in $LIB_FILES; do
	    lib_target=$(echo "$library" | sed -e "s@$SRC_ROOT/lib/libc/build@@")
	    buildstep "system_libraries" $INSTALL -D "$library" "Root/usr/lib/$lib_target"
    done
    unset SRC_ROOT
popd

# === DEPENDENCIES ===
buildstep dependencies echo "Checking whether 'make' is available..."
if ! command -v ${MAKE:-make} >/dev/null; then
    buildstep dependencies echo "Please make sure to install GNU Make (for the '${MAKE:-make}' tool)."
    exit 1
fi

buildstep dependencies echo "Checking whether your C compiler works..."
if ! ${CC:-cc} -o /dev/null -xc - >/dev/null <<'PROGRAM'
int main() {}
PROGRAM
then
    buildstep dependencies echo "Please make sure to install a working C compiler."
    exit 1
fi

if [ "$SYSTEM_NAME" != "Darwin" ]; then
    for lib in gmp mpc mpfr; do
        buildstep dependencies echo "Checking whether the $lib library and headers are available..."
        if ! ${CC:-cc} -I /usr/local/include -L /usr/local/lib -l$lib -o /dev/null -xc - >/dev/null <<PROGRAM
#include <$lib.h>
int main() {}
PROGRAM
        then
            echo "Please make sure to install the $lib library and headers."
            exit 1
        fi
    done
fi

# === COMPILE AND INSTALL ===

rm -rf "$PREFIX"
mkdir -p "$PREFIX"

if [ -z "$MAKEJOBS" ]; then
    MAKEJOBS=$($NPROC)
fi

pushd "$BUILD"
    unset PKG_CONFIG_LIBDIR # Just in case

    if [ "$ARCH" = "aarch64" ]; then
        rm -rf gdb
        mkdir -p gdb

        pushd gdb
            echo "XXX configure gdb"
            buildstep "gdb/configure" "$DIR"/Tarballs/$GDB_NAME/configure --prefix="$PREFIX" \
                                                     --target="$TARGET" \
                                                     --with-sysroot="$SYSROOT" \
                                                     --enable-shared \
                                                     --disable-nls \
                                                     ${TRY_USE_LOCAL_TOOLCHAIN:+"--quiet"} || exit 1
            echo "XXX build gdb"
            buildstep "gdb/build" "$MAKE" -j "$MAKEJOBS" || exit 1
            buildstep "gdb/install" "$MAKE" install || exit 1
        popd
    fi

    rm -rf binutils-build
    mkdir -p binutils-build

    pushd binutils-build
        echo "XXX configure binutils"
        buildstep "binutils/configure" "$DIR"/gnu/binutils/configure --prefix="$PREFIX" \
                                                 --target="$TARGET" \
                                                 --with-sysroot="$SYSROOT" \
                                                 --disable-nls \
												 --disable-werror
                                                 ${TRY_USE_LOCAL_TOOLCHAIN:+"--quiet"} || exit 1
        if [ "$SYSTEM_NAME" = "Darwin" ]; then
            # under macOS generated makefiles are not resolving the "intl"
            # dependency properly to allow linking its own copy of
            # libintl when building with --enable-shared.
            buildstep "binutils/build" "$MAKE" -j "$MAKEJOBS" || true
            pushd intl
            buildstep "binutils/build" "$MAKE" all-yes
            popd
        fi
        echo "XXX build binutils"
        buildstep "binutils/build" "$MAKE" -j "$MAKEJOBS" || exit 1
        buildstep "binutils/install" "$MAKE" install || exit 1
    popd

    if [ "$SYSTEM_NAME" = "OpenBSD" ]; then
        perl -pi -e 's/-no-pie/-nopie/g' "$DIR/Tarballs/gcc-$GCC_VERSION/gcc/configure"
    fi

    if [ ! -f "$DIR/gnu/gcc/gcc/config/hydra-userland.h" ]; then
        cp "$DIR/gnu/gcc/gcc/config/hydra.h" "$DIR/gnu/gcc/gcc/config/hydra-kernel.h"
    fi

    rm -rf gcc-build
    mkdir -p gcc-build

    pushd gcc-build
        echo "XXX configure gcc and libgcc"
        buildstep "gcc/configure" "$DIR/gnu/gcc/configure" --prefix="$PREFIX" \
                                            --target="$TARGET" \
                                            --with-sysroot="$SYSROOT" \
                                            --disable-nls \
                                            --enable-languages=c,c++ \
                                            ${TRY_USE_LOCAL_TOOLCHAIN:+"--quiet"} || exit 1

        echo "XXX build gcc and libgcc"
        buildstep "gcc/build" "$MAKE" -j "$MAKEJOBS" all-gcc || exit 1
        if [ "$SYSTEM_NAME" = "OpenBSD" ]; then
            ln -sf liblto_plugin.so.0.0 gcc/liblto_plugin.so
        fi
        buildstep "libgcc/build" "$MAKE" -j "$MAKEJOBS" all-target-libgcc || exit 1
        echo "XXX install gcc and libgcc"
        buildstep "gcc+libgcc/install" "$MAKE" install-gcc install-target-libgcc || exit 1

        #echo "XXX build libstdc++"
        #buildstep "libstdc++/build" "$MAKE" -j "$MAKEJOBS" all-target-libstdc++-v3 || exit 1
        #echo "XXX install libstdc++"
        #buildstep "libstdc++/install" "$MAKE" install-target-libstdc++-v3 || exit 1
    popd

    if [ "$SYSTEM_NAME" = "OpenBSD" ]; then
        cd "$DIR/Local/${ARCH}/libexec/gcc/$TARGET/$GCC_VERSION" && ln -sf liblto_plugin.so.0.0 liblto_plugin.so
    fi
popd


# == SAVE TO CACHE ==

pushd "$DIR"
    if [ "${TRY_USE_LOCAL_TOOLCHAIN}" = "y" ] ; then
        echo "::endgroup::"
        echo "Building cache tar:"

        rm -f "${CACHED_TOOLCHAIN_ARCHIVE}"  # Just in case

        tar czf "${CACHED_TOOLCHAIN_ARCHIVE}" Local/

        echo "Cache (after):"
        ls -l Cache
    fi
popd

# == INSTALL ==

pushd "$DIR"
	echo "Installing to ~/bin"
	cp -r Local/x86_64/* ~/.
	echo "Adding ~/bin to PATH"
	echo "export PATH=~/bin:\$PATH" >> ~/.bashrc
	echo "export PATH=~/bin:\$PATH" >> ~/.zshrc
	echo "export PATH=~/bin:\$PATH" >> ~/.profile
popd
