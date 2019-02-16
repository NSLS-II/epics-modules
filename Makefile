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
PERL=perl
SED=sed
GIT=git
CP=cp

define set_release
  $(wildcard $($(1))/configure/RELEASE) \
  $(wildcard $($(1))/configure/RELEASE_BASE.local) \
  $(wildcard $($(1))/configure/RELEASE_BASE.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_BASE.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_SUPPORT.local) \
  $(wildcard $($(1))/configure/RELEASE_SUPPORT.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_SUPPORT.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_PATHS.local) \
  $(wildcard $($(1))/configure/RELEASE_PATHS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_PATHS.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_LIBS.local) \
  $(wildcard $($(1))/configure/RELEASE_LIBS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_LIBS.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_PRODS.local) \
  $(wildcard $($(1))/configure/RELEASE_PRODS.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE_PRODS.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE.local) \
  $(wildcard $($(1))/configure/RELEASE.local.$(EPICS_HOST_ARCH)) \
  $(wildcard $($(1))/configure/RELEASE.$(EPICS_HOST_ARCH)) 
endef

MODULE_LIST = ASYN AUTOSAVE BUSY CALC SSCAN DEVIOCSTATS \
			  AREA_DETECTOR MOTOR MODBUS STREAM QUADEM \
			  IPAC IPUNIDIG

.PHONY: release base asyn calc sscan busy autosave \
	    iocstats motor modbus stream areadetector \
		ipac quadem ipunidig clean update

all: base asyn calc sscan busy autosave iocstats \
	 motor modbus stream areadetector ipac \
	 ipunidig
.PHONY : all

base:
	$(MAKE) -C $(EPICS_BASE)

#seq: base
#	$(MAKE) -C $(SNCSEQ)

asyn: base
	$(MAKE) -C $(ASYN)

calc: base sscan
	$(MAKE) -C $(CALC)

sscan: base
	$(MAKE) -C $(SSCAN)

busy: base asyn autosave
	$(MAKE) -C $(BUSY)

autosave: base
	$(MAKE) -C $(AUTOSAVE)

iocstats: base
	$(MAKE) -C $(DEVIOCSTATS)

motor: base asyn ipac
	$(MAKE) -C $(MOTOR)

modbus: base asyn
	$(MAKE) -C $(MODBUS)

stream: base asyn ipac
	$(MAKE) -C $(STREAM)

quadem: base ipac areadetector 
	$(MAKE) -C $(QUADEM)

ipac: base 
	$(MAKE) -C $(IPAC) 

ipunidig: base ipac
	$(MAKE) -C $(IPUNIDIG)

areadetector: base asyn calc sscan busy autosave iocstats
	$(MAKE) -C $(AREA_DETECTOR)

.release_areadetector:
	$(CP) -nv $(AREA_DETECTOR)/configure/EXAMPLE_CONFIG_SITE.local \
		      $(AREA_DETECTOR)/configure/CONFIG_SITE.local
	$(CP) -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE.local \
		      $(AREA_DETECTOR)/configure/RELEASE.local
	$(CP) -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE.local \
		      $(AREA_DETECTOR)/configure/RELEASE.local
	$(CP) -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE_SUPPORT.local \
		      $(AREA_DETECTOR)/configure/RELEASE_SUPPORT.local
	$(CP) -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE_LIBS.local \
		      $(AREA_DETECTOR)/configure/RELEASE_LIBS.local
	$(CP) -nv $(AREA_DETECTOR)/configure/EXAMPLE_RELEASE_PRODS.local \
		      $(AREA_DETECTOR)/configure/RELEASE_PRODS.local

.release_setvar: .release_areadetector
	$(eval RELEASE_FILES := $(foreach mod, $(MODULE_LIST), $(call set_release,$(mod)) ))

release: .release_setvar
	echo "SUPPORT=${SUPPORT}" > "$(SUPPORT)/configure/RELEASE"
	cat "${SUPPORT}/configure/RELEASE.template" >> "$(SUPPORT)/configure/RELEASE"
	configure/make_release.py "$(SUPPORT)/configure/RELEASE" $(RELEASE_FILES)
	configure/modify_release.py $(DEVIOCSTATS)/configure/RELEASE MAKE_TEST_IOC_APP UNSET

update:
	#$(GIT) submodule foreach "git stash || true"
	$(GIT) submodule update --init --recursive
	$(GIT) pull --recurse-submodules
	cd "$(AREA_DETECTOR)" && $(GIT) submodule update --init --recursive --remote
	#$(GIT) submodule foreach "git stash pop || true"

clean:
	$(MAKE) -C $(EPICS_BASE) clean
	#$(MAKE) -C $(SNCSEQ) clean
	$(MAKE) -C $(ASYN) clean
	$(MAKE) -C $(CALC) clean
	$(MAKE) -C $(SSCAN) clean
	$(MAKE) -C $(BUSY) clean
	$(MAKE) -C $(AUTOSAVE) clean
	$(MAKE) -C $(DEVIOCSTATS) clean
	$(MAKE) -C $(AREA_DETECTOR) clean
	#$(MAKE) -C $(MOTOR) clean
	$(MAKE) -C $(MODBUS) clean
	$(MAKE) -C $(STREAM) clean
	$(MAKE) -C $(IPAC) clean
	$(MAKE) -C $(IPUNIDIG) clean
	$(MAKE) -C $(QUADEM) clean
	rm -rf configure/RELEASE
	rm -rf $(AREA_DETECTOR)/configure/CONFIG_SITE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_SUPPORT.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_LIBS.local
	rm -rf $(AREA_DETECTOR)/configure/RELEASE_PRODS.local
	

