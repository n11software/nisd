BUILD 7 "JUNE 2024" NISD "Miscellaneous"
========================================

NAME
----

build - NISD build script

SYNOPSIS
--------

`build` [`-hv`] *target*

DESCRIPTION
-----------

The `meta/build` script provides targets to build the NISD system as well
as its various parts (e.g. the Inferno kernel or the Better Opensource
Bootloader). The `meta/build` script can only be ran from the `nisd`
source directory.

OPTIONS
-------

`-h`
  Help page for the script.

`-v`
  Version number of NISD.

TARGETS
-------

*import*
  Import all sources via git into the NISD source directory.

*buildbootloader*
  Builds the Better Opensource Bootloader source.

*cleanbootloader*
  Cleans the previous Better Opensource Bootloader `build/` directory.

*buildkernel*
  Builds the Inferno kernel source.

*cleankernel*
  Cleans the Inferno kernel `build/` directory.

*buildiso*
  Generates an ISO file in `build/`.

BUGS
----

No known bugs are known at this time. Please report all bugs to <me@ariston.dev>

AUTHOR
------

Ariston Lorenzo <me@ariston.dev>

SEE ALSO
--------

run(7)
