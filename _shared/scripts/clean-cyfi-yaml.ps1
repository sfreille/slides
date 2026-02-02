# Clean cyfi QMD files to have simple YAML like hpae
# Pattern: title = unit name, subtitle = course name

$files = Get-ChildItem 'P:\r-Projects\slides\cyfi\*.qmd'

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # Extract current subtitle (which is the unit name)
    if ($content -match 'subtitle:\s*(.+?)[\r\n]') {
        $unitName = $matches[1].Trim()
    } else {
        Write-Host "WARNING: No subtitle found in $($file.Name)"
        continue
    }

    # Find the end of YAML front matter
    if ($content -match '(?s)^---\r?\n.*?\r?\n---\r?\n(.*)$') {
        $bodyContent = $matches[1]
    } else {
        Write-Host "WARNING: Could not parse YAML in $($file.Name)"
        continue
    }

    # Create new simple YAML
    $newYaml = @"
---
title: $unitName
subtitle: Comercio y Finanzas Internacionales
---

"@

    $newContent = $newYaml + $bodyContent
    Set-Content $file.FullName $newContent -NoNewline
    Write-Host "Cleaned: $($file.Name) -> title: $unitName"
}

Write-Host "`nAll files cleaned!"
