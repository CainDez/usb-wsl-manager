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

$deviceName = [string]::Concat(
    [char]0x82F1,
    [char]0x7279,
    [char]0x5C14,
    '(R) ',
    [char]0x65E0,
    [char]0x7EBF,
    ' Bluetooth(R)'
)

$utf8Text = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($deviceName))
$childScript = @"
`$bytes = [Convert]::FromBase64String('$utf8Text')
`$stream = [Console]::OpenStandardOutput()
`$stream.Write(`$bytes, 0, `$bytes.Length)
"@

try {
    $originalOutputEncoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = [Text.Encoding]::Default

    $result = Invoke-ProcessCommand -FilePath 'powershell.exe' -Arguments @(
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        $childScript
    )
} finally {
    [Console]::OutputEncoding = $originalOutputEncoding
}

Assert-Equal -Actual $result.StdOut -Expected $deviceName -Message 'Invoke-ProcessCommand should decode UTF-8 stdout without garbling device names.'
Assert-Equal -Actual $result.ExitCode -Expected 0 -Message 'Child process should exit successfully.'

Write-Host 'InvokeProcessCommand.Tests.ps1 passed'
