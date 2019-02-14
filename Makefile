MASTER_FILE=configure/RELEASE
PERL=/usr/bin/perl
SED=/bin/sed

include configure/RELEASE

define set_release
  RELEASE_FILES += $(wildcard $($(1))/configure/RELEASE)
endef

MODULE_LIST = ASYN AUTOSAVE BUSY CALC SSCAN IOCSTATS
MODULE_LIST += SNCSEQ IPAC

$(foreach mod, $(MODULE_LIST), $(eval $(call set_release,$(mod)) ))

$(info MODULE_LIST is ${MODULE_LIST})

.PHONY: release base asyn seq calc sscan busy autosave iocstats clean

all: release base asyn seq calc sscan busy autosave iocstats

base:
	$(MAKE) -C $(EPICS_BASE)

seq: base
	$(MAKE) -C $(SNCSEQ)

asyn: base seq
	$(MAKE) -C $(ASYN)

calc: base sscan
	$(MAKE) -C $(CALC)

sscan: base seq
	$(MAKE) -C $(SSCAN)

busy: base asyn autosave
	$(MAKE) -C $(BUSY)

autosave: base
	$(MAKE) -C $(AUTOSAVE)

iocstats: base
	$(MAKE) -C $(IOCSTATS)

release:
	$(PERL) configure/makeReleaseConsistent.pl $(SUPPORT) $(EPICS_BASE) $(MASTER_FILE) $(RELEASE_FILES)
	$(SED) -i 's/^IPAC/#IPAC/g' $(RELEASE_FILES)
	#$(SED) -i 's/^SNCSEQ/#SNCSEQ/g' $(RELEASE_FILES)

clean:
	$(MAKE) -C $(EPICS_BASE) clean
	$(MAKE) -C $(SNCSEQ) clean
	$(MAKE) -C $(ASYN) clean
	$(MAKE) -C $(CALC) clean
	$(MAKE) -C $(SSCAN) clean
	$(MAKE) -C $(BUSY) clean
	$(MAKE) -C $(AUTOSAVE) clean
	$(MAKE) -C $(IOCSTATS) clean
	

