SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

SNAPCRAFT ?= snapcraft
SNAP_DIR ?= snap
SNAP_YAML ?= $(SNAP_DIR)/snapcraft.yaml

SNAP_NAME ?= openra-combined-arms
SNAP_ARCH ?= amd64

# Read the version from snap/snapcraft.yaml so names stay in sync.
SNAP_VERSION ?= $(shell sed -n 's/^version:[[:space:]]*"\?\([^"]*\)"\?/\1/p' "$(SNAP_YAML)" 2>/dev/null | head -n 1)

# snapcraft pack is currently producing the built snap in the repo root.
SNAP_FILE ?= $(shell ls -1 $(SNAP_NAME)_*.snap 2>/dev/null | sort -V | tail -n 1)
SNAP_EXPECTED_FILE := $(SNAP_NAME)_$(SNAP_VERSION)_$(SNAP_ARCH).snap

# Standard mount point after installation.
SNAP_MOUNT_DIR := /snap/$(SNAP_NAME)/current

.PHONY: help info build rebuild clean clean-artifacts clean-all lint \
	install reinstall refresh remove run logs connections \
	connect-extra-data disconnect-extra-data \
	smoke test test-all test-build test-install test-installed-version \
	test-layout test-shell test-env test-desktop test-confinement \
	test-artifact-version test-manual-launch dev

define snapcraft_cmd
	$(SNAPCRAFT) $(1)
endef

help: ## Show help and the workflows that make sense for this project
	@echo ""
	@echo "Common workflows:"
	@echo "-----------------"
	@echo "First local install:"
	@echo "  make build && make install && make smoke"
	@echo ""
	@echo "Normal local iteration:"
	@echo "  make build && make refresh && make smoke"
	@echo ""
	@echo "If packaging state feels weird:"
	@echo "  make clean && make build && make reinstall"
	@echo ""
	@echo "Full non-interactive verification:"
	@echo "  make test-all"
	@echo ""
	@echo "Manual GUI launch test:"
	@echo "  make run"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean            # clear snapcraft build state"
	@echo "  make clean-artifacts  # remove built .snap files from repo root"
	@echo "  make clean-all        # both"
	@echo ""
	@echo "Targets:"
	@echo "--------"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""

info: ## Print detected values
	@echo "SNAP_DIR           = $(SNAP_DIR)"
	@echo "SNAP_YAML          = $(SNAP_YAML)"
	@echo "SNAP_NAME          = $(SNAP_NAME)"
	@echo "SNAP_VERSION       = $(SNAP_VERSION)"
	@echo "SNAP_ARCH          = $(SNAP_ARCH)"
	@echo "SNAP_EXPECTED_FILE = $(SNAP_EXPECTED_FILE)"
	@echo "SNAP_FILE          = $(SNAP_FILE)"
	@echo "SNAP_MOUNT_DIR     = $(SNAP_MOUNT_DIR)"

build: ## Build the snap
	$(call snapcraft_cmd,pack)

rebuild: ## Clean snapcraft state and build again
	$(MAKE) clean
	$(MAKE) build

clean: ## Clean snapcraft build state
	$(call snapcraft_cmd,clean)

clean-artifacts: ## Remove built snap files from the repo root
	rm -f ./*.snap ./*.assert

clean-all: ## Clean snapcraft state and remove built artifacts
	$(MAKE) clean
	$(MAKE) clean-artifacts

lint: ## Run snapcraft lint
	$(call snapcraft_cmd,lint)

install: ## Install the newest local build
	@test -f "$(SNAP_FILE)" || { echo "No snap file found. Run 'make build' first."; exit 1; }
	sudo snap install --dangerous "$(SNAP_FILE)"

reinstall: ## Remove the installed snap and install the newest local build again
	@if snap list | awk '{print $$1}' | grep -qx "$(SNAP_NAME)"; then \
		sudo snap remove "$(SNAP_NAME)"; \
	fi
	$(MAKE) install

refresh: ## Replace installed snap with the newest local build
	$(MAKE) reinstall

remove: ## Remove the installed snap
	@if snap list | awk '{print $$1}' | grep -qx "$(SNAP_NAME)"; then \
		sudo snap remove "$(SNAP_NAME)"; \
	else \
		echo "$(SNAP_NAME) is not installed"; \
	fi

run: ## Launch the app manually
	snap run $(SNAP_NAME)

logs: ## Follow snap logs
	snap logs -f $(SNAP_NAME)

connections: ## Show interface connections
	snap connections $(SNAP_NAME)

connect-extra-data: ## Connect optional interfaces for discs and removable media
	sudo snap connect $(SNAP_NAME):mount-observe
	sudo snap connect $(SNAP_NAME):removable-media

disconnect-extra-data: ## Disconnect optional interfaces for discs and removable media
	sudo snap disconnect $(SNAP_NAME):mount-observe || true
	sudo snap disconnect $(SNAP_NAME):removable-media || true

smoke: test-build test-install test-installed-version test-layout ## Fast non-interactive checks

test: test-all ## Alias for the full non-interactive test pass

test-all: test-build test-artifact-version test-install test-installed-version test-layout test-shell test-env test-desktop test-confinement ## Run everything worth automating locally without opening the game

test-build: ## Verify a snap artifact exists
	@test -f "$(SNAP_FILE)" || { echo "No snap file found. Run 'make build' first."; exit 1; }
	@echo "Found snap: $(SNAP_FILE)"

test-artifact-version: ## Verify the built artifact name matches the version from snapcraft.yaml
	@test -n "$(SNAP_VERSION)" || { echo "Could not read version from $(SNAP_YAML)"; exit 1; }
	@test -f "$(SNAP_EXPECTED_FILE)" || { \
		echo "Expected artifact not found: $(SNAP_EXPECTED_FILE)"; \
		echo "Newest artifact seen: $(SNAP_FILE)"; \
		exit 1; \
	}
	@echo "Artifact version check passed"

test-install: ## Verify the snap is installed
	@snap list | awk '{print $$1}' | grep -qx "$(SNAP_NAME)" || { echo "$(SNAP_NAME) is not installed"; exit 1; }
	@echo "$(SNAP_NAME) is installed"

test-installed-version: ## Verify the installed version matches snapcraft.yaml
	@INSTALLED_VERSION="$$(snap list "$(SNAP_NAME)" | awk 'NR==2 {print $$2}')"; \
	test -n "$$INSTALLED_VERSION" || { echo "Could not detect installed version for $(SNAP_NAME)"; exit 1; }; \
	test "$$INSTALLED_VERSION" = "$(SNAP_VERSION)" || { \
		echo "Installed version mismatch: expected $(SNAP_VERSION), got $$INSTALLED_VERSION"; \
		exit 1; \
	}; \
	echo "Installed version check passed"

test-layout: ## Check for files we expect inside the installed snap
	@test -d "$(SNAP_MOUNT_DIR)" || { echo "Snap mount dir not found: $(SNAP_MOUNT_DIR)"; exit 1; }
	@test -f "$(SNAP_MOUNT_DIR)/usr/bin/openra-ca" || { echo "Missing binary: $(SNAP_MOUNT_DIR)/usr/bin/openra-ca"; exit 1; }
	@test -f "$(SNAP_MOUNT_DIR)/usr/share/applications/openra-ca.desktop" || { echo "Missing desktop file inside snap"; exit 1; }
	@echo "Layout check passed"

test-shell: ## Enter the snap environment and make sure it looks normal
	@snap run --shell $(SNAP_NAME) -c 'test -n "$$SNAP" && test -d "$$SNAP" && test -n "$$SNAP_USER_DATA"' || { \
		echo "Snap shell environment check failed"; \
		exit 1; \
	}
	@echo "Shell environment check passed"

test-env: ## Verify a few important environment variables inside the snap
	@snap run --shell $(SNAP_NAME) -c ' \
		test "$$SNAP_NAME" = "$(SNAP_NAME)" && \
		test -n "$$SNAP_REVISION" && \
		test -n "$$HOME" \
	' || { \
		echo "Snap environment variables are not what we expected"; \
		exit 1; \
	}
	@echo "Environment check passed"

test-desktop: ## Check that snapd exported a desktop launcher on the host
	@FOUND="$$(find /var/lib/snapd/desktop/applications -maxdepth 1 -type f \( -name '*$(SNAP_NAME)*.desktop' -o -name '*openra-ca*.desktop' \) | head -n 1)"; \
	test -n "$$FOUND" || { \
		echo "No exported desktop launcher found for $(SNAP_NAME)"; \
		echo "Installed launchers that look relevant:"; \
		find /var/lib/snapd/desktop/applications -maxdepth 1 -type f | grep -E 'openra|combined-arms' || true; \
		exit 1; \
	}; \
	echo "Desktop integration check passed: $$FOUND"

test-confinement: ## Basic confinement sanity check
	@echo "Checking declared connections..."
	@snap connections $(SNAP_NAME) >/dev/null || { echo "Could not inspect snap connections"; exit 1; }
	@echo "Checking that /root is not writable from inside the snap..."
	@snap run --shell $(SNAP_NAME) -c 'test ! -w /root' || { \
		echo "Unexpected write access to /root"; \
		exit 1; \
	}
	@echo "Confinement sanity check passed"

test-manual-launch: ## Manual test only; this will open the game
	@echo "Launching $(SNAP_NAME). Close it when done."
	snap run $(SNAP_NAME)

dev: ## Fast local loop: build, reinstall, smoke
	$(MAKE) build
	$(MAKE) refresh
	$(MAKE) smoke