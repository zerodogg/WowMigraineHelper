SHELL=/bin/bash
DISTFILES=COPYING *.xml *.lua *.md *.toc libs
VERSION:=$(shell grep Version: WowMigraineHelper.toc|perl -p -E 's/.+Version:\s+//')
ACE3_RELEASE=r1241
LIBSTUB_RELEASE=1.0.2-70000
ZIPNAME=WowMigraineHelper-$(VERSION).zip

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
	@[ -e libs/AceGUI-3.0 ] || make --no-print-directory ace3
	@[ -e libs/LibStub ] || make --no-print-directory libstub
distclean: clean
	rm -f *.zip
clean:
	rm -rf libs Ace3 WowMigraineHelper
ace3: clean
	mkdir -p libs
	rm -rf libs/Ace*
	wget -q "https://media.forgecdn.net/files/3078/383/Ace3-Release-$(ACE3_RELEASE).zip" -O Ace3.zip
	unzip -q Ace3.zip
	mv Ace3/AceGUI-3.0 Ace3/AceConfig-3.0 Ace3/AceAddon-3.0 Ace3/AceEvent-3.0 libs
	rm -rf Ace3 Ace3.zip
libstub:
	mkdir -p libs
	rm -rf libs/LibStub
	wget -q "https://media.forgecdn.net/files/937/452/LibStub-$(LIBSTUB_RELEASE).zip" -O LibStub.zip
	unzip -q LibStub.zip
	mv LibStub libs
	rm -f LibStub.zip
libs: clean ace3 libstub
dist: distclean libs
	mkdir -p WowMigraineHelper
	cp -r $(DISTFILES) WowMigraineHelper/
	zip -q -l -9 -r $(ZIPNAME) WowMigraineHelper
	rm -rf WowMigraineHelper
_GITLABDIST_TOKEN?=JOB-TOKEN: $(CI_JOB_TOKEN)
# Uploads the package to gitlab and creates a new release
_gitlabdist: dist
	@if [ "$(_GITLABDIST_TOKEN)" == "JOB-TOKEN: " ]; then \
		echo "ERROR: The _gitlabdist target is intended for use in gitlab-ci only";\
		[ "$$CI_JOB_TOKEN" != "" ] && exit 1;\
	fi
	curl --header "JOB-TOKEN: $$CI_JOB_TOKEN" --upload-file $(ZIPNAME) "$${CI_API_V4_URL}/projects/$${CI_PROJECT_ID}/packages/generic/WowMigraineHelper/v$(VERSION)/$(ZIPNAME)"
	PACKAGE="$$( curl -s --header "$(_GITLABDIST_TOKEN)" "https://gitlab.com/api/v4/projects/23433152/packages/" |jq -r '.[] |select (.version=="0.3.0")|._links.web_path' )";\
	curl -s --header 'Content-Type: application/json' --header "$(_GITLABDIST_TOKEN)" \
		--data '{ "name": "v$(VERSION)", "tag_name": "v$(VERSION)", "assets": { "links": [{ "name": "$(ZIPNAME)", "url": "https://gitlab.com$$PACKAGE", "link_type":"package" }] } }' \
		--request POST "https://gitlab.com/api/v4/projects/23433152/releases"
