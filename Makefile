# Set the SUPPORT Directory (from this makefile)
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
SUPPORT := $(dir $(MKFILE_PATH))
$(info MKFILE_PATH=${MKFILE_PATH})
$(info SUPPORT=${SUPPORT})

ASYN=$(SUPPORT)/asyn
EPICS_BASE=$(SUPPORT)/epics-base
AUTOSAVE=$(SUPPORT)/autosave
BUSY=$(SUPPORT)/busy
CALC=$(SUPPORT)/calc
SSCAN=$(SUPPORT)/sscan
DEVIOCSTATS=$(SUPPORT)/iocStats
SNCSEQ=$(SUPPORT)/seq
AREA_DETECTOR=$(SUPPORT)/areaDetector

# Include overrides
#include configure/RELEASE

MASTER_FILE=configure/RELEASE
PERL=perl
SED=sed
GIT=git
CP=cp

define set_release
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE)
  # areaDetector has differently named RELEASE files
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_BASE.local)
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_BASE.local.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_BASE.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_SUPPORT.local)
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_SUPPORT.local.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_SUPPORT.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_PATHS.local)
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_PATHS.local.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_PATHS.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_LIBS.local)
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_LIBS.local.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_LIBS.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_PRODS.local)
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_PRODS.local.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE_PRODS.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE.local)
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE.local.$(EPICS_HOST_ARCH))
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE.$(EPICS_HOST_ARCH))
endef

MODULE_LIST = ASYN AUTOSAVE BUSY CALC SSCAN DEVIOCSTATS AREA_DETECTOR
$(foreach mod, $(MODULE_LIST), $(eval $(call set_release,$(mod)) ))

.PHONY: release base asyn calc sscan busy autosave iocstats clean update

all: base asyn calc sscan busy autosave iocstats areadetector
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

areadetector: base asyn calc sscan busy autosave iocstats
	$(MAKE) -C $(AREA_DETECTOR)

release:
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
	echo "SUPPORT=${SUPPORT}" > "$(SUPPORT)/configure/RELEASE"
	cat "${SUPPORT}/configure/RELEASE.template" >> "$(SUPPORT)/configure/RELEASE"
	$(PERL) configure/makeReleaseConsistent.pl $(SUPPORT) $(EPICS_BASE) $(MASTER_FILE) $(RELEASE_FILES)
	$(SED) -i 's/^IPAC/#IPAC/g' $(RELEASE_FILES)
	$(SED) -i 's/^SNCSEQ/#SNCSEQ/g' $(RELEASE_FILES)
	$(SED) -i 's/^MAKE_TEST_IOC_APP/#MAKE_TEST_IOC_APP/g' $(DEVIOCSTATS)/configure/RELEASE

update:
	$(GIT) submodule update --init --recursive

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
	rm -rf configure/RELEASE
	

