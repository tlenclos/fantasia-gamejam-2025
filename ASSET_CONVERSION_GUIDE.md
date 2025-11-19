# Asset Conversion Guide

## Problem
The CI build fails because Blender files (`.blend`) require Blender to be installed for Godot to import them. Blender is not available in the CI environment.

## Solution 1: Convert .blend to .glb (Recommended)

This approach converts all Blender files to GLB format, which Godot can import without requiring Blender.

### Steps:

1. **Run the conversion script** (requires Blender installed locally):
   ```bash
   bash convert_assets.sh
   ```
   
   Or manually:
   ```bash
   blender --background --python export_blend_to_glb.py
   ```

2. **Update scene references**:
   - Open `scenes/Map2.tscn` in Godot
   - Replace the reference to `res://assets/Map_02.blend` with `res://assets/Map_02.glb`
   - Save the scene

3. **Organize the files**:
   ```bash
   # Create a source folder for .blend files
   mkdir -p blender_sources
   
   # Move .blend files to sources (keep them for future editing)
   mv assets/**/*.blend blender_sources/
   mv assets/*.blend blender_sources/
   
   # Remove .blend.import files (no longer needed)
   find assets -name "*.blend.import" -delete
   ```

4. **Commit the changes**:
   ```bash
   git add assets/**/*.glb blender_sources/ scenes/Map2.tscn
   git rm assets/**/*.blend assets/**/*.blend.import assets/*.blend assets/*.blend.import
   git commit -m "Convert Blender assets to GLB for CI compatibility"
   git push
   ```

## Solution 2: Commit Godot Import Cache (Quick Fix)

This approach commits the pre-imported assets so CI doesn't need to re-import them.

### Steps:

1. **Update `.gitignore`**:
   Remove or comment out the `.godot/` line:
   ```diff
   # Godot 4+ specific ignores
   - .godot/
   + # .godot/  # Uncommenting to include imported assets for CI
   /android/
   
   exports
   ```

2. **Add the imported files**:
   ```bash
   git add .godot/imported/
   git commit -m "Include Godot import cache for CI builds"
   git push
   ```

**Note**: This will make your repository larger (~several MB depending on assets).

## Current .blend Files in Project

- `assets/Map_01.blend`
- `assets/Map_02.blend` (referenced in `scenes/Map2.tscn`)
- `assets/snowman/Snowman_arm.blend`
- `assets/snowman/Snowman_eye.blend`
- `assets/snowman/Snowman_nose.blend`
- `assets/snowman/Snowman_reference.blend`
- `assets/snowman/Snowman_step0.blend`
- `assets/snowman/Snowman_step1.blend`
- `assets/snowman/Snowman_step2.blend`
- `assets/snowman/Snowman_step3.blend`

## Recommendation

**Use Solution 1** (Convert to GLB) because:
- ✅ Smaller repository size
- ✅ Faster CI builds (no import processing)
- ✅ More portable (works everywhere)
- ✅ GLB is the standard format for 3D assets
- ✅ Better version control (text-based scene files won't change as much)

