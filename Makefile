# Makefile for sync-android-apps
.PHONY: install test diff prepare

INSTDIR=$(HOME)/bin
INSTFILES=trapwrapper.sh

install: $(INSTFILES)
	install --target-directory=$(INSTDIR) $^

test:
	./test-trapwrapper.sh

diff: $(INSTFILES)
	$(foreach instfile,$^,diff -u $(INSTDIR)/$(instfile) $(instfile);)

IMPORTDIR1=../basictests-for-bash
IMPORTFILES1=basictests.sh

prepare: $(IMPORTFILES1)

$(IMPORTFILES1): $(IMPORTDIR1)
	ln -sf $(addprefix $^/,$@) .

$(IMPORTDIR1):
	cd $(dir $@) && git clone git@github.com:for2ando/copy-android-apps.git $(notdir $@)
