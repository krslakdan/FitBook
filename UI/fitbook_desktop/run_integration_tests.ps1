# Pokreće integracione (UI) testove desktop aplikacije.
#
# Svaki fajl se pokreće zasebnom `flutter test` komandom jer Flutter na
# Windows desktopu može pokrenuti samo jednu instancu aplikacije po pozivu,
# pa `flutter test integration_test` javlja "Unable to start the app".
#
# Preduslov: backend mora biti pokrenut (docker compose up).

$ErrorActionPreference = 'Continue'
$files = Get-ChildItem -Path "$PSScriptRoot\integration_test" -Filter '*_test.dart' | Sort-Object Name

$results = @()
foreach ($file in $files) {
    Write-Host ""
    Write-Host ("=" * 70)
    Write-Host "  $($file.Name)"
    Write-Host ("=" * 70)

    Get-Process fitbook_desktop -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -like "*build\windows*" } |
        Stop-Process -Force -ErrorAction SilentlyContinue

    $output = & flutter test $file.FullName -d windows 2>&1
    $output | Select-String -Pattern '^\d\d:\d\d \+|Isteklo|Expected:|Actual:|Which:|Bad state|reason:' |
        ForEach-Object { Write-Host "  $_" }

    $summary = ($output | Select-String -Pattern 'All tests passed|Some tests failed' | Select-Object -Last 1)
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
