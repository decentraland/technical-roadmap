UNAME := $(shell uname)

DW_VERSION := 1.0.19
ifeq ($(UNAME),Darwin)
DW_ZIP = dw-$(DW_VERSION)-macOS
else
DW_ZIP = dw-$(DW_VERSION)-Linux
endif
DW_HOME := $(shell pwd)/dw-cli
DW = dw-cli/bin/dw

install:
	@# remove local folder
	rm -rf dw-cli || true

	@# Make sure you grab the latest version
	curl -OL https://github.com/mulesoft-labs/data-weave-cli/releases/download/v$(DW_VERSION)/$(DW_ZIP)

	@# Unzip
	unzip $(DW_ZIP) -d dw-cli
	@# delete the files
	rm $(DW_ZIP)

	@# move protoc to /usr/local/bin/
	chmod +x $(DW)

process-svg: roadmap.excalidraw.svg transform.dwl
	@DW_HOME=$(DW_HOME) $(DW) --input svg roadmap.excalidraw.svg -f transform.dwl -o ./output.svg
