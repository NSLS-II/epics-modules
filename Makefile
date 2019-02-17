# Set the SUPPORT Directory (from this makefile)
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))

SUPPORT := $(dir $(MKFILE_PATH))

MASTER_FILE=configure/RELEASE

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
			  ipUnidig ipac modbus motor sscan stream

MODULE_DIRS_CLEAN = $(addsuffix clean,$(MODULE_DIRS))
$(info $(MODULE_DIRS_CLEAN))

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
	cp -nv $(AREA_DETECTOR)/configure/EXAMPLE_CONFIG_SITE.local \
		      $(AREA_DETECTOR)/configure/CONFIG_SITE.local
	cp -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE.local \
		      $(AREA_DETECTOR)/configure/RELEASE.local
	cp -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE.local \
		      $(AREA_DETECTOR)/configure/RELEASE.local
	cp -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE_SUPPORT.local \
		      $(AREA_DETECTOR)/configure/RELEASE_SUPPORT.local
	cp -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE_LIBS.local \
		      $(AREA_DETECTOR)/configure/RELEASE_LIBS.local
	cp -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE_PRODS.local \
		      $(AREA_DETECTOR)/configure/RELEASE_PRODS.local

.PHONY: release
release: .release_areadetector
	$(eval RELEASE_FILES := $(foreach mod, $(MODULE_DIRS), $(call set_release,$(mod)) ))
	echo "SUPPORT=${SUPPORT}" > "$(SUPPORT)/configure/RELEASE"
	echo "EPICS_BASE=${SUPPORT}/epics-base" >> "$(SUPPORT)/configure/RELEASE"
	cat "${SUPPORT}/configure/RELEASE.template" >> "$(SUPPORT)/configure/RELEASE"
	configure/modify_release.py SNCSEQ UNSET $(RELEASE_FILES)
	configure/make_release.py "$(SUPPORT)/configure/RELEASE" $(RELEASE_FILES)
	configure/modify_release.py MAKE_TEST_IOC_APP UNSET "$(DEVIOCSTATS)/configure/RELEASE"

#
## Update all git repos to their master (or equivalent)
#

.PHONY: update
update:
	# Initialize submodules
	git submodule update --init --recursive
	cd asyn && git fetch origin master && git checkout master
	cd autosave && git fetch origin master && git checkout master
	cd busy && git fetch origin master && git checkout master
	cd calc && git fetch origin master && git checkout master
	cd epics-base && git fetch origin 7.0 && git checkout 7.0
	cd iocStats && git fetch origin master && git checkout master
	cd ipac && git fetch origin master && git checkout master
	cd ipUnidig && git fetch origin master && git checkout master
	cd modbus && git fetch origin master && git checkout master
	cd motor && git fetch origin master && git checkout master
	cd quadEM && git fetch origin master && git checkout master
	cd sscan && git fetch origin master && git checkout master
	cd stream && git fetch origin master && git checkout master
	cd stream/StreamDevice && git fetch origin master && git checkout master
	cd areaDetector && git fetch origin master && git checkout master
	cd areaDetector && git submodule foreach "git fetch origin master && git checkout master"

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
	rm -rf $(AREA_DETECTOR)/configure/CONFIG_SITE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_SUPPORT.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_LIBS.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_PRODS.local
