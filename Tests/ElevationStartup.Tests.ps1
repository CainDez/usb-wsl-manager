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

function Assert-True {
    param(
        [Parameter(Mandatory = $true)] [bool] $Condition,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$arguments = Get-ManagerScriptLaunchArguments -ScriptPath 'C:\Tools With Spaces\UsbWslManager.ps1'

Assert-Equal -Actual ($arguments -join '|') -Expected '-NoProfile|-ExecutionPolicy|Bypass|-WindowStyle|Hidden|-STA|-File|"C:\Tools With Spaces\UsbWslManager.ps1"' -Message 'Manager relaunch arguments should hide the console and preserve STA mode.'

$source = Get-Content -Raw $scriptPath
$elevationGateIndex = $source.IndexOf('if (-not (Test-IsAdministrator))')
$staGateIndex = $source.IndexOf("if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA')")

Assert-True -Condition ($elevationGateIndex -ge 0) -Message 'Startup should check for administrator rights.'
Assert-True -Condition ($source.IndexOf('Start-ManagerScript -ScriptPath $PSCommandPath -Elevated', $elevationGateIndex) -gt $elevationGateIndex) -Message 'Startup should relaunch the manager with administrator rights.'
Assert-True -Condition ($elevationGateIndex -lt $staGateIndex) -Message 'Administrator relaunch should happen before the STA relaunch gate.'

Write-Host 'ElevationStartup.Tests.ps1 passed'
