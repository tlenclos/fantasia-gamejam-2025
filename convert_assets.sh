#!/bin/bash

# Script to convert all .blend files to .glb using Blender
# This needs to be run locally where Blender is installed

echo "Converting .blend files to .glb format..."
echo "This requires Blender to be installed and available in PATH"
echo ""

# Check if blender is available
if ! command -v blender &> /dev/null; then
    echo "Error: Blender is not installed or not in PATH"
    echo "Please install Blender from: https://www.blender.org/download/"
    exit 1
fi

# Run the conversion script
blender --background --python export_blend_to_glb.py

echo ""
echo "Conversion complete!"
echo ""
echo "Next steps:"
echo "1. Update your Godot scenes to reference the .glb files instead of .blend files"
echo "2. Move .blend files to a 'sources' or 'blender_sources' folder"
echo "3. Commit the .glb files to git"
echo "4. Run your CI pipeline again"

