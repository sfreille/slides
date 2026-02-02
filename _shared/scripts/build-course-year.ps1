<#
.SYNOPSIS
    Build course slides for a specific year using Master + Override pattern

.DESCRIPTION
    Reads manifest.yml from _archive/{year}/ and builds slides by:
    1. Starting with master files (root course folder)
    2. Overriding with archived files for that year
    3. Excluding files not present in that year
    4. Rendering to output folder

.PARAMETER Course
    Course folder name (e.g., "hpae", "cyfi")

.PARAMETER Year
    Year to build (e.g., "2024", "2025")

.PARAMETER OutputDir
    Output directory for rendered files. Default: course/_output/{year}

.PARAMETER Format
    Output format: "html", "pdf", or "both". Default: "html"

.PARAMETER DryRun
    Show what would be done without actually doing it

.EXAMPLE
    .\build-course-year.ps1 -Course hpae -Year 2025
    .\build-course-year.ps1 -Course hpae -Year 2024 -Format both
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Course,

    [Parameter(Mandatory=$true)]
    [string]$Year,

    [string]$OutputDir = "",

    [ValidateSet("html", "pdf", "both")]
    [string]$Format = "html",

    [switch]$DryRun
)

$BaseDir = "P:/r-Projects/slides"
$CourseDir = Join-Path $BaseDir $Course
$ArchiveDir = Join-Path $CourseDir "_archive/$Year"
$ManifestPath = Join-Path $ArchiveDir "manifest.yml"

# Set default output dir
if (-not $OutputDir) {
    $OutputDir = Join-Path $CourseDir "_output/$Year"
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Building $Course for year $Year" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check if archive exists
if (-not (Test-Path $ArchiveDir)) {
    Write-Host "No archive found for $Year. Building from master only." -ForegroundColor Yellow
    $UseArchive = $false
} else {
    $UseArchive = $true
    Write-Host "Archive found: $ArchiveDir"
}

# Create output directory
if (-not $DryRun) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
Write-Host "Output: $OutputDir"

# Get master QMD files
$MasterFiles = Get-ChildItem -Path $CourseDir -Filter "*.qmd" -File |
    Where-Object { $_.Name -ne "_quarto.yml" }

Write-Host "`nMaster files: $($MasterFiles.Count)"

# Parse manifest if using archive
$ChangedFiles = @()
$UniqueFiles = @()
$ExcludedFiles = @()

if ($UseArchive -and (Test-Path $ManifestPath)) {
    Write-Host "Reading manifest..."
    $ManifestLines = Get-Content $ManifestPath

    $currentSection = ""
    foreach ($line in $ManifestLines) {
        # Detect section headers
        if ($line -match "^changed_files:") { $currentSection = "changed"; continue }
        if ($line -match "^unique_files:") { $currentSection = "unique"; continue }
        if ($line -match "^excluded_files:") { $currentSection = "excluded"; continue }
        if ($line -match "^[a-z_]+:" -and $line -notmatch "^\s+-") { $currentSection = ""; continue }

        # Parse list items
        if ($line -match "^\s+-\s+(.+\.qmd)") {
            $fileName = $Matches[1] -replace "\s*#.*$", ""  # Remove comments
            switch ($currentSection) {
                "changed" { $ChangedFiles += $fileName }
                "unique" { $UniqueFiles += $fileName }
                "excluded" { $ExcludedFiles += $fileName }
            }
        }
    }

    Write-Host "  Changed files: $($ChangedFiles.Count)"
    Write-Host "  Unique files: $($UniqueFiles.Count)"
    Write-Host "  Excluded files: $($ExcludedFiles.Count)"
}

# Build file list for this year
$FilesToBuild = @()

foreach ($file in $MasterFiles) {
    $fileName = $file.Name

    # Skip if excluded
    if ($ExcludedFiles -contains $fileName) {
        Write-Host "  Excluding: $fileName" -ForegroundColor DarkGray
        continue
    }

    # Use archive version if changed, otherwise master
    if ($ChangedFiles -contains $fileName) {
        $sourcePath = Join-Path $ArchiveDir $fileName
        if (Test-Path $sourcePath) {
            $FilesToBuild += @{
                Name = $fileName
                Source = $sourcePath
                Type = "archive"
            }
            Write-Host "  Archive: $fileName" -ForegroundColor Yellow
        }
    } else {
        $FilesToBuild += @{
            Name = $fileName
            Source = $file.FullName
            Type = "master"
        }
        Write-Host "  Master: $fileName" -ForegroundColor Green
    }
}

# Add unique files from archive
foreach ($fileName in $UniqueFiles) {
    $sourcePath = Join-Path $ArchiveDir $fileName
    if (Test-Path $sourcePath) {
        $FilesToBuild += @{
            Name = $fileName
            Source = $sourcePath
            Type = "unique"
        }
        Write-Host "  Unique: $fileName" -ForegroundColor Magenta
    }
}

Write-Host "`nTotal files to build: $($FilesToBuild.Count)"

if ($DryRun) {
    Write-Host "`n[DRY RUN] Would build the following files:" -ForegroundColor Yellow
    $FilesToBuild | ForEach-Object { Write-Host "  $($_.Name) ($($_.Type))" }
    exit 0
}

# Copy files to output and render
Write-Host "`nBuilding..." -ForegroundColor Cyan

# Copy _quarto.yml to output
$QuartoYml = Join-Path $CourseDir "_quarto.yml"
if (Test-Path $QuartoYml) {
    Copy-Item $QuartoYml $OutputDir -Force
}

# Copy each file and render
$successCount = 0
$failCount = 0

foreach ($file in $FilesToBuild) {
    $destPath = Join-Path $OutputDir $file.Name
    Copy-Item $file.Source $destPath -Force

    Write-Host "`n[$($file.Name)] Rendering..." -ForegroundColor Yellow

    Push-Location $OutputDir
    try {
        & quarto render $file.Name --to revealjs 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$($file.Name)] Success" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "[$($file.Name)] FAILED" -ForegroundColor Red
            $failCount++
        }
    } finally {
        Pop-Location
    }
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "Build Complete" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Success: $successCount"
Write-Host "Failed: $failCount"
Write-Host "Output: $OutputDir"
