# Step-by-Step Conversion Instructions

## Prerequisites
- Blender installed on your system (download from https://www.blender.org/download/)
- Blender added to your PATH, or know the installation directory

## Step 1: Run the Conversion Script

**Option A**: If Blender is in your PATH:
```bash
# On Windows (Git Bash)
bash convert_assets.sh

# On Windows (Command Prompt)
convert_assets.bat
```

**Option B**: If Blender is NOT in your PATH:
```bash
# Navigate to Blender installation directory, e.g.:
cd "C:\Program Files\Blender Foundation\Blender 4.x"

# Run the conversion (replace with your actual project path)
blender.exe --background --python "C:\Users\thiba\Documents\GitHub\fantasia-gamejam-2025\export_blend_to_glb.py"
```

After this step, you should see `.glb` files next to each `.blend` file in your `assets/` directory.

## Step 2: Verify the Conversion

Check that these files were created:
- `assets/Map_01.glb`
- `assets/Map_02.glb`
- `assets/snowman/Snowman_arm.glb`
- `assets/snowman/Snowman_eye.glb`
- `assets/snowman/Snowman_nose.glb`
- `assets/snowman/Snowman_reference.glb`
- `assets/snowman/Snowman_step0.glb`
- `assets/snowman/Snowman_step1.glb`
- `assets/snowman/Snowman_step2.glb`
- `assets/snowman/Snowman_step3.glb`

## Step 3: Update Scene References in Godot

Open your project in Godot and update the scene:

1. Open `scenes/Map2.tscn` in Godot
2. Find the node that references `res://assets/Map_02.blend`
3. Change it to reference `res://assets/Map_02.glb`
4. Save the scene (Ctrl+S)

## Step 4: Move Source Files (Optional but Recommended)

Keep the original `.blend` files for future editing:

```bash
# Move .blend files to source folder
mv assets/*.blend blender_sources/ 2>/dev/null || true
mv assets/snowman/*.blend blender_sources/ 2>/dev/null || true
```

## Step 5: Clean Up Import Files

Remove the old `.blend.import` files:

```bash
# On Windows (Git Bash)
find assets -name "*.blend.import" -delete

# Or manually delete these files:
# - assets/Map_01.blend.import
# - assets/Map_02.blend.import
# - assets/snowman/*.blend.import
```

## Step 6: Test Locally

Before committing, test that everything works:

1. Open your project in Godot
2. Run the game and verify all 3D models load correctly
3. Check that Map2 scene works properly

## Step 7: Commit the Changes

```bash
# Add new .glb files
git add assets/**/*.glb

# Add updated scene
git add scenes/Map2.tscn

# Add source files if moved
git add blender_sources/

# Remove .blend files from git (if moved)
git rm -r assets/**/*.blend assets/*.blend

# Remove .blend.import files
git rm -r assets/**/*.blend.import assets/*.blend.import

# Commit
git commit -m "Convert Blender assets to GLB for CI compatibility"

# Push
git push origin fix/github-ci
```

## Step 8: Test CI

After pushing, go to GitHub Actions and run your release workflow again. The build should now work without Blender!

## Troubleshooting

### "Blender not found"
- Verify Blender is installed
- Add Blender to PATH, or use the full path to blender.exe

### "Export failed"
- Make sure the .blend files are not corrupted
- Try opening them in Blender manually first

### "Scene still references .blend"
- Re-open the scene in Godot and verify the path changed
- Check for other scenes that might reference .blend files:
  ```bash
  grep -r "\.blend" scenes/
  ```

## Need Help?

If you encounter issues, let me know and I can help troubleshoot!

