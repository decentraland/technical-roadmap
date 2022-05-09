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

build: roadmap.excalidraw.svg transform.dwl raw-data.dwl
	@mkdir -p docs || true
	@DW_HOME=$(DW_HOME) $(DW) --input svg roadmap.excalidraw.svg --input data raw-data.dwl -f transform.dwl -o ./docs/output.svg

raw-data.dwl: extract.dwl
	@DW_HOME=$(DW_HOME) $(DW) --input svg roadmap.excalidraw.svg -f extract.dwl -o ./raw-data.dwl