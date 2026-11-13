.DEFAULT_GOAL := help

PYTHON ?= python3
MACOS_JOBS ?= 1
WINDOWS_JOBS ?= 1
MACOS_ARGS ?=
WINDOWS_ARGS ?=

.PHONY: help macos macos-release macos-native windows test-build

help:
	@echo "make macos          Build local macOS app, skip distribution ZIP"
	@echo "make macos-release  Build local macOS app and distribution ZIP"
	@echo "make macos-native   Build and check macOS native extension only"
	@echo "make windows        Build Windows x64 app and ZIP on Windows"
	@echo "make test-build     Run build-tool tests without starting a game build"
	@echo "Overrides: PYTHON, MACOS_JOBS, WINDOWS_JOBS, MACOS_ARGS, WINDOWS_ARGS"

macos:
	$(PYTHON) tools/build_macos.py --jobs $(MACOS_JOBS) --no-zip $(MACOS_ARGS)

macos-release:
	$(PYTHON) tools/build_macos.py --jobs $(MACOS_JOBS) $(MACOS_ARGS)

macos-native:
	$(PYTHON) tools/build_macos.py --jobs $(MACOS_JOBS) --native-only $(MACOS_ARGS)

windows:
	$(PYTHON) tools/build_windows.py --jobs $(WINDOWS_JOBS) $(WINDOWS_ARGS)

test-build:
	$(PYTHON) -m unittest discover -s tools -p 'test_*build*.py' -v
	$(PYTHON) -m unittest discover -s tools -p 'test_desktop_resources.py' -v
