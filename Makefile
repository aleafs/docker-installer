TAGNAME ?= $(shell date +'v%y.%-m.%d')

release:
	git tag $(TAGNAME) --force
	git push origin $(TAGNAME) --force

.PHONY: release
