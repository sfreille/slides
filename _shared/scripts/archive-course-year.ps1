<#
.SYNOPSIS
    Archive a course year using the Master + Override pattern

.DESCRIPTION
    Creates an archive snapshot of the current master files for a specific year.
    Compares master files with the previous archive to identify:
    - Changed files (differ from master, need to be archived)
    - Unique files (only exist in this year)
    - Excluded files (in master but not used this year)

    Generates a manifest.yml for the build script.

.PARAMETER Course
    Course folder name (e.g., "hpae", "cyfi")

.PARAMETER Year
    Year to archive (e.g., "2026")

.PARAMETER PreviousYear
    Previous year to compare against. Default: Year - 1

.PARAMETER DryRun
    Show what would be done without actually doing it

.EXAMPLE
    .\archive-course-year.ps1 -Course hpae -Year 2026
    .\archive-course-year.ps1 -Course hpae -Year 2026 -DryRun

.NOTES
    Run this at the END of a teaching year, before you start modifying for the next year.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Course,

    [Parameter(Mandatory=$true)]
    [string]$Year,

    [string]$PreviousYear = "",

    [switch]$DryRun
)

$BaseDir = "P:/r-Projects/slides"
$CourseDir = Join-Path $BaseDir $Course
$ArchiveDir = Join-Path $CourseDir "_archive/$Year"

# Default previous year
if (-not $PreviousYear) {
    $PreviousYear = [string]([int]$Year - 1)
}
$PrevArchiveDir = Join-Path $CourseDir "_archive/$PreviousYear"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Archiving $Course for year $Year" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if archive already exists
if (Test-Path $ArchiveDir) {
    Write-Host "WARNING: Archive for $Year already exists at $ArchiveDir" -ForegroundColor Yellow
    $response = Read-Host "Overwrite? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Aborted." -ForegroundColor Red
        exit 1
    }
}

# Get master QMD files
$MasterFiles = Get-ChildItem -Path $CourseDir -Filter "*.qmd" -File |
    Where-Object { $_.Name -notmatch "^_" }

Write-Host "Master files: $($MasterFiles.Count)" -ForegroundColor Green
Write-Host ""

# Determine what to compare against
$CompareDir = $CourseDir  # Compare against current master (for future rebuilds)
$CompareLabel = "master"

# If there's a previous archive, we can also check what's new since then
$HasPrevArchive = Test-Path $PrevArchiveDir
if ($HasPrevArchive) {
    Write-Host "Previous archive found: $PrevArchiveDir" -ForegroundColor Gray
}

# Collect file lists
$ChangedFiles = @()
$UniqueFiles = @()
$ExcludedFiles = @()
$UnchangedFiles = @()

Write-Host "Analyzing files..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $MasterFiles) {
    $fileName = $file.Name

    # For archiving, we're saving the current state
    # "Changed" means: this file should be in the archive (all files go in initially)
    # Later when master evolves, these become the "changed from master" files

    $ChangedFiles += $fileName
    Write-Host "  Archive: $fileName" -ForegroundColor Green
}

# Check for files that might be in previous archive but not in master anymore
if ($HasPrevArchive) {
    $PrevArchiveFiles = Get-ChildItem -Path $PrevArchiveDir -Filter "*.qmd" -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch "^_" }

    foreach ($prevFile in $PrevArchiveFiles) {
        $fileName = $prevFile.Name
        $masterPath = Join-Path $CourseDir $fileName

        if (-not (Test-Path $masterPath)) {
            # File was in previous archive but not in current master
            # This is a unique file for the previous year, not relevant for new archive
            Write-Host "  Note: $fileName was in $PreviousYear but not in current master" -ForegroundColor DarkGray
        }
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Files to archive: $($ChangedFiles.Count)"
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] Would create archive at: $ArchiveDir" -ForegroundColor Yellow
    Write-Host "[DRY RUN] Would copy $($ChangedFiles.Count) files" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Files to archive:" -ForegroundColor Yellow
    $ChangedFiles | ForEach-Object { Write-Host "  $_" }
    exit 0
}

# Create archive directory
Write-Host "Creating archive directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null

# Copy all master files to archive
Write-Host "Copying files to archive..." -ForegroundColor Yellow
foreach ($fileName in $ChangedFiles) {
    $sourcePath = Join-Path $CourseDir $fileName
    $destPath = Join-Path $ArchiveDir $fileName
    Copy-Item $sourcePath $destPath -Force
    Write-Host "  Copied: $fileName" -ForegroundColor Gray
}

# Generate manifest.yml
Write-Host ""
Write-Host "Generating manifest.yml..." -ForegroundColor Yellow

$manifestContent = @"
# $($Course.ToUpper()) Archive Manifest - $Year
# This file describes how to build the $Year version of slides
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

year: $Year
master_year: current  # Compare against root (master)

# Files that differ from master - use archived versions
# NOTE: When this archive was created, these were identical to master.
#       As master evolves for future years, these become the "old" versions.
changed_files:
$($ChangedFiles | ForEach-Object { "  - $_" } | Out-String)
# Files unique to this year (not in master)
# Add files here if you later remove them from master
unique_files: []

# Files from master to exclude for this year
# Add files here if master gains new files not applicable to $Year
excluded_files: []

# Notes
notes: |
  Archive created $(Get-Date -Format "yyyy-MM-dd").
  Initially all files match master.
  Update this manifest if master changes significantly.

"@

$manifestPath = Join-Path $ArchiveDir "manifest.yml"
# Write with Unix line endings
$manifestContent = $manifestContent -replace "`r`n", "`n"
[System.IO.File]::WriteAllText($manifestPath, $manifestContent, [System.Text.UTF8Encoding]::new($false))

Write-Host "  Created: manifest.yml" -ForegroundColor Gray

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Archive Complete" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Location: $ArchiveDir"
Write-Host "Files archived: $($ChangedFiles.Count)"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Continue editing master files for the new year"
Write-Host "  2. If you remove files from master, add them to 'unique_files' in manifest"
Write-Host "  3. If you add files to master not applicable to $Year, add them to 'excluded_files'"
Write-Host "  4. Test build with: .\build-course-year.ps1 -Course $Course -Year $Year -DryRun"
Write-Host ""
