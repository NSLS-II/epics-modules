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

.PHONY: base asyn seq clean busy

all: release 
#base seq asyn calc sscan busy autosave

base:
	$(MAKE) -C $(EPICS_BASE)

#seq: base
#	$(MAKE) -C $(SEQ)

asyn: base
	$(MAKE) -C $(ASYN)

calc: base sscan seq
	$(MAKE) -C $(CALC)

sscan: base seq
	$(MAKE) -C $(SSCAN)

busy: base asyn
	$(MAKE) -C $(BUSY)

autosave: base
	$(MAKE) -C $(AUTOSAVE)

release:
	$(PERL) configure/makeReleaseConsistent.pl $(SUPPORT) $(EPICS_BASE) $(MASTER_FILE) $(RELEASE_FILES)
	$(SED) -i 's/^IPAC/#IPAC/g' $(RELEASE_FILES)
	$(SED) -i 's/^SNCSEQ/#SNCSEQ/g' $(RELEASE_FILES)

clean:
	$(MAKE) -C $(EPICS_BASE) clean
	$(MAKE) -C $(SEQ) clean
	$(MAKE) -C $(SSCAN) clean
	$(MAKE) -C $(CALC) clean
	$(MAKE) -C $(BUSY) clean
	$(MAKE) -C $(AUTOSAVE) clean
	$(MAKE) -C $(ASYN) clean
	$(MAKE) -C $(IOCSTATS) clean
	

