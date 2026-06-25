$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $repoRoot 'UsbWslManager.ps1'

$env:USB_WSL_MANAGER_TEST_IMPORT = '1'
. $scriptPath
Remove-Item Env:\USB_WSL_MANAGER_TEST_IMPORT -ErrorAction SilentlyContinue
Set-UiLanguage -Language 'zh-CN'

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

$notSharedDevice = [pscustomobject]@{
    BusId  = '3-2'
    VidPid = '062a:38cf'
    Device = 'USB input device'
    State  = 'Not shared'
}

$notSharedPlan = Get-ConnectUsbDevicePlan -Device $notSharedDevice
$bindActionName = New-Object string (,[char[]]@([char]0x5171, [char]0x4EAB, [char]0x8BBE, [char]0x5907))
$attachActionName = (New-Object string (,[char[]]@([char]0x8FDE, [char]0x63A5, [char]0x5230))) + ' WSL'

Assert-Equal -Actual $notSharedPlan.Count -Expected 2 -Message 'Not shared devices should be bound before attach.'
Assert-Equal -Actual $notSharedPlan[0].ActionName -Expected $bindActionName -Message 'First step should bind the device.'
Assert-Equal -Actual ($notSharedPlan[0].Arguments -join ' ') -Expected 'bind --busid 3-2' -Message 'First step should run usbipd bind.'
Assert-Equal -Actual $notSharedPlan[0].RequiresAdmin -Expected $true -Message 'Bind step should be marked as requiring admin.'
Assert-Equal -Actual $notSharedPlan[1].ActionName -Expected $attachActionName -Message 'Second step should attach the device.'
Assert-Equal -Actual ($notSharedPlan[1].Arguments -join ' ') -Expected 'attach --wsl --busid 3-2' -Message 'Second step should run usbipd attach.'

$sharedDevice = [pscustomobject]@{
    BusId  = '1-10'
    VidPid = '8087:0aaa'
    Device = 'Bluetooth'
    State  = 'Shared'
}

$sharedPlan = Get-ConnectUsbDevicePlan -Device $sharedDevice

Assert-Equal -Actual $sharedPlan.Count -Expected 1 -Message 'Already shared devices should only attach.'
Assert-Equal -Actual ($sharedPlan[0].Arguments -join ' ') -Expected 'attach --wsl --busid 1-10' -Message 'Shared devices should run attach directly.'

Write-Host 'ConnectWorkflow.Tests.ps1 passed'
