# Fix line endings in QMD files - convert to Unix LF format
param(
    [string]$Path = "P:/r-Projects/slides"
)

$courses = @("epin", "epol", "epol-uns", "fpub", "gpre", "lpfp", "teaa", "tepm")

foreach ($course in $courses) {
    $coursePath = Join-Path $Path $course
    if (Test-Path $coursePath) {
        $qmdFiles = Get-ChildItem -Path $coursePath -Filter "*.qmd" -Recurse -File
        foreach ($file in $qmdFiles) {
            $content = [System.IO.File]::ReadAllText($file.FullName)
            # Replace CRLF with LF, then any remaining CR with nothing
            $content = $content -replace "`r`n", "`n"
            $content = $content -replace "`r", ""
            # Write back with LF only (no BOM)
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
            Write-Host "Fixed: $($file.FullName)"
        }
    }
}
Write-Host "`nDone!"
