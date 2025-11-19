@echo off
REM Script to convert all .blend files to .glb using Blender
REM This needs to be run locally where Blender is installed

echo Converting .blend files to .glb format...
echo This requires Blender to be installed
echo.

REM Check if blender is available in PATH
where blender >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Blender is not installed or not in PATH
    echo.
    echo Please install Blender from: https://www.blender.org/download/
    echo After installation, add Blender to your PATH or run this script from the Blender installation directory
    echo.
    echo Alternatively, run this command manually from the Blender installation directory:
    echo blender --background --python "%~dp0export_blend_to_glb.py"
    pause
    exit /b 1
)

REM Run the conversion script
blender --background --python "%~dp0export_blend_to_glb.py"

echo.
echo Conversion complete!
echo.
echo Next steps:
echo 1. Update your Godot scenes to reference the .glb files instead of .blend files
echo 2. Move .blend files to a 'blender_sources' folder
echo 3. Commit the .glb files to git
echo 4. Run your CI pipeline again
echo.
pause

