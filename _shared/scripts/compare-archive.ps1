<#
.SYNOPSIS
    Compare master files with an existing archive

.DESCRIPTION
    Analyzes differences between current master and an archived year.
    Useful for:
    - Updating manifest.yml after master has evolved
    - Seeing what changed between years
    - Identifying files that need to be added to unique_files or excluded_files

.PARAMETER Course
    Course folder name (e.g., "hpae", "cyfi")

.PARAMETER Year
    Year archive to compare against

.PARAMETER Detailed
    Show detailed diff for changed files

.EXAMPLE
    .\compare-archive.ps1 -Course hpae -Year 2025
    .\compare-archive.ps1 -Course hpae -Year 2026 -Detailed
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Course,

    [Parameter(Mandatory=$true)]
    [string]$Year,

    [switch]$Detailed
)

$BaseDir = "P:/r-Projects/slides"
$CourseDir = Join-Path $BaseDir $Course
$ArchiveDir = Join-Path $CourseDir "_archive/$Year"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Comparing $Course master vs $Year archive" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if archive exists
if (-not (Test-Path $ArchiveDir)) {
    Write-Host "ERROR: Archive not found at $ArchiveDir" -ForegroundColor Red
    exit 1
}

# Get file lists
$MasterFiles = Get-ChildItem -Path $CourseDir -Filter "*.qmd" -File |
    Where-Object { $_.Name -notmatch "^_" } |
    Select-Object -ExpandProperty Name

$ArchiveFiles = Get-ChildItem -Path $ArchiveDir -Filter "*.qmd" -File |
    Where-Object { $_.Name -notmatch "^_" } |
    Select-Object -ExpandProperty Name

Write-Host "Master files: $($MasterFiles.Count)"
Write-Host "Archive files: $($ArchiveFiles.Count)"
Write-Host ""

# Categorize files
$Identical = @()
$Changed = @()
$OnlyInMaster = @()
$OnlyInArchive = @()

# Check files in master
foreach ($fileName in $MasterFiles) {
    $masterPath = Join-Path $CourseDir $fileName
    $archivePath = Join-Path $ArchiveDir $fileName

    if (Test-Path $archivePath) {
        # File exists in both - compare content
        $masterHash = (Get-FileHash $masterPath -Algorithm MD5).Hash
        $archiveHash = (Get-FileHash $archivePath -Algorithm MD5).Hash

        if ($masterHash -eq $archiveHash) {
            $Identical += $fileName
        } else {
            $Changed += $fileName
        }
    } else {
        # File only in master (new file added after archive was created)
        $OnlyInMaster += $fileName
    }
}

# Check files only in archive
foreach ($fileName in $ArchiveFiles) {
    if ($fileName -notin $MasterFiles) {
        $OnlyInArchive += $fileName
    }
}

# Report results
Write-Host "=== IDENTICAL (no changes needed) ===" -ForegroundColor Green
if ($Identical.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Gray
} else {
    $Identical | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
}
Write-Host ""

Write-Host "=== CHANGED (archive differs from master) ===" -ForegroundColor Yellow
if ($Changed.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Gray
} else {
    $Changed | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "  -> These should be in 'changed_files' in manifest.yml" -ForegroundColor Cyan
}
Write-Host ""

Write-Host "=== ONLY IN MASTER (new files, not in $Year) ===" -ForegroundColor Magenta
if ($OnlyInMaster.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Gray
} else {
    $OnlyInMaster | ForEach-Object { Write-Host "  $_" -ForegroundColor Magenta }
    Write-Host ""
    Write-Host "  -> Add to 'excluded_files' in manifest.yml if not applicable to $Year" -ForegroundColor Cyan
}
Write-Host ""

Write-Host "=== ONLY IN ARCHIVE (removed from master, unique to $Year) ===" -ForegroundColor Blue
if ($OnlyInArchive.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Gray
} else {
    $OnlyInArchive | ForEach-Object { Write-Host "  $_" -ForegroundColor Blue }
    Write-Host ""
    Write-Host "  -> These should be in 'unique_files' in manifest.yml" -ForegroundColor Cyan
}
Write-Host ""

# Show detailed diffs if requested
if ($Detailed -and $Changed.Count -gt 0) {
    Write-Host "=== DETAILED CHANGES ===" -ForegroundColor Cyan
    foreach ($fileName in $Changed) {
        $masterPath = Join-Path $CourseDir $fileName
        $archivePath = Join-Path $ArchiveDir $fileName

        $masterLines = (Get-Content $masterPath).Count
        $archiveLines = (Get-Content $archivePath).Count

        Write-Host ""
        Write-Host "[$fileName]" -ForegroundColor Yellow
        Write-Host "  Master: $masterLines lines"
        Write-Host "  Archive: $archiveLines lines"
        Write-Host "  Difference: $($masterLines - $archiveLines) lines"
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Identical:       $($Identical.Count)"
Write-Host "Changed:         $($Changed.Count)"
Write-Host "Only in master:  $($OnlyInMaster.Count)"
Write-Host "Only in archive: $($OnlyInArchive.Count)"
Write-Host ""

# Suggest manifest updates
if ($Changed.Count -gt 0 -or $OnlyInMaster.Count -gt 0 -or $OnlyInArchive.Count -gt 0) {
    Write-Host "Suggested manifest.yml updates:" -ForegroundColor Yellow
    Write-Host ""

    if ($Changed.Count -gt 0) {
        Write-Host "changed_files:" -ForegroundColor White
        $Changed | ForEach-Object { Write-Host "  - $_" }
    }

    if ($OnlyInArchive.Count -gt 0) {
        Write-Host ""
        Write-Host "unique_files:" -ForegroundColor White
        $OnlyInArchive | ForEach-Object { Write-Host "  - $_" }
    }

    if ($OnlyInMaster.Count -gt 0) {
        Write-Host ""
        Write-Host "excluded_files:" -ForegroundColor White
        $OnlyInMaster | ForEach-Object { Write-Host "  - $_" }
    }
}
