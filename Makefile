# Set the SUPPORT Directory (from this makefile)
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR:= $(dir $(MKFILE_PATH))

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
			  ipUnidig ipac modbus motor sscan stream quadEM

MODULE_DIRS_CLEAN = $(addsuffix clean,$(MODULE_DIRS))

.PHONY: all
all: $(MODULE_DIRS)

asyn: epics-base ipac

calc: epics-base sscan

sscan: epics-base

busy: epics-base asyn autosave

autosave: epics-base

iocStats: epics-base

motor: epics-base asyn ipac

modbus: epics-base asyn

stream: epics-base asyn ipac

quadEM: epics-base ipac areaDetector 

ipac: epics-base 

ipUnidig: epics-base ipac

areaDetector: epics-base asyn calc sscan busy autosave iocStats

.PHONY: $(MODULE_DIRS)
$(MODULE_DIRS):
	$(MAKE) -C $@

.PHONY: .release_areadetector
.release_areadetector:
	cp -nv areaDetector/configure/EXAMPLE_CONFIG_SITE.local \
		      areaDetector/configure/CONFIG_SITE.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE.local \
		      areaDetector/configure/RELEASE.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE.local \
		      areaDetector/configure/RELEASE.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE_SUPPORT.local \
		      areaDetector/configure/RELEASE_SUPPORT.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE_LIBS.local \
		      areaDetector/configure/RELEASE_LIBS.local
	cp -nv areaDetector/configure/EXAMPLE_RELEASE_PRODS.local \
		      areaDetector/configure/RELEASE_PRODS.local

.PHONY: release
release: .release_areadetector
	$(eval RELEASE_FILES := $(foreach mod, $(MODULE_DIRS), $(call set_release,$(mod)) ))
	echo "SUPPORT=${MKFILE_DIR}" > "$(MKFILE_DIR)/configure/RELEASE"
	echo "EPICS_BASE=${MKFILE_DIR}/epics-base" >> "$(MKFILE_DIR)/configure/RELEASE"
	cat "${MKFILE_DIR}/configure/RELEASE.template" >> "$(MKFILE_DIR)/configure/RELEASE"
	configure/modify_release.py SNCSEQ UNSET $(RELEASE_FILES)
	configure/make_release.py "configure/RELEASE" $(RELEASE_FILES)
	configure/modify_release.py MAKE_TEST_IOC_APP UNSET "iocStats/configure/RELEASE"

#
## Update all git repos to their master (or equivalent)
#

.PHONY: update
update:
	# Initialize submodules
	git submodule foreach --recursive "git stash"
	git submodule update --init --recursive
	cd asyn && git fetch --all --tags --prune && git checkout master
	cd autosave && git fetch --all --tags --prune && git checkout master
	cd busy && git fetch --all --tags --prune && git checkout master
	cd calc && git fetch --all --tags --prune && git checkout master
	cd epics-base && git fetch --all --tags --prune && git checkout 7.0
	cd iocStats && git fetch --all --tags --prune && git checkout master
	cd ipac && git fetch --all --tags --prune && git checkout master
	cd ipUnidig && git fetch --all --tags --prune && git checkout master
	cd modbus && git fetch --all --tags --prune && git checkout master
	cd motor && git fetch --all --tags --prune && git checkout master
	cd quadEM && git fetch --all --tags --prune && git checkout master
	cd sscan && git fetch --all --tags --prune && git checkout master
	cd stream && git fetch --all --tags --prune && git checkout master
	cd stream/StreamDevice && git fetch --all --tags --prune && git checkout master
	cd areaDetector && git fetch --all --tags --prune && git checkout master
	cd areaDetector && git submodule foreach "git fetch --all --tags --prune && git checkout master"
	git submodule foreach --recursive "git stash pop || true"

#
## Clean up by running "make clean" in all modules and deleting the areadetector
## local files
#

.PHONY: clean
clean: clean_release

.PHONY: clean_modules
clean_modules: $(MODULE_DIRS_CLEAN)

%clean: 
	$(MAKE) -C $(patsubst %clean,%,$@) clean

.PHONY: clean_release
clean_release: clean_modules
	rm -rf configure/RELEASE
	rm -rf areaDetector/configure/CONFIG_SITE.local
	rm -rf areaDetector/configure/RELEASE.local
	rm -rf areaDetector/configure/RELEASE.local
	rm -rf areaDetector/configure/RELEASE_SUPPORT.local
	rm -rf areaDetector/configure/RELEASE_LIBS.local
	rm -rf areaDetector/configure/RELEASE_PRODS.local
