<#
.SYNOPSIS
    Batch render Quarto slides to HTML and PDF (via Decktape)

.DESCRIPTION
    Renders all QMD files in a course folder to HTML using Quarto,
    then converts to PDF using Decktape for better fidelity.

.PARAMETER Course
    Course folder name (e.g., "hpae", "cyfi")

.PARAMETER Year
    Optional year subfolder (e.g., "2025"). If not specified, renders main folder.

.PARAMETER Format
    Output format: "html", "pdf", or "both" (default: "both")

.PARAMETER Files
    Optional specific file(s) to render. If not specified, renders all QMD files.

.EXAMPLE
    .\render-slides.ps1 -Course hpae -Format both
    .\render-slides.ps1 -Course hpae -Year 2025 -Format html
    .\render-slides.ps1 -Course cyfi -Files "lect01.qmd","lect02.qmd"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Course,

    [string]$Year = "",

    [ValidateSet("html", "pdf", "both")]
    [string]$Format = "both",

    [string[]]$Files = @(),

    [switch]$Parallel,

    [int]$DecktapeDelay = 1000
)

# Configuration
$BaseDir = "P:/r-Projects/slides"
$DecktapePath = "decktape"

# Determine working directory
if ($Year) {
    $WorkDir = Join-Path $BaseDir "$Course/$Year"
} else {
    $WorkDir = Join-Path $BaseDir $Course
}

if (-not (Test-Path $WorkDir)) {
    Write-Error "Directory not found: $WorkDir"
    exit 1
}

# Get QMD files to render
if ($Files.Count -gt 0) {
    $QmdFiles = $Files | ForEach-Object { Join-Path $WorkDir $_ } | Where-Object { Test-Path $_ }
} else {
    $QmdFiles = Get-ChildItem -Path $WorkDir -Filter "*.qmd" -File | Select-Object -ExpandProperty FullName
}

if ($QmdFiles.Count -eq 0) {
    Write-Host "No QMD files found in $WorkDir" -ForegroundColor Yellow
    exit 0
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Batch Slide Renderer" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Course: $Course"
Write-Host "Directory: $WorkDir"
Write-Host "Files: $($QmdFiles.Count)"
Write-Host "Format: $Format"
Write-Host "=========================================" -ForegroundColor Cyan

# Function to render a single QMD file
function Render-QmdFile {
    param(
        [string]$QmdPath,
        [string]$OutputFormat
    )

    $FileName = [System.IO.Path]::GetFileNameWithoutExtension($QmdPath)
    $Dir = [System.IO.Path]::GetDirectoryName($QmdPath)
    $HtmlPath = Join-Path $Dir "$FileName.html"
    $PdfPath = Join-Path $Dir "$FileName.pdf"

    # Render to HTML
    if ($OutputFormat -eq "html" -or $OutputFormat -eq "both") {
        Write-Host "`n[$FileName] Rendering to HTML..." -ForegroundColor Yellow
        $startTime = Get-Date

        & quarto render $QmdPath --to revealjs 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

        if ($LASTEXITCODE -eq 0) {
            $elapsed = ((Get-Date) - $startTime).TotalSeconds
            Write-Host "[$FileName] HTML complete (${elapsed}s)" -ForegroundColor Green
        } else {
            Write-Host "[$FileName] HTML FAILED" -ForegroundColor Red
            return $false
        }
    }

    # Convert to PDF via Decktape
    if ($OutputFormat -eq "pdf" -or $OutputFormat -eq "both") {
        if (-not (Test-Path $HtmlPath)) {
            Write-Host "[$FileName] HTML file not found, skipping PDF" -ForegroundColor Yellow
            return $false
        }

        Write-Host "[$FileName] Converting to PDF via Decktape..." -ForegroundColor Yellow
        $startTime = Get-Date

        # Decktape command for RevealJS
        & $DecktapePath reveal --size 1500x900 --pause $DecktapeDelay $HtmlPath $PdfPath 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

        if ($LASTEXITCODE -eq 0 -and (Test-Path $PdfPath)) {
            $elapsed = ((Get-Date) - $startTime).TotalSeconds
            $pdfSize = [math]::Round((Get-Item $PdfPath).Length / 1MB, 2)
            Write-Host "[$FileName] PDF complete (${elapsed}s, ${pdfSize}MB)" -ForegroundColor Green
        } else {
            Write-Host "[$FileName] PDF FAILED" -ForegroundColor Red
            return $false
        }
    }

    return $true
}

# Process files
$totalStart = Get-Date
$successCount = 0
$failCount = 0

foreach ($qmd in $QmdFiles) {
    $result = Render-QmdFile -QmdPath $qmd -OutputFormat $Format
    if ($result) {
        $successCount++
    } else {
        $failCount++
    }
}

# Summary
$totalElapsed = ((Get-Date) - $totalStart).TotalSeconds
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "Rendering Complete" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host "Total time: $([math]::Round($totalElapsed, 1))s"
Write-Host "=========================================" -ForegroundColor Cyan
