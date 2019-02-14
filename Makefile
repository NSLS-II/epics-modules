MASTER_FILE=configure/RELEASE
PERL=/usr/bin/perl
SED=/bin/sed
GIT=/usr/bin/git

include configure/RELEASE

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

$(info MODULE_LIST is ${MODULE_LIST})
$(info RELEASE_FILES are ${RELEASE_FILES})

.PHONY: release base asyn calc sscan busy autosave iocstats clean update

all: release base asyn calc sscan busy autosave iocstats

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

areadetector: base asyn calc sscan busy autosaveiocstats
	$(MAKE) -C $(AREA_DETECTOR)

release:
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
	

