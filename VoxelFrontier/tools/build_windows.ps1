# Voxel Frontier - Windows Build Script
# This script builds the game for Windows using Godot

param(
    [string]$GodotPath = "",
    [switch]$Debug,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Help {
    Write-Host @"
Voxel Frontier - Windows Build Script

Usage: .\build_windows.ps1 [options]

Options:
  -GodotPath <path>   Path to Godot executable (auto-detected if not specified)
  -Debug              Build with debug symbols
  -Help               Show this help message

Examples:
  .\build_windows.ps1
  .\build_windows.ps1 -GodotPath "C:\Program Files\Godot\Godot_v4.2.exe"
  .\build_windows.ps1 -Debug

"@
}

if ($Help) {
    Show-Help
    exit 0
}

Write-Host "======================================"
Write-Host "  Voxel Frontier - Windows Build"
Write-Host "======================================"
Write-Host ""

# Find Godot executable
if ([string]::IsNullOrEmpty($GodotPath)) {
    Write-Host "Searching for Godot installation..."
    
    # Check common locations
    $possiblePaths = @(
        "$env:ProgramFiles\Godot\Godot_v4*.exe",
        "$env:ProgramFiles(x86)\Godot\Godot_v4*.exe",
        "$env:LOCALAPPDATA\Godot\Godot_v4*.exe",
        ".\Godot_v4*.exe"
    )
    
    foreach ($pattern in $possiblePaths) {
        $found = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $GodotPath = $found.FullName
            break
        }
    }
    
    if ([string]::IsNullOrEmpty($GodotPath)) {
        Write-Host "ERROR: Could not find Godot executable." -ForegroundColor Red
        Write-Host ""
        Write-Host "Please install Godot 4.x from https://godotengine.org/download"
        Write-Host "Or specify the path using -GodotPath parameter"
        Write-Host ""
        Write-Host "Example:"
        Write-Host "  .\build_windows.ps1 -GodotPath `"C:\Program Files\Godot\Godot_v4.2.exe`""
        exit 1
    }
}

Write-Host "Using Godot: $GodotPath"
Write-Host ""

# Verify Godot exists
if (-not (Test-Path $GodotPath)) {
    Write-Host "ERROR: Godot executable not found at: $GodotPath" -ForegroundColor Red
    exit 1
}

# Get project directory
$ProjectDir = Split-Path -Parent $PSScriptRoot
$ProjectFile = Join-Path $ProjectDir "project.godot"

if (-not (Test-Path $ProjectFile)) {
    Write-Host "ERROR: project.godot not found in: $ProjectDir" -ForegroundColor Red
    exit 1
}

# Create build output directory
$BuildDir = Join-Path $ProjectDir "builds\windows"
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
    Write-Host "Created build directory: $BuildDir"
}

# Determine export preset name
$ExportPreset = "Windows Desktop"
$OutputName = "VoxelFrontier.exe"

if ($Debug) {
    Write-Host "Building DEBUG version..." -ForegroundColor Yellow
    $OutputName = "VoxelFrontier_debug.exe"
} else {
    Write-Host "Building RELEASE version..." -ForegroundColor Green
}

$OutputPath = Join-Path $BuildDir $OutputName

# Build command
$Arguments = @(
    "--headless",
    "--export-release",
    "`"$ExportPreset`"",
    "`"$OutputPath`""
)

if ($Debug) {
    $Arguments = @(
        "--headless",
        "--export-debug",
        "`"$ExportPreset`"",
        "`"$OutputPath`""
    )
}

Write-Host "Building..."
Write-Host "  Command: $GodotPath $($Arguments -join ' ')"
Write-Host ""

# Run Godot export
try {
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $GodotPath
    $processInfo.Arguments = $Arguments -join ' '
    $processInfo.WorkingDirectory = $ProjectDir
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true
    
    $process = [System.Diagnostics.Process]::Start($processInfo)
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    
    if ($output) {
        Write-Host $output
    }
    
    if ($errorOutput) {
        Write-Host $errorOutput -ForegroundColor Yellow
    }
    
    if ($process.ExitCode -eq 0) {
        Write-Host ""
        Write-Host "======================================" -ForegroundColor Green
        Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
        Write-Host "======================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Executable created at:"
        Write-Host "  $OutputPath" -ForegroundColor Cyan
        Write-Host ""
        
        # List files in build directory
        Write-Host "Build contents:"
        Get-ChildItem -Path $BuildDir | ForEach-Object {
            Write-Host "  $($_.Name)"
        }
        Write-Host ""
        
        # Instructions
        Write-Host "To test the build:"
        Write-Host "  1. Navigate to: $BuildDir"
        Write-Host "  2. Double-click: $OutputName"
        Write-Host ""
        
    } else {
        Write-Host ""
        Write-Host "======================================" -ForegroundColor Red
        Write-Host "  BUILD FAILED (Exit code: $($process.ExitCode))" -ForegroundColor Red
        Write-Host "======================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Common issues:"
        Write-Host "  - Export template not installed"
        Write-Host "  - Export preset not configured"
        Write-Host "  - Missing dependencies"
        Write-Host ""
        Write-Host "See BUILD_WINDOWS.md for setup instructions."
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: Build failed with exception:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}
