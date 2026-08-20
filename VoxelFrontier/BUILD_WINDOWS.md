# BUILD_WINDOWS.md

## Building Voxel Frontier for Windows

This guide will walk you through building a standalone Windows executable from the Voxel Frontier project.

---

## Prerequisites

### 1. Install Godot 4.x

1. Go to https://godotengine.org/download
2. Download **Godot 4.x Standard (.NET version optional)** for Windows
3. Extract the ZIP file to a location like `C:\Godot\`
4. The executable should be named `Godot_v4.x.x.exe`

**Recommended Version:** Godot 4.2.x or 4.3.x (latest stable)

### 2. Install Export Templates

Export templates are required to build games for release.

**Option A: Automatic Installation (Recommended)**
1. Open Godot
2. Go to **Editor** → **Manage Export Templates**
3. Click **Download and Install**
4. Select the version matching your Godot installation
5. Wait for download and installation to complete

**Option B: Manual Installation**
1. Download export templates from https://godotengine.org/download
2. Extract the templates
3. Copy to `%APPDATA%\Godot\export_templates\`

---

## Quick Build (Automatic)

If you have Godot installed and in your PATH:

```powershell
# Navigate to project directory
cd VoxelFrontier

# Run the build script
.\tools\build_windows.ps1

# The executable will be in builds\windows\
```

---

## Manual Build Steps

### Step 1: Open Project in Godot

1. Launch Godot Engine
2. Click **Import**
3. Navigate to the `VoxelFrontier` folder
4. Select `project.godot` file
5. Click **Import & Edit**

### Step 2: Configure Export Preset

1. Go to **Project** → **Export**
2. Click **Add...** button
3. Select **Windows Desktop** from the list
4. Name it `Windows Desktop`

### Step 3: Configure Export Settings

In the export preset, configure these settings:

**Main Tab:**
- ✓ Export With Debug: **Unchecked** (for release)
- Debug Port: (leave default)
- Remote Host: (leave default)

**Features Tab:**
- Ensure no extra features are needed

**Options Tab:**
- **Binary Format:** 64-bit
- **Embed PCK:** Checked (optional, keeps files together)
- **Console Wrapper:** Unchecked
- **Icon:** Browse to `assets/icons/icon.ico`

**Resources Tab:**
- **Filters to Export Non-Local:** Leave empty
- **Pack Mode:** Pack all resources

### Step 4: Set Export Path

1. In the export preset, find **Export Path**
2. Set to: `builds/windows/VoxelFrontier.exe`

### Step 5: Export

1. Click **Export Project** button at bottom
2. Choose location: `builds/windows/`
3. Filename: `VoxelFrontier.exe`
4. Click **Save**
5. Wait for export to complete

---

## Using the Build Script

The project includes an automated build script.

### build_windows.ps1

```powershell
# Navigate to project root
cd VoxelFrontier

# Run the build script
.\tools\build_windows.ps1
```

What the script does:
1. Checks for Godot installation
2. Creates build directory
3. Runs Godot headless export
4. Copies required files
5. Reports success/failure

### package_windows.ps1

After building, package into a distributable ZIP:

```powershell
.\tools\package_windows.ps1
```

This creates: `builds\VoxelFrontier-Windows-x64.zip`

---

## Verifying the Build

After export completes:

1. Navigate to `builds/windows/`
2. You should see:
   - `VoxelFrontier.exe`
   - `data.pck` (if not embedded)
   - Other runtime files

3. Double-click `VoxelFrontier.exe`
4. The main menu should appear
5. Test creating a world and playing

---

## Troubleshooting

### "Export Template Not Found"

**Solution:**
1. Open Godot
2. Go to Editor → Manage Export Templates
3. Download and install templates

### "Export Failed" with No Error Message

**Common causes:**
- Export path directory doesn't exist
- File permissions issue
- Antivirus blocking

**Solution:**
1. Create the `builds/windows/` directory manually
2. Run Godot as Administrator
3. Temporarily disable antivirus

### Missing DLL Errors at Runtime

**Solution:**
Ensure all exported files are kept together:
- `VoxelFrontier.exe`
- `data.pck`
- Any `.dll` files

Don't delete any files from the export folder.

### Game Crashes on Startup

**Check:**
1. Event Viewer for crash details
2. Logs in `%APPDATA%\VoxelFrontier\logs\`
3. GPU drivers are up to date
4. DirectX 11 is supported

### Low Performance in Build vs Editor

**Try:**
1. Lower render distance in settings
2. Check if running on integrated graphics
3. Update GPU drivers
4. Ensure power plan is set to High Performance

---

## Distribution

Once you have a working build:

### Option 1: ZIP Distribution

```powershell
# Package into ZIP
.\tools\package_windows.ps1

# Distribute VoxelFrontier-Windows-x64.zip
```

Users simply:
1. Extract ZIP
2. Run `VoxelFrontier.exe`

### Option 2: Installer (Advanced)

Use tools like:
- Inno Setup
- NSIS
- WiX Toolset

Create an installer that:
1. Copies files to Program Files or user directory
2. Creates desktop shortcut
3. Adds uninstaller

---

## Build Configuration Reference

### Export Preset Settings

| Setting | Recommended Value |
|---------|-------------------|
| Binary Format | 64-bit |
| Embed PCK | Yes (optional) |
| Debug Build | No (for release) |
| Console Wrapper | No |

### Build Script Variables

Edit `tools/build_windows.ps1` to customize:

```powershell
$GODOT_PATH = "C:\Godot\Godot_v4.2.exe"  # Your Godot path
$BUILD_DIR = "builds\windows"             # Output directory
$PROJECT_NAME = "VoxelFrontier"           # Game name
```

---

## Version Information

Update version before each release in:
- `README.md`
- `scripts/core/version.gd`
- Main menu scene

---

## Signing the Executable (Optional)

For professional distribution, consider code signing:

1. Purchase code signing certificate
2. Use `signtool.exe` from Windows SDK
3. Sign after building:

```powershell
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com builds\windows\VoxelFrontier.exe
```

This prevents "Unknown Publisher" warnings.

---

## Continuous Integration (Advanced)

For automated builds, consider:
- GitHub Actions
- GitLab CI
- Azure Pipelines

Example GitHub Actions workflow would:
1. Checkout code
2. Download Godot
3. Download export templates
4. Run export command
5. Upload artifact

---

## Support

For build issues:
1. Check this document thoroughly
2. Review error messages carefully
3. Check Godot documentation
4. Verify Godot version compatibility

---

## Last Updated

Alpha 0.1.0 - Initial Release
