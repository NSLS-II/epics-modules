# Modular build of EPICS and areaDetector

## Introduction 

This is a repository to build areaDetector and its dependencies out of the relevant 
git repositories. These are included as submodules (along with areaDetector). 

The top level `Makefile` can be used to build the whole stack.

## Status

|   | Build & Test |
|---|:-----:|
| ![Linux-x64](docs/linux_med.png) **Linux x64**| [![Linux Build Status](https://dev.azure.com/nsls-ii/epics-modules/_apis/build/status/NSLS-II.epics-modules?branchName=master&jobName=Linux)](https://dev.azure.com/nsls-ii/epics-modules/_build/latest?definitionId=2&branchName=master) |
| ![Win-x64](docs/win_med.png) **Windows x64**| [![Windows Build Status](https://dev.azure.com/nsls-ii/epics-modules/_apis/build/status/NSLS-II.epics-modules?branchName=master&jobName=Windows)](https://dev.azure.com/nsls-ii/epics-modules/_build/latest?definitionId=2&branchName=master) |

## Release Files

In order to keep the release files consistent between the repositories, the `Makefile`
target `release` is used to propagate the paths into the relevant repositories. 

## Getting started

Clone the repository:
```
git clone https://github.com/NSLS-II/epics-modules
cd epics-modules/
git submodule init
git submodule update
```

To update the repository, execute the command:
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
where `XX` is the number of cores on the system. Note: this can also be accomplished by setting the
environmental variable `MAKEFLAGS`:
```
export MAKEFLAGS="--jobs `nproc`"
```

Enjoy your areaDetector build!

