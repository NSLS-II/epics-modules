# Set the SUPPORT Directory (from this makefile)
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))

SUPPORT := $(dir $(MKFILE_PATH))
ASYN=$(SUPPORT)/asyn
EPICS_BASE=$(SUPPORT)/epics-base
AUTOSAVE=$(SUPPORT)/autosave
BUSY=$(SUPPORT)/busy
CALC=$(SUPPORT)/calc
SSCAN=$(SUPPORT)/sscan
DEVIOCSTATS=$(SUPPORT)/iocStats
SNCSEQ=$(SUPPORT)/seq
AREA_DETECTOR=$(SUPPORT)/areaDetector
MOTOR=$(SUPPORT)/motor
MODBUS=$(SUPPORT)/modbus
STREAM=$(SUPPORT)/stream
QUADEM=$(SUPPORT)/quadEM
IPAC=$(SUPPORT)/ipac
IPUNIDIG=$(SUPPORT)/ipUnidig

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

.PHONY: clean
clean: $(MODULE_DIRS_CLEAN)

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

.PHONY: update
update:
	# Initialize submodules
	git submodule update --init --recursive
	cd "$(ASYN)" && git fetch origin master && git checkout master
	cd "$(AUTOSAVE)" && git fetch origin master && git checkout master
	cd "$(BUSY)" && git fetch origin master && git checkout master
	cd "$(CALC)" && git fetch origin master && git checkout master
	cd "$(EPICS_BASE)" && git fetch origin 7.0 && git checkout 7.0
	cd "$(DEVIOCSTATS)" && git fetch origin master && git checkout master
	cd "$(IPUNIDIG)" && git fetch origin master && git checkout master
	cd "$(IPAC)" && git fetch origin master && git checkout master
	cd "$(MODBUS)" && git fetch origin master && git checkout master
	cd "$(MOTOR)" && git fetch origin master && git checkout master
	cd "$(QUADEM)" && git fetch origin master && git checkout master
	cd "$(SSCAN)" && git fetch origin master && git checkout master
	cd "$(SSCAN)" && git fetch origin master && git checkout master
	cd "$(STREAM)" && git fetch origin master && git checkout master
	cd "$(STREAM)/StreamDevice" && git fetch origin master && git checkout master
	cd "$(AREA_DETECTOR)" && git submodule update --init --recursive --remote

%clean:
	$(MAKE) -C $(patsubst %clean,%,$@) clean

.PHONY: .clean_release
.clean_release:
	rm -rf configure/RELEASE
	rm -rf $(AREA_DETECTOR)/configure/CONFIG_SITE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_SUPPORT.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_LIBS.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_PRODS.local
