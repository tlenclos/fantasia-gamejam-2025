.PHONY: build-linux build-macos build-windows build-all clean docker-run-server convert-blender-assets help

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

# Docker configuration
DOCKER_IMAGE := fantasia-server
DOCKER_CONTAINER := fantasia-game-server
DOCKER_PORT := 9999

help: ## Show this help message
	@echo "Available targets:"
	@echo ""
	@echo "Godot Builds:"
	@echo "  build-linux            - Build Linux version"
	@echo "  build-macos            - Build macOS version"
	@echo "  build-windows          - Build Windows version"
	@echo "  build-all              - Build all platforms"
	@echo "  clean                  - Clean export artifacts"
	@echo ""
	@echo "Assets:"
	@echo "  convert-blender-assets - Convert .blend files to .glb (requires Blender)"
	@echo ""
	@echo "Docker Server:"
	@echo "  docker-run-server      - Build and run Docker dedicated server"
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

convert-blender-assets: ## Convert .blend files to .glb format
	@echo "Converting .blend files to .glb format..."
	@echo "This requires Blender to be installed and available in PATH"
	@echo ""
	@command -v blender >/dev/null 2>&1 || { echo "Error: Blender is not installed or not in PATH"; echo "Please install Blender from: https://www.blender.org/download/"; exit 1; }
	@echo "Note: This requires export_blend_to_glb.py script to exist"
	@if [ -f export_blend_to_glb.py ]; then \
		blender --background --python export_blend_to_glb.py; \
		echo "Conversion complete!"; \
	else \
		echo "Error: export_blend_to_glb.py not found"; \
		echo "The conversion script has been removed as all assets are already converted."; \
		echo "All .blend files are in blender_sources/ and .glb files are in assets/"; \
		exit 1; \
	fi

docker-run-server:
	@echo "Building Docker dedicated server..."
	@docker stop $(DOCKER_CONTAINER) 2>/dev/null || true
	@docker rm $(DOCKER_CONTAINER) 2>/dev/null || true
	@docker rmi $(DOCKER_IMAGE) 2>/dev/null || true
	@docker build -t $(DOCKER_IMAGE) .
	@docker run -p $(DOCKER_PORT):$(DOCKER_PORT)/udp --name $(DOCKER_CONTAINER) $(DOCKER_IMAGE)
	@echo "Docker server started on port $(DOCKER_PORT)"

