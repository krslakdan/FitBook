# Pokreće integracione (UI) testove mobilne aplikacije na Android emulatoru.
#
# Svaki fajl se pokreće zasebnom `flutter test` komandom jer Flutter može
# pokrenuti samo jednu instancu aplikacije po pozivu.
#
# Preduslovi:
#   - backend pokrenut (docker compose up)
#   - emulator pokrenut i sa najmanje ~1 GB slobodnog prostora

param([string]$Device = 'emulator-5554')

$ErrorActionPreference = 'Continue'
$files = Get-ChildItem -Path "$PSScriptRoot\integration_test" -Filter '*_test.dart' | Sort-Object Name

$results = @()
foreach ($file in $files) {
    Write-Host ""
    Write-Host ("=" * 70)
    Write-Host "  $($file.Name)"
    Write-Host ("=" * 70)

    $output = & flutter test $file.FullName -d $Device 2>&1
    $output | Select-String -Pattern '^\d\d:\d\d \+|Isteklo|Expected:|Actual:|Which:|Bad state|setState\(\) or markNeedsBuild' |
        ForEach-Object { Write-Host "  $_" }

    $passed = ($output | Select-String -Pattern 'All tests passed').Count -gt 0
    $counts = ($output | Select-String -Pattern '^\d\d:\d\d \+\d+' | Select-Object -Last 1)

    $results += [pscustomobject]@{
        Fajl    = $file.Name
        Prosao  = $passed
        Sazetak = if ($counts) { ($counts -replace '.*(\+\d+( -\d+)?).*', '$1') } else { 'n/a' }
    }
}

Write-Host ""
Write-Host ("=" * 70)
Write-Host "  UKUPNO"
Write-Host ("=" * 70)
$results | Format-Table -AutoSize
if ($results | Where-Object { -not $_.Prosao }) { exit 1 }
