#!/usr/bin/env python3
"""
Script to batch export .blend files to .glb format using Blender.
Run with: blender --background --python export_blend_to_glb.py
"""

import bpy
import os
import sys
from pathlib import Path

def export_blend_to_glb(blend_file, output_file):
    """Export a single .blend file to .glb format."""
    print(f"Processing: {blend_file}")
    
    # Clear existing scene
    bpy.ops.wm.read_factory_settings(use_empty=True)
    
    # Load the blend file
    bpy.ops.wm.open_mainfile(filepath=str(blend_file))
    
    # Export to glb
    bpy.ops.export_scene.gltf(
        filepath=str(output_file),
        export_format='GLB',
        use_selection=False,
        export_apply=True
    )
    
    print(f"Exported: {output_file}")

def main():
    # Get the script directory (project root)
    project_root = Path(__file__).parent
    
    # Find all .blend files
    blend_files = list(project_root.rglob("*.blend"))
    
    if not blend_files:
        print("No .blend files found!")
        return
    
    print(f"Found {len(blend_files)} .blend files")
    
    for blend_file in blend_files:
        # Create output path (same location, but .glb extension)
        output_file = blend_file.with_suffix('.glb')
        
        try:
            export_blend_to_glb(blend_file, output_file)
        except Exception as e:
            print(f"Error exporting {blend_file}: {e}")
            continue
    
    print("\nExport complete!")
    print(f"Exported {len(blend_files)} files to .glb format")

if __name__ == "__main__":
    main()

