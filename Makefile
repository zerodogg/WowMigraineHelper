SHELL=/bin/bash
DISTFILES=*.xml *.lua *.md Libs
VERSION:=$(shell grep Version: WowMigraineHelper.toc|perl -p -E 's/.+Version:\s+//')

test: prep lint validateTOC validateChangelog
lint: prep
	luacheck --codes main.lua
validateTOC:
	@for f in *lua *xml; do\
		if [ "$$f" != "Bindings.xml" ]; then\
			if ! grep -q "$$f" *.toc; then\
				echo "$$f: missing from toc";\
				exit 1;\
			fi;\
		fi;\
	done
validateChangelog:
	@if ! egrep -q "# $(VERSION)$$" CHANGELOG.md; then\
		echo "$(VERSION) missing from CHANGELOG.md";\
		exit 1;\
	fi
prep:
	@[ -e Libs/AceGUI-3.0 ] || make --no-print-directory wowace
	@[ -e Libs/LibStub ] || make --no-print-directory libstub
distclean: clean
	rm -f *.zip
clean:
	rm -rf Libs Ace3 WowMigraineHelper
wowace: clean
	mkdir -p Libs
	wget -q "https://media.forgecdn.net/files/3078/383/Ace3-Release-r1241.zip" -O Ace3.zip
	unzip -q Ace3.zip
	mv Ace3/AceGUI-3.0 Ace3/AceConfig-3.0 Ace3/AceAddon-3.0 Libs
	rm -rf Ace3 Ace3.zip
libstub:
	mkdir -p Libs
	wget -q "https://media.forgecdn.net/files/937/452/LibStub-1.0.2-70000.zip" -O LibStub.zip
	mv LibStub Libs
	rm -f LibStub.zip
libs: clean wowace libstub
dist: distclean libs
	mkdir -p WowMigraineHelper
	cp -r $(DISTFILES) WowMigraineHelper/
	zip -q -l -9 -r WowMigraineHelper-$(VERSION).zip WowMigraineHelper
	rm -rf WowMigraineHelper
