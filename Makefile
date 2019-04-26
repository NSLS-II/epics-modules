# Some defaults
prefix = /opt
EPICS_DIR = /epics
PACKAGE_NAME = epics-modules
TAR_PREFIX = opt/epics
DEBIAN=ci/DEBIAN

# Set the SUPPORT Directory (from this makefile)
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR:= $(dir $(MKFILE_PATH))
SUPPORT := $(or $(SUPPORT), $(MKFILE_DIR))

# Set the version from the git info
VERSION = $(shell git describe --tags --always)

# Print INFO

$(info git version      = $(VERSION))
$(info prefix           = $(prefix))
$(info EPICS_DIR        = $(EPICS_DIR))
$(info PACKAGE_NAME     = $(PACKAGE_NAME))
$(info TAR_PREFIX       = $(TAR_PREFIX))
$(info RELEASE_PREFIX   = $(RELEASE_PREFIX))
$(info MKFILE_PATH      = $(MKFILE_PATH))
$(info MKFILE_DIR       = $(MKFILE_DIR))
$(info SUPPORT          = $(SUPPORT))
$(info DEBIAN           = $(DEBIAN))

#
## Version Definitions
#

EPICS_BASE_VERSION    := $(or $(EPICS_BASE_VERSION), 7.0)
ASYN_VERSION          := $(or $(ASYN_VERSION), master)
AUTOSAVE_VERSION      := $(or $(AUTOSAVE_VERSION), master)
BUSY_VERSION          := $(or $(BUSY_VERSION), master)
CALC_VERSION          := $(or $(CALC_VERSION), master)
SSCAN_VERSION         := $(or $(SSCAN_VERSION), master)
DEVIOCSTATS_VERSION   := $(or $(DEVIOCSTATS_VERSION), master)
SNCSEQ_VERSION        := $(or $(SNCSEQ_VERSION), master)
AREA_DETECTOR_VERSION := $(or $(AREA_DETECTOR_VERSION), master)
ADCORE_VERSION        := $(or $(ADCORE_VERSION), master)
MOTOR_VERSION         := $(or $(MOTOR_VERSION), master)
MODBUS_VERSION        := $(or $(MODBUS_VERSION), master)
STREAM_VERSION        := $(or $(STREAM_VERSION), master)
QUADEM_VERSION        := $(or $(QUADEM_VERSION), master)
IPAC_VERSION          := $(or $(IPAC_VERSION), master)
IPUNIDIG_VERSION      := $(or $(IPUNIDIG_VERSION), master)
XSPRESS3_VERSION      := $(or $(XSPRESS3_VERSION), qd-prod)

#
## If files exist in the configure dir, include them If files exist in the configure dir, include them  
#

-include configure/VERSIONS
-include configure/VERSIONS.$(EPICS_HOST_ARCH)

#
## Function to get all release files
#

define set_release
  $(wildcard $(1)/configure/RELEASE) \
  $(wildcard $(1)/configure/RELEASE_BASE.local) \
  $(wildcard $(1)/configure/RELEASE_BASE.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_BASE.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_SUPPORT.local) \
  $(wildcard $(1)/configure/RELEASE_SUPPORT.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_SUPPORT.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_PATHS.local) \
  $(wildcard $(1)/configure/RELEASE_PATHS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_PATHS.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_LIBS.local) \
  $(wildcard $(1)/configure/RELEASE_LIBS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_LIBS.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_PRODS.local) \
  $(wildcard $(1)/configure/RELEASE_PRODS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE_PRODS.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE.local) \
  $(wildcard $(1)/configure/RELEASE.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $(1)/configure/RELEASE.$(EPICS_HOST_ARCH)) 
endef

MODULE_DIRS = areaDetector asyn autosave busy calc epics-base iocStats \
			  ipUnidig ipac modbus motor sscan stream quadEM xspress3-epics

MODULE_DIRS_CLEAN = $(addsuffix _clean,$(MODULE_DIRS))
MODULE_DIRS_UNINSTALL = $(addsuffix _uninstall,$(MODULE_DIRS))
MODULE_DIRS_INSTALL = $(addsuffix _install,$(MODULE_DIRS))
MODULE_DIRS_VERSION = $(addsuffix _version,$(MODULE_DIRS))

.PHONY: all
all: $(MODULE_DIRS)

asyn: epics-base ipac

calc: epics-base sscan

sscan: epics-base

busy: epics-base asyn autosave

autosave: epics-base

iocStats: epics-base

motor: epics-base asyn busy ipac

modbus: epics-base asyn

stream: epics-base asyn calc sscan

ipUnidig: epics-base asyn ipac

quadEM: epics-base ipac busy ipUnidig autosave sscan calc iocStats areaDetector 

ipac: epics-base 

areaDetector: epics-base asyn calc sscan busy autosave iocStats

xspress3-epics: epics-base asyn calc busy areaDetector

.PHONY: $(MODULE_DIRS)
$(MODULE_DIRS):
	$(MAKE) -C $@

.PHONY: .release_areadetector
.release_areadetector:
	cp -nv $(RELEASE_PREFIX)areaDetector/configure/EXAMPLE_CONFIG_SITE.local \
		      $(RELEASE_PREFIX)areaDetector/configure/CONFIG_SITE.local
	cp -nv $(RELEASE_PREFIX)areaDetector/configure/EXAMPLE_RELEASE.local \
		      $(RELEASE_PREFIX)areaDetector/configure/RELEASE.local
	cp -nv $(RELEASE_PREFIX)areaDetector/configure/EXAMPLE_RELEASE_SUPPORT.local \
		      $(RELEASE_PREFIX)areaDetector/configure/RELEASE_SUPPORT.local
	cp -nv $(RELEASE_PREFIX)areaDetector/configure/EXAMPLE_RELEASE_LIBS.local \
		      $(RELEASE_PREFIX)areaDetector/configure/RELEASE_LIBS.local
	cp -nv $(RELEASE_PREFIX)areaDetector/configure/EXAMPLE_RELEASE_PRODS.local \
		      $(RELEASE_PREFIX)areaDetector/configure/RELEASE_PRODS.local
	cp -nv configure/RELEASE.local.linux-x86_64 \
		      $(RELEASE_PREFIX)areaDetector/configure/RELEASE.local.linux-x86_64
	cp -nv $(RELEASE_PREFIX)areaDetector/configure/EXAMPLE_CONFIG_SITE.local.Linux \
		      $(RELEASE_PREFIX)areaDetector/configure/CONFIG_SITE.local.Linux

.PHONY: release
release: .release_areadetector
	$(eval RELEASE_FILES := $(foreach mod, $(MODULE_DIRS), $(call set_release,$(mod)) ))
	echo "SUPPORT=$(SUPPORT)" > "$(RELEASE_PREFIX)configure/RELEASE"
	echo "EPICS_BASE=$(SUPPORT)/epics-base" >> "$(RELEASE_PREFIX)configure/RELEASE"
	cat "$(RELEASE_PREFIX)configure/RELEASE.template" >> "$(RELEASE_PREFIX)configure/RELEASE"
	configure/modify_release.py SNCSEQ UNSET $(RELEASE_PREFIX)$(RELEASE_FILES)
	configure/make_release.py "configure/RELEASE" $(RELEASE_FILES)
	configure/modify_release.py MAKE_TEST_IOC_APP UNSET "$(RELEASE_PREFIX)iocStats/configure/RELEASE"
	configure/modify_release.py STATIC_BUILD YES "$(RELEASE_PREFIX)epics-base/configure/CONFIG_SITE"
	configure/modify_release.py SHARED_LIBRARIES NO "$(RELEASE_PREFIX)epics-base/configure/CONFIG_SITE"

#
## Update all git repos to their master (or equivalent)
#

.PHONY: update
update:
	# Initialize submodules
	git submodule foreach --recursive "git stash"
	git submodule update --init --recursive
	cd asyn && git fetch --all --tags --prune && git checkout $(ASYN_VERSION)
	cd autosave && git fetch --all --tags --prune && git checkout $(AUTOSAVE_VERSION)
	cd busy && git fetch --all --tags --prune && git checkout $(BUSY_VERSION)
	cd calc && git fetch --all --tags --prune && git checkout $(CALC_VERSION)
	cd epics-base && git fetch --all --tags --prune && git checkout $(EPICS_BASE_VERSION)
	cd iocStats && git fetch --all --tags --prune && git checkout $(DEVIOCSTATS_VERSION)
	cd ipac && git fetch --all --tags --prune && git checkout $(IPAC_VERSION)
	cd ipUnidig && git fetch --all --tags --prune && git checkout $(IPUNIDIG_VERSION)
	cd modbus && git fetch --all --tags --prune && git checkout $(MODBUS_VERSION)
	cd motor && git fetch --all --tags --prune && git checkout $(MOTOR_VERSION)
	cd quadEM && git fetch --all --tags --prune && git checkout $(QUADEM_VERSION)
	cd sscan && git fetch --all --tags --prune && git checkout $(SSCAN_VERSION)
	cd stream && git fetch --all --tags --prune && git checkout $(STREAM_VERSION)
	#cd stream/StreamDevice && git fetch --all --tags --prune && git checkout $(STREAM_VERSION)
	cd xspress3-epics && git fetch --all --tags --prune && git checkout $(XSPRESS3_VERSION)
	cd areaDetector && git submodule update --init --recursive
	cd areaDetector && git fetch --all --tags --prune && git checkout $(AREA_DETECTOR_VERSION)
	cd areaDetector && git submodule foreach "git fetch --all --tags --prune && git checkout master"
	git submodule foreach --recursive "git stash pop || true"

#
## Install into directory
#

.PHONY: .install
.install: 
	install -Dd $(DESTDIR)$(prefix)/$(EPICS_DIR)

.PHONY: install
install: .install $(MODULE_DIRS_INSTALL) configure_install

%_install: 
	tar --exclude-vcs -cf - $(patsubst %_install,%,$@) | \
		(cd $(DESTDIR)$(prefix)/$(EPICS_DIR) && tar xf - )
#
## Clean up by running "make clean" in all modules and deleting the areadetector
## local files
#

.PHONY: clean
clean: clean_release_files

.PHONY: clean_modules
clean_modules: $(MODULE_DIRS_CLEAN)

.PHONY: uninstal
uninstall: $(MODULE_DIRS_UNINSTALL)

%_clean: 
	$(MAKE) -C $(patsubst %_clean,%,$@) clean

%_uninstall: 
	$(MAKE) -C $(patsubst %_uninstall,%,$@) uninstall

.PHONY: clean_release_files
clean_release_files: clean_modules
	rm -f configure/RELEASE
	rm -f areaDetector/configure/CONFIG_SITE.local
	rm -f areaDetector/configure/RELEASE.local
	rm -f areaDetector/configure/RELEASE_SUPPORT.local
	rm -f areaDetector/configure/RELEASE_LIBS.local
	rm -f areaDetector/configure/RELEASE_PRODS.local
	rm -f areaDetector/configure/RELEASE.local.linux-x86_64
	
#
## Make version info from git
#

.PHONY: versions
versions: .version_header $(MODULE_DIRS_VERSION)

PHONY: .version_header
.version_header:
	@printf "Versions:\n"
	@printf "Created with %s\n\n" "$(shell git describe --tags)"

%_version: .version_header
	@printf "%20s = %s\n" \
		"$(patsubst %_version,%,$@)" \
		"$(shell cd $(patsubst %_version,%,$@) && git describe --tags)"

.PHONY: archive
archive:
	tar --exclude-vcs --exclude-backups \
	-cjf $(PACKAGE_NAME)_$(EPICS_HOST_ARCH)_$(VERSION).tar.bz2 \
	--transform 's,$(DESTDIR)/,,' --show-transformed \
	$(DESTDIR)

.PHONY: debian
debian: 
	cp -r $(DEBIAN) $(DESTDIR)
	dpkg-deb --build $(DESTDIR) $(PACKAGE_NAME)_$(VERSION).deb
