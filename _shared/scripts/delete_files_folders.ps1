# Delete all _files folders except in electoral-congruence and conferences
$folders = Get-ChildItem -Path "P:/r-Projects/slides" -Filter "*_files" -Directory -Recurse

$deleted = 0
foreach ($f in $folders) {
    if ($f.FullName -notmatch "electoral-congruence|conferences") {
        Remove-Item -Path $f.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Deleted: $($f.FullName)"
        $deleted++
    }
}
Write-Host "`nDeleted $deleted folders"
