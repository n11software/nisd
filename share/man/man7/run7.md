RUN 7 "JUNE 2024" NISD "Miscellaneous"
======================================

NAME
----

run

SYNOPSIS
--------

`run` [`-hv`]

DESCRIPTION
-----------

`meta/run` is a script for managing and running a QEMU virtual machine
configuration for NISD. The script provides a boot menu with two options
for a normal boot or a boot with debugging enabled, as well as a QEMU
configuration settings page.

MAIN MENU
---------

The main menu provides the following options:

1. **Boot** - Boot the QEMU VM.
2. **Configure QEMU emulation** - Enter the configuration menu to set various QEMU options.
3. **Boot and Debug** - Boot the QEMU VM with debugging options enabled.
4. **Quit** - Exit the script.

CONFIGURATION MENU
------------------

The configuration menu allows setting the following options:

- **Machine** - Set the machine type (e.g., `q35`).
- **CPU** - Select the CPU type (e.g., `EPYC`, `Skylake-Client`).
- **RAM** - Set the RAM size (e.g., `128M` to `8G`).
- **HDD** - Specify the HDD file path.
- **CD-ROM** - Specify the CD-ROM file path.
- **Graphics Card** - Select the graphics card type (e.g., `cirrus`, `std`).
- **PCI Passthrough** - Enable or disable PCI passthrough.
- **Serial** - Set the serial output (e.g., `mon:stdio`, `file:dmesg`).
- **Display** - Choose the display type (e.g., `none`, `gtk`, `sdl`).

See qemu-system-x86_64(1) for more information.

OPTIONS
-------

`-h`
  Help page for the script.

`-v`
  Version number of NISD.

FILES
-----

# FILES

- `.qemu-config` - Configuration file for QEMU options.
- `meta/.run-qemu.sh` - Direct script with QEMU command.
- `build/nisd.iso` - ISO file to boot the VM.
- `share/res/ovmf/OVMF_CODE.fd` - OVMF code file.
- `share/res/ovmf/OVMF_VARS.fd` - OVMF variables file.

BUGS
----

No known bugs are known at this time. Please report all bugs to <me@ariston.dev>

AUTHOR
------

Ariston Lorenzo <me@ariston.dev>

SEE ALSO
--------

build(7), qemu-system-x86_64(1)
