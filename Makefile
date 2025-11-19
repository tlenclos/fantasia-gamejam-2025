.PHONY: build-linux build-macos build-windows build-all clean help

# Godot version
GODOT_VERSION := 4.5
# Allow overriding GODOT_PATH via environment variable, default to 'godot' in PATH
GODOT_PATH ?= godot

# Export paths
EXPORTS_DIR := exports
LINUX_EXPORT := $(EXPORTS_DIR)/FantasiaGamejam2025-Linux.x86_64
MACOS_EXPORT := $(EXPORTS_DIR)/FantasiaGamejam2025-macOS.zip
WINDOWS_EXPORT := $(EXPORTS_DIR)/FantasiaGamejam2025-Windows.exe

# Preset names
LINUX_PRESET := Linux
MACOS_PRESET := macOS
WINDOWS_PRESET := Windows

help: ## Show this help message
	@echo "Available targets:"
	@echo "  build-linux   - Build Linux version"
	@echo "  build-macos   - Build macOS version"
	@echo "  build-windows - Build Windows version"
	@echo "  build-all     - Build all platforms"
	@echo "  clean         - Clean export artifacts"
	@echo ""
	@echo "Note: Make sure Godot $(GODOT_VERSION) is installed and available as 'godot' in your PATH"

build-linux: ## Build Linux version
	@echo "Building Linux version..."
	@mkdir -p $(EXPORTS_DIR)
	@$(GODOT_PATH) --headless --path . --export-release "$(LINUX_PRESET)" "$(LINUX_EXPORT)"
	@echo "Linux build complete: $(LINUX_EXPORT)"

build-macos: ## Build macOS version
	@echo "Building macOS version..."
	@mkdir -p $(EXPORTS_DIR)
	@$(GODOT_PATH) --headless --path . --export-release "$(MACOS_PRESET)" "$(MACOS_EXPORT)"
	@echo "macOS build complete: $(MACOS_EXPORT)"

build-windows: ## Build Windows version
	@echo "Building Windows version..."
	@mkdir -p $(EXPORTS_DIR)
	@$(GODOT_PATH) --headless --path . --export-release "$(WINDOWS_PRESET)" "$(WINDOWS_EXPORT)"
	@echo "Windows build complete: $(WINDOWS_EXPORT)"

build-all: build-linux build-macos build-windows ## Build all platforms
	@echo "All builds complete!"

clean: ## Clean export artifacts
	@echo "Cleaning export artifacts..."
	@rm -rf $(EXPORTS_DIR)
	@echo "Clean complete!"

