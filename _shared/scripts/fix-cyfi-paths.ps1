# Fix image paths in cyfi master QMD files
# Change ../../_shared to ../_shared

$files = Get-ChildItem 'P:\r-Projects\slides\cyfi\*.qmd'

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $newContent = $content -replace '\.\./\.\./(_shared)', '../$1'
    Set-Content $file.FullName $newContent -NoNewline
    Write-Host "Fixed: $($file.Name)"
}

Write-Host "`nAll paths fixed!"
