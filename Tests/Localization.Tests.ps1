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

Assert-Equal -Actual (Get-DefaultUiLanguage -CultureName 'zh-CN') -Expected 'zh-CN' -Message 'Chinese UI culture should select Chinese.'
Assert-Equal -Actual (Get-DefaultUiLanguage -CultureName 'zh-Hans') -Expected 'zh-CN' -Message 'Simplified Chinese UI culture should select Chinese.'
Assert-Equal -Actual (Get-DefaultUiLanguage -CultureName 'en-US') -Expected 'en-US' -Message 'English UI culture should select English.'
Assert-Equal -Actual (Get-DefaultUiLanguage -CultureName 'fr-FR') -Expected 'en-US' -Message 'Unsupported UI culture should fall back to English.'

Set-UiLanguage -Language 'en-US'
Assert-Equal -Actual (Get-UiText -Key 'Button.Attach') -Expected 'Connect to WSL' -Message 'English button text should resolve.'
Assert-Equal -Actual (Get-UiText -Key 'Log.Refreshed' -Values @(4)) -Expected 'Refreshed, found 4 USB devices.' -Message 'Formatted English text should resolve.'
Assert-Equal -Actual (Get-UiText -Key 'Missing.Key') -Expected 'Missing.Key' -Message 'Missing translation keys should fall back to the key name.'

Set-UiLanguage -Language 'xx-YY'
Assert-Equal -Actual (Get-UiText -Key 'Button.Refresh') -Expected 'Refresh' -Message 'Unsupported selected language should fall back to English.'

Write-Host 'Localization.Tests.ps1 passed'
