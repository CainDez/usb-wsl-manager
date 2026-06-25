$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$launcherPath = Join-Path $repoRoot 'Run-UsbWslManager.bat'
$launcher = Get-Content -Raw $launcherPath

function Assert-Matches {
    param(
        [Parameter(Mandatory = $true)] [string] $Text,
        [Parameter(Mandatory = $true)] [string] $Pattern,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-NotMatches {
    param(
        [Parameter(Mandatory = $true)] [string] $Text,
        [Parameter(Mandatory = $true)] [string] $Pattern,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    if ($Text -match $Pattern) {
        throw $Message
    }
}

Assert-Matches -Text $launcher -Pattern '(?im)^\s*start\s+""\s+powershell\.exe\b' -Message 'Launcher should start PowerShell asynchronously so the batch window can close.'
Assert-Matches -Text $launcher -Pattern '(?i)\s-WindowStyle\s+Hidden\b' -Message 'Launcher should hide the PowerShell console window.'
Assert-NotMatches -Text $launcher -Pattern '(?im)^\s*powershell\.exe\b' -Message 'Launcher should not run PowerShell synchronously in the batch window.'

Write-Host 'Launcher.Tests.ps1 passed'
