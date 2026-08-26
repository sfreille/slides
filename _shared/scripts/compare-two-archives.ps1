<#
.SYNOPSIS
    Compare two archive years

.PARAMETER Course
    Course folder name

.PARAMETER Year1
    First year (older)

.PARAMETER Year2
    Second year (newer)
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Course,

    [Parameter(Mandatory=$true)]
    [string]$Year1,

    [Parameter(Mandatory=$true)]
    [string]$Year2
)

$BaseDir = "P:/r-Projects/slides"
$Archive1 = Join-Path $BaseDir "$Course/_archive/$Year1"
$Archive2 = Join-Path $BaseDir "$Course/_archive/$Year2"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Comparing $Course $Year1 vs $Year2 archives" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Get file lists
$files1 = Get-ChildItem -Path $Archive1 -Filter "*.qmd" -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
$files2 = Get-ChildItem -Path $Archive2 -Filter "*.qmd" -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

if (-not $files1) { $files1 = @() }
if (-not $files2) { $files2 = @() }

Write-Host "$Year1 archive: $($files1.Count) files"
Write-Host "$Year2 archive: $($files2.Count) files"
Write-Host ""

# Compare common files
$common = $files1 | Where-Object { $_ -in $files2 }
$only1 = $files1 | Where-Object { $_ -notin $files2 }
$only2 = $files2 | Where-Object { $_ -notin $files1 }

Write-Host "=== FILES IN BOTH ===" -ForegroundColor Yellow
if ($common.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Gray
} else {
    foreach ($f in $common) {
        $path1 = Join-Path $Archive1 $f
        $path2 = Join-Path $Archive2 $f
        $hash1 = (Get-FileHash $path1 -Algorithm MD5).Hash
        $hash2 = (Get-FileHash $path2 -Algorithm MD5).Hash
        $lines1 = (Get-Content $path1).Count
        $lines2 = (Get-Content $path2).Count

        if ($hash1 -eq $hash2) {
            Write-Host "  $f - IDENTICAL ($lines1 lines)" -ForegroundColor Green
        } else {
            $diff = $lines2 - $lines1
            $sign = if ($diff -ge 0) { "+" } else { "" }
            Write-Host "  $f - CHANGED ($Year1`: $lines1, $Year2`: $lines2, $sign$diff lines)" -ForegroundColor Yellow
        }
    }
}
Write-Host ""

Write-Host "=== ONLY IN $Year1 ===" -ForegroundColor Blue
if ($only1.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Gray
} else {
    foreach ($f in $only1) {
        $path = Join-Path $Archive1 $f
        $lines = (Get-Content $path).Count
        Write-Host "  $f ($lines lines)"
    }
}
Write-Host ""

Write-Host "=== ONLY IN $Year2 ===" -ForegroundColor Magenta
if ($only2.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Gray
} else {
    foreach ($f in $only2) {
        $path = Join-Path $Archive2 $f
        $lines = (Get-Content $path).Count
        Write-Host "  $f ($lines lines)"
    }
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Common files:    $($common.Count)"
Write-Host "Only in $Year1`:   $($only1.Count)"
Write-Host "Only in $Year2`:   $($only2.Count)"
