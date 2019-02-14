# epics-modules

## Introduction 

This is a repository to build areaDetector and its dependencies out of the relevant 
git repositories. These are included as submodules (along with areaDetector). 

The top level makefile can be used to build the whole stack. 

## Release Files

In order to keep the release files consistent between the repositories, the makefile
target `release` is used to propagate the paths into the relevant repositories. 

__TODO__ : Convert the perl file to a python script to do this more efficiently and 
not use sed. 

## Getting started

To build, first edit the file `configure/RELEASE`. An example is below:

```
SUPPORT=/home/swilkins/Repos/epics
ASYN=$(SUPPORT)/asyn
EPICS_BASE=$(SUPPORT)/epics-base
AUTOSAVE=$(SUPPORT)/autosave
BUSY=$(SUPPORT)/busy
CALC=$(SUPPORT)/calc
SSCAN=$(SUPPORT)/sscan
DEVIOCSTATS=$(SUPPORT)/iocStats
SNCSEQ=$(SUPPORT)/seq
AREA_DETECTOR=$(SUPPORT)/areaDetector
```

The only line which needs changing is the `SUPPORT` definition, this should be changed to 
the top level directory of the whole repository. 

Once this is completed, execute the command:
```
make update
```
to update all the submodules. After that execute:
```
make release
```
to make the releases consistent. For areaDetector, the file `areaDetector/configure/CONFIG_SITE`
should be edited to make changes for local libraries. To specify which detectors are built, the 
file `areaDetector/configure/RELEASE.local` should be modified, uncommenting any lines for
detectors to be build.

Finally, engage the build with
```
make -j XX
```
where `XX` is the number of cores on the system. Note: this can also be acomplished by setting the 
environmental variable `MAKEFLAGS`:
```
export MAKEFLAGS="--jobs `nproc`"
```

Enjoy your areaDetector build!

