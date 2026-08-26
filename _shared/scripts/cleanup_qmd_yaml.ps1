<#
.SYNOPSIS
    Clean up QMD YAML headers to minimal preamble

.DESCRIPTION
    Removes redundant YAML settings from QMD files, keeping only title and subtitle.
    All other settings are inherited from _quarto.yml and _metadata.yml.

.PARAMETER Path
    Directory containing QMD files to clean

.EXAMPLE
    .\cleanup_qmd_yaml.ps1 -Path "P:/r-Projects/slides/hpae/2025"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

if (-not (Test-Path $Path)) {
    Write-Error "Directory not found: $Path"
    exit 1
}

$files = Get-ChildItem -Path $Path -Filter "*.qmd" -File

Write-Host "Cleaning QMD files in: $Path" -ForegroundColor Cyan
Write-Host "Found $($files.Count) QMD files" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8

    # Extract title
    $title = ""
    if ($content -match "(?m)^title:\s*(.+?)$") {
        $title = $Matches[1].Trim()
    }

    # Extract subtitle
    $subtitle = ""
    if ($content -match "(?m)^subtitle:\s*(.+?)$") {
        $subtitle = $Matches[1].Trim()
    }

    # Extract body (everything after second ---)
    $parts = $content -split "---", 3
    if ($parts.Count -ge 3) {
        $body = $parts[2]

        # Build new content with minimal YAML
        $newYaml = "---`ntitle: $title`n"
        if ($subtitle) {
            $newYaml += "subtitle: $subtitle`n"
        }
        $newYaml += "---"

        $newContent = $newYaml + $body

        # Write back with UTF8 encoding (no BOM)
        [System.IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.UTF8Encoding]::new($false))

        Write-Host "Cleaned: $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "Skipped (no YAML): $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Cleanup complete!" -ForegroundColor Cyan
