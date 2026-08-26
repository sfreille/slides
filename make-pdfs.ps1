# make-pdfs.ps1
# Run from slides/ root after quarto render.
# Converts every HTML slide deck in docs/ to a matching PDF using decktape.
#
# Usage:
#   ./make-pdfs.ps1              # all courses
#   ./make-pdfs.ps1 epol         # single course
#   ./make-pdfs.ps1 epol hear    # multiple courses

param([string[]]$Courses = @())

$docsRoot = Join-Path $PSScriptRoot "docs"

if ($Courses.Count -gt 0) {
    $htmlFiles = $Courses | ForEach-Object {
        Get-ChildItem -Path (Join-Path $docsRoot $_) -Filter "*.html" -ErrorAction SilentlyContinue
    }
} else {
    $htmlFiles = Get-ChildItem -Path $docsRoot -Recurse -Filter "*.html" |
        Where-Object { $_.DirectoryName -notmatch "_shared" }
}

$total = @($htmlFiles).Count
$i = 0
$errors = @()

foreach ($f in $htmlFiles) {
    $i++
    $pdfPath = $f.FullName -replace "\.html$", ".pdf"
    $fileUrl  = "file:///" + ($f.FullName -replace "\\", "/")

    Write-Host "[$i/$total] $($f.Directory.Name)/$($f.Name)" -ForegroundColor Cyan

    $extraArgs = if ($f.Name -eq "lect07-24.html") { @("--slides", "1-89") } else { @() }

    decktape reveal $fileUrl $pdfPath `
        --page-load-timeout 20000 `
        --buffer-timeout 5000 `
        --load-pause 500 `
        @extraArgs `
        2>&1 | Out-Null

    if ($LASTEXITCODE -ne 0) {
        $errors += "$($f.Directory.Name)/$($f.Name)"
        Write-Host "  FAILED" -ForegroundColor Red
    } else {
        Write-Host "  OK" -ForegroundColor Green
    }
}

Write-Host "`nDone: $($total - $errors.Count)/$total succeeded." -ForegroundColor Yellow
if ($errors.Count -gt 0) {
    Write-Host "Failed:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  $_" }
}
