$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $repoRoot 'UsbWslManager.ps1'

$env:USB_WSL_MANAGER_TEST_IMPORT = '1'
. $scriptPath
Remove-Item Env:\USB_WSL_MANAGER_TEST_IMPORT -ErrorAction SilentlyContinue

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)] $Actual,
        [Parameter(Mandatory = $true)] $Expected,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message`r`nExpected: $Expected`r`nActual:   $Actual"
    }
}

$attempt = 0
$result = Wait-UsbDevicePresent -BusId '3-2' -MaxAttempts 3 -SleepMilliseconds 0 -DeviceProvider {
    $script:attempt++
    if ($script:attempt -eq 1) {
        return @(
            [pscustomobject]@{ BusId = '1-10'; State = 'Not shared' }
        )
    }

    return @(
        [pscustomobject]@{ BusId = '1-10'; State = 'Not shared' },
        [pscustomobject]@{ BusId = '3-2'; State = 'Not shared' }
    )
}

Assert-Equal -Actual $result -Expected $true -Message 'Wait should succeed once the detached bus id reappears.'
Assert-Equal -Actual $attempt -Expected 2 -Message 'Wait should retry after an initial list that is missing the detached device.'

$missingAttempt = 0
$missingResult = Wait-UsbDevicePresent -BusId '9-9' -MaxAttempts 2 -SleepMilliseconds 0 -DeviceProvider {
    $script:missingAttempt++
    return @(
        [pscustomobject]@{ BusId = '1-10'; State = 'Not shared' }
    )
}

Assert-Equal -Actual $missingResult -Expected $false -Message 'Wait should report false when the bus id does not return.'
Assert-Equal -Actual $missingAttempt -Expected 2 -Message 'Wait should stop after the configured attempt count.'

Write-Host 'DetachRefresh.Tests.ps1 passed'
