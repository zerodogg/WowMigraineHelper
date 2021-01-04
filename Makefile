SHELL=/bin/bash
VERSION:=$(shell grep Version: WowMigraineHelper.toc|perl -p -E 's/.+Version:\s+//')

test: lint validateTOC validateChangelog
lint:
	luacheck .
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
