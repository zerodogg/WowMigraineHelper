SHELL=/bin/bash

test: lint validateTOC
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
