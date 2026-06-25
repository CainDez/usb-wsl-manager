Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Translations = @{
    'en-US' = @{
        'App.Title' = 'USB to WSL Manager'
        'Label.Language' = 'Language:'
        'Language.English' = 'English'
        'Language.Chinese' = '中文'
        'Button.Install' = 'Install usbipd-win'
        'Button.Refresh' = 'Refresh'
        'Button.Bind' = 'Share / bind'
        'Button.Unbind' = 'Unshare'
        'Button.Attach' = 'Connect to WSL'
        'Button.Detach' = 'Disconnect from WSL'
        'Column.BusId' = 'BUSID'
        'Column.VidPid' = 'VID:PID'
        'Column.Device' = 'Device'
        'Column.State' = 'Status'
        'Permission.Admin' = 'Administrator'
        'Permission.User' = 'Standard user'
        'Status.Text' = 'usbipd: {0}    Current permission: {1}    Tip: The tool requests administrator permission at startup for bind/unbind/install.'
        'Usbipd.NotInstalled' = 'Not installed'
        'Usbipd.Installed' = 'Installed'
        'Error.UsbipdMissing' = 'usbipd was not found. Please click "Install usbipd-win" first.'
        'Error.UsbipdListFailed' = 'usbipd list failed: {0}'
        'Error.ActionFailed' = '{0} failed: {1}'
        'Log.Execute' = 'Run: usbipd {0}'
        'Log.ActionDone' = '{0} completed.'
        'Log.ActionFailed' = '{0} failed: {1}'
        'Log.Refreshed' = 'Refreshed, found {0} USB devices.'
        'Log.RefreshFailed' = 'Refresh failed: {0}'
        'Log.WaitDevice' = 'Waiting for device {0} to reappear in the list.'
        'Dialog.RefreshFailed' = 'Refresh failed'
        'Dialog.NoSelectionTitle' = 'No device selected'
        'Dialog.NoSelectionMessage' = 'Please select a USB device first.'
        'Action.Bind' = 'Share device'
        'Action.Unbind' = 'Unshare device'
        'Action.Attach' = 'Connect to WSL'
        'Action.Detach' = 'Disconnect from WSL'
        'Action.Install' = 'Install usbipd-win'
        'Install.WingetMissing' = 'winget was not found. Please install Windows App Installer first, or install usbipd-win manually.'
        'Install.Start' = 'Preparing to install usbipd-win with winget.'
        'Install.Done' = 'The install command was started. If installation just finished, close and reopen this tool.'
        'Install.Failed' = 'Install failed: {0}'
        'Elevated.CommandDone' = 'The command was executed in an administrator window.'
        'Help.Text' = @'
WSL connection and permission notes

Windows:
1. On first use, click "Install usbipd-win" if needed. After installation, run once: wsl --update, then wsl --shutdown.
2. Click "Refresh", then select a USB device.
3. Click "Connect to WSL"; if the device is not shared yet, the tool automatically runs "Share / bind" first.
4. After rebooting Windows, restarting WSL, or unplugging/replugging the device, usually only "Connect to WSL" is needed; bind is normally preserved.
5. When finished, click "Disconnect from WSL". If you no longer want to allow sharing, click "Unshare".

WSL:
1. Check that the device is visible: lsusb
2. If lsusb can see it but your software cannot, test first: sudo your-command
3. If sudo works, it is usually a permission issue.
'@
    }
    'zh-CN' = @{
        'App.Title' = 'USB to WSL Manager'
        'Label.Language' = '语言:'
        'Language.English' = 'English'
        'Language.Chinese' = '中文'
        'Button.Install' = '安装 usbipd-win'
        'Button.Refresh' = '刷新列表'
        'Button.Bind' = '共享 / bind'
        'Button.Unbind' = '取消共享'
        'Button.Attach' = '连接到 WSL'
        'Button.Detach' = '从 WSL 断开'
        'Column.BusId' = 'BUSID'
        'Column.VidPid' = 'VID:PID'
        'Column.Device' = '设备'
        'Column.State' = '状态'
        'Permission.Admin' = '管理员'
        'Permission.User' = '普通用户'
        'Status.Text' = 'usbipd: {0}    当前权限: {1}    提示: 工具启动时会请求管理员权限，便于直接执行 bind/unbind/安装。'
        'Usbipd.NotInstalled' = '未安装'
        'Usbipd.Installed' = '已安装'
        'Error.UsbipdMissing' = '未找到 usbipd。请先点击“安装 usbipd-win”。'
        'Error.UsbipdListFailed' = 'usbipd list 失败：{0}'
        'Error.ActionFailed' = '{0} 失败：{1}'
        'Log.Execute' = '执行：usbipd {0}'
        'Log.ActionDone' = '{0} 完成。'
        'Log.ActionFailed' = '{0} 失败：{1}'
        'Log.Refreshed' = '已刷新，找到 {0} 个 USB 设备。'
        'Log.RefreshFailed' = '刷新失败：{0}'
        'Log.WaitDevice' = '等待设备 {0} 重新出现在列表中。'
        'Dialog.RefreshFailed' = '刷新失败'
        'Dialog.NoSelectionTitle' = '未选择设备'
        'Dialog.NoSelectionMessage' = '请先在列表中选择一个 USB 设备。'
        'Action.Bind' = '共享设备'
        'Action.Unbind' = '取消共享'
        'Action.Attach' = '连接到 WSL'
        'Action.Detach' = '从 WSL 断开'
        'Action.Install' = '安装 usbipd-win'
        'Install.WingetMissing' = '未找到 winget。请先安装 Windows App Installer，或手动安装 usbipd-win。'
        'Install.Start' = '准备通过 winget 安装 usbipd-win。'
        'Install.Done' = '安装命令已执行。若刚安装完成，请关闭并重新打开本工具。'
        'Install.Failed' = '安装失败：{0}'
        'Elevated.CommandDone' = '已通过管理员窗口执行命令。'
        'Help.Text' = @'
WSL 连接与权限说明

Windows 侧：
1. 首次使用可点击“安装 usbipd-win”。安装后建议执行一次：wsl --update，然后 wsl --shutdown。
2. 点击“刷新列表”，选择 USB 设备。
3. 点击“连接到 WSL”；如果设备尚未共享，工具会先自动执行“共享 / bind”。
4. 重启电脑或 WSL 后，通常只需要重新“连接到 WSL”；bind 一般会保留。
5. 用完后点击“从 WSL 断开”。如果不想再允许共享，点击“取消共享”。

WSL 侧：
1. 确认设备可见：lsusb
2. 如果 lsusb 能看到，但软件读不到，先测试：sudo 你的软件命令
3. sudo 能读到，多半是权限问题。
'@
    }
}

function Get-DefaultUiLanguage {
    param([string] $CultureName = [Globalization.CultureInfo]::CurrentUICulture.Name)

    if ($CultureName -like 'zh*') { return 'zh-CN' }
    return 'en-US'
}

$script:UiLanguage = Get-DefaultUiLanguage

function Set-UiLanguage {
    param([Parameter(Mandatory = $true)][string] $Language)

    if (-not $script:Translations.ContainsKey($Language)) {
        $Language = 'en-US'
    }

    $script:UiLanguage = $Language
}

function Get-UiText {
    param(
        [Parameter(Mandatory = $true)][string] $Key,
        [object[]] $Values = @()
    )

    $language = $script:UiLanguage
    if (-not $script:Translations.ContainsKey($language)) {
        $language = 'en-US'
    }

    if ($script:Translations[$language].ContainsKey($Key)) {
        $text = $script:Translations[$language][$Key]
    } elseif ($script:Translations['en-US'].ContainsKey($Key)) {
        $text = $script:Translations['en-US'][$Key]
    } else {
        $text = $Key
    }

    if ($Values.Count -gt 0) {
        return [string]::Format($text, $Values)
    }

    return $text
}

function ConvertTo-WindowsLineEnding {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Text
    )

    return (($Text -replace "`r`n", "`n") -replace "`r", "`n") -replace "`n", "`r`n"
}

function ConvertFrom-UsbipdListOutput {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Text
    )

    $devices = @()

    foreach ($line in ($Text -split "`r?`n")) {
        $trimmed = $line.TrimEnd()
        if ([string]::IsNullOrWhiteSpace($trimmed)) {
            continue
        }

        $match = [regex]::Match(
            $trimmed,
            '^(?<busid>\S+)\s+(?<vidpid>[0-9A-Fa-f]{4}:[0-9A-Fa-f]{4})\s+(?<device>.+?)\s{2,}(?<state>.+)$'
        )

        if (-not $match.Success) {
            continue
        }

        $devices += [pscustomobject]@{
            BusId  = $match.Groups['busid'].Value
            VidPid = $match.Groups['vidpid'].Value.ToLowerInvariant()
            Device = $match.Groups['device'].Value.Trim()
            State  = $match.Groups['state'].Value.Trim()
        }
    }

    return @($devices)
}

function Test-CommandAvailable {
    param([Parameter(Mandatory = $true)][string] $Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-ManagerScriptLaunchArguments {
    param([Parameter(Mandatory = $true)][string] $ScriptPath)

    return @(
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-STA',
        '-File',
        "`"$ScriptPath`""
    )
}

function Start-ManagerScript {
    param(
        [Parameter(Mandatory = $true)][string] $ScriptPath,
        [switch] $Elevated
    )

    $startArgs = @{
        FilePath     = 'powershell.exe'
        WindowStyle  = 'Hidden'
        ArgumentList = Get-ManagerScriptLaunchArguments -ScriptPath $ScriptPath
    }

    if ($Elevated) {
        $startArgs.Verb = 'RunAs'
    }

    Start-Process @startArgs
}

function Join-CommandArguments {
    param([Parameter(Mandatory = $true)][string[]] $Arguments)

    return ($Arguments | ForEach-Object {
        if ($_ -match '[\s"]') {
            '"' + ($_.Replace('"', '\"')) + '"'
        } else {
            $_
        }
    }) -join ' '
}

function Join-PowerShellCommandArguments {
    param([Parameter(Mandatory = $true)][string[]] $Arguments)

    return ($Arguments | ForEach-Object {
        "'" + ($_.Replace("'", "''")) + "'"
    }) -join ' '
}

function Invoke-ProcessCommand {
    param(
        [Parameter(Mandatory = $true)][string] $FilePath,
        [Parameter(Mandatory = $true)][string[]] $Arguments
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.Arguments = Join-CommandArguments -Arguments $Arguments
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [Text.Encoding]::UTF8
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return [pscustomobject]@{
        ExitCode = $process.ExitCode
        StdOut   = $stdout.TrimEnd()
        StdErr   = $stderr.TrimEnd()
    }
}

function Start-ElevatedPowerShellCommand {
    param(
        [Parameter(Mandatory = $true)][string] $Command,
        [switch] $Pause
    )

    $script = @"
`$ErrorActionPreference = 'Continue'
$Command
`$exitCode = `$LASTEXITCODE
Write-Host ''
if (`$null -ne `$exitCode -and `$exitCode -ne 0) {
    Write-Host "Command exited with code `$exitCode" -ForegroundColor Yellow
}
"@

    if ($Pause) {
        $script += "`r`nRead-Host '按 Enter 关闭此窗口'"
    }

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script))
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -Wait -ArgumentList @(
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-EncodedCommand',
        $encoded
    )
}

function Get-UsbipdVersionText {
    if (-not (Test-CommandAvailable -Name 'usbipd')) {
        return Get-UiText -Key 'Usbipd.NotInstalled'
    }

    try {
        $result = Invoke-ProcessCommand -FilePath 'usbipd' -Arguments @('--version')
        if ($result.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($result.StdOut)) {
            return $result.StdOut
        }
    } catch {
    }

    return Get-UiText -Key 'Usbipd.Installed'
}

function Get-UsbipdDevices {
    if (-not (Test-CommandAvailable -Name 'usbipd')) {
        throw (Get-UiText -Key 'Error.UsbipdMissing')
    }

    $result = Invoke-ProcessCommand -FilePath 'usbipd' -Arguments @('list')
    if ($result.ExitCode -ne 0) {
        $message = $result.StdErr
        if ([string]::IsNullOrWhiteSpace($message)) {
            $message = $result.StdOut
        }
        throw (Get-UiText -Key 'Error.UsbipdListFailed' -Values @($message))
    }

    return ConvertFrom-UsbipdListOutput -Text $result.StdOut
}

function Wait-UsbDevicePresent {
    param(
        [Parameter(Mandatory = $true)][string] $BusId,
        [int] $MaxAttempts = 8,
        [int] $SleepMilliseconds = 250,
        [scriptblock] $DeviceProvider = { Get-UsbipdDevices }
    )

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            $devices = @(& $DeviceProvider)
            if ($devices | Where-Object { $_.BusId -eq $BusId }) {
                return $true
            }
        } catch {
            if ($attempt -eq $MaxAttempts) {
                return $false
            }
        }

        if ($attempt -lt $MaxAttempts -and $SleepMilliseconds -gt 0) {
            Start-Sleep -Milliseconds $SleepMilliseconds
        }
    }

    return $false
}

function Invoke-UsbipdAction {
    param(
        [Parameter(Mandatory = $true)][string[]] $Arguments,
        [switch] $RequiresAdmin
    )

    if (-not (Test-CommandAvailable -Name 'usbipd')) {
        throw '未找到 usbipd。请先点击“安装 usbipd-win”。'
    }

    if ($RequiresAdmin -and -not (Test-IsAdministrator)) {
        $argText = Join-PowerShellCommandArguments -Arguments $Arguments
        Start-ElevatedPowerShellCommand -Command "usbipd $argText" -Pause
        return [pscustomobject]@{
            ExitCode = 0
            StdOut   = '已通过管理员窗口执行命令。'
            StdErr   = ''
        }
    }

    return Invoke-ProcessCommand -FilePath 'usbipd' -Arguments $Arguments
}

function Get-ConnectUsbDevicePlan {
    param([Parameter(Mandatory = $true)] $Device)

    $steps = @()

    if ($Device.State -eq 'Not shared') {
        $steps += [pscustomobject]@{
            ActionName    = Get-UiText -Key 'Action.Bind'
            Arguments     = @('bind', '--busid', $Device.BusId)
            RequiresAdmin = $true
        }
    }

    $steps += [pscustomobject]@{
        ActionName    = Get-UiText -Key 'Action.Attach'
        Arguments     = @('attach', '--wsl', '--busid', $Device.BusId)
        RequiresAdmin = $false
    }

    return ,@($steps)
}

if ($env:USB_WSL_MANAGER_TEST_IMPORT -eq '1') {
    return
}

if (-not (Test-IsAdministrator)) {
    Start-ManagerScript -ScriptPath $PSCommandPath -Elevated
    exit
}

if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    Start-ManagerScript -ScriptPath $PSCommandPath
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$font = New-Object System.Drawing.Font('Microsoft YaHei UI', 9)
$monoFont = New-Object System.Drawing.Font('Consolas', 9)

$form = New-Object System.Windows.Forms.Form
$form.Text = 'USB to WSL Manager'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(1040, 760)
$form.MinimumSize = New-Object System.Drawing.Size(880, 640)
$form.Font = $font

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.AutoSize = $false
$statusLabel.Location = New-Object System.Drawing.Point(12, 12)
$statusLabel.Size = New-Object System.Drawing.Size(760, 28)
$statusLabel.Anchor = 'Top,Left,Right'
$form.Controls.Add($statusLabel)

$languageLabel = New-Object System.Windows.Forms.Label
$languageLabel.AutoSize = $false
$languageLabel.Location = New-Object System.Drawing.Point(790, 16)
$languageLabel.Size = New-Object System.Drawing.Size(80, 20)
$languageLabel.Anchor = 'Top,Right'
$form.Controls.Add($languageLabel)

$languageComboBox = New-Object System.Windows.Forms.ComboBox
$languageComboBox.Location = New-Object System.Drawing.Point(872, 12)
$languageComboBox.Size = New-Object System.Drawing.Size(130, 24)
$languageComboBox.Anchor = 'Top,Right'
$languageComboBox.DropDownStyle = 'DropDownList'
$form.Controls.Add($languageComboBox)

$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = '安装 usbipd-win'
$installButton.Location = New-Object System.Drawing.Point(12, 44)
$installButton.Size = New-Object System.Drawing.Size(130, 32)
$form.Controls.Add($installButton)

$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Text = '刷新列表'
$refreshButton.Location = New-Object System.Drawing.Point(152, 44)
$refreshButton.Size = New-Object System.Drawing.Size(100, 32)
$form.Controls.Add($refreshButton)

$bindButton = New-Object System.Windows.Forms.Button
$bindButton.Text = '共享 / bind'
$bindButton.Location = New-Object System.Drawing.Point(262, 44)
$bindButton.Size = New-Object System.Drawing.Size(110, 32)
$form.Controls.Add($bindButton)

$unbindButton = New-Object System.Windows.Forms.Button
$unbindButton.Text = '取消共享'
$unbindButton.Location = New-Object System.Drawing.Point(382, 44)
$unbindButton.Size = New-Object System.Drawing.Size(110, 32)
$form.Controls.Add($unbindButton)

$attachButton = New-Object System.Windows.Forms.Button
$attachButton.Text = '连接到 WSL'
$attachButton.Location = New-Object System.Drawing.Point(502, 44)
$attachButton.Size = New-Object System.Drawing.Size(120, 32)
$form.Controls.Add($attachButton)

$detachButton = New-Object System.Windows.Forms.Button
$detachButton.Text = '从 WSL 断开'
$detachButton.Location = New-Object System.Drawing.Point(632, 44)
$detachButton.Size = New-Object System.Drawing.Size(120, 32)
$form.Controls.Add($detachButton)

$listView = New-Object System.Windows.Forms.ListView
$listView.Location = New-Object System.Drawing.Point(12, 86)
$listView.Size = New-Object System.Drawing.Size(998, 285)
$listView.Anchor = 'Top,Left,Right'
$listView.View = 'Details'
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.MultiSelect = $false
[void]$listView.Columns.Add('BUSID', 90)
[void]$listView.Columns.Add('VID:PID', 110)
[void]$listView.Columns.Add('设备', 590)
[void]$listView.Columns.Add('状态', 180)
$form.Controls.Add($listView)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point(12, 382)
$logBox.Size = New-Object System.Drawing.Size(998, 120)
$logBox.Anchor = 'Top,Left,Right'
$logBox.Multiline = $true
$logBox.ScrollBars = 'Vertical'
$logBox.ReadOnly = $true
$logBox.Font = $monoFont
$form.Controls.Add($logBox)

$helpBox = New-Object System.Windows.Forms.TextBox
$helpBox.Location = New-Object System.Drawing.Point(12, 514)
$helpBox.Size = New-Object System.Drawing.Size(998, 195)
$helpBox.Anchor = 'Top,Bottom,Left,Right'
$helpBox.Multiline = $true
$helpBox.ScrollBars = 'Vertical'
$helpBox.ReadOnly = $true
$helpBox.Font = $monoFont
$helpBox.Text = @'
WSL 连接与权限说明

Windows 侧：
1. 首次使用可点击“安装 usbipd-win”。安装后建议执行一次：wsl --update，然后 wsl --shutdown。
2. 点击“刷新列表”，选择 USB 设备。
3. 点击“连接到 WSL”；如果设备尚未共享，工具会先自动执行“共享 / bind”。
4. 重启电脑或 WSL 后，通常只需要重新“连接到 WSL”；bind 一般会保留。
5. 用完后点击“从 WSL 断开”。如果不想再允许共享，点击“取消共享”。

WSL 侧：
1. 确认设备可见：lsusb
2. 如果 lsusb 能看到，但软件读不到，先测试：sudo 你的软件命令
3. sudo 能读到，多半是权限问题。

串口设备：
  ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
  sudo usermod -aG dialout $USER
  退出 WSL 后重新进入，或执行：newgrp dialout

libusb/raw USB 设备：
  lsusb                       # 找到 VID:PID，例如 2341:0043
  sudo tee /etc/udev/rules.d/99-usb-wsl.rules <<'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="2341", ATTR{idProduct}=="0043", MODE="0666", TAG+="uaccess"
EOF
  sudo udevadm control --reload-rules
  sudo udevadm trigger

如果 udev 不工作，可在 /etc/wsl.conf 加：
  [boot]
  systemd=true
然后在 Windows PowerShell 执行：wsl --shutdown
'@
$form.Controls.Add($helpBox)

function Add-Log {
    param([Parameter(Mandatory = $true)][string] $Message)
    $timestamp = Get-Date -Format 'HH:mm:ss'
    $logBox.AppendText("[$timestamp] $Message`r`n")
}

function Update-Status {
    $versionText = Get-UsbipdVersionText
    $adminText = if (Test-IsAdministrator) { Get-UiText -Key 'Permission.Admin' } else { Get-UiText -Key 'Permission.User' }
    $statusLabel.Text = Get-UiText -Key 'Status.Text' -Values @($versionText, $adminText)
}

function Apply-UiLanguage {
    $script:IsApplyingLanguage = $true
    try {
        $form.Text = Get-UiText -Key 'App.Title'
        $languageLabel.Text = Get-UiText -Key 'Label.Language'
        $installButton.Text = Get-UiText -Key 'Button.Install'
        $refreshButton.Text = Get-UiText -Key 'Button.Refresh'
        $bindButton.Text = Get-UiText -Key 'Button.Bind'
        $unbindButton.Text = Get-UiText -Key 'Button.Unbind'
        $attachButton.Text = Get-UiText -Key 'Button.Attach'
        $detachButton.Text = Get-UiText -Key 'Button.Detach'
        $listView.Columns[0].Text = Get-UiText -Key 'Column.BusId'
        $listView.Columns[1].Text = Get-UiText -Key 'Column.VidPid'
        $listView.Columns[2].Text = Get-UiText -Key 'Column.Device'
        $listView.Columns[3].Text = Get-UiText -Key 'Column.State'
        $helpBox.Text = ConvertTo-WindowsLineEnding -Text (Get-UiText -Key 'Help.Text')

        $languageComboBox.Items.Clear()
        [void]$languageComboBox.Items.Add((Get-UiText -Key 'Language.Chinese'))
        [void]$languageComboBox.Items.Add((Get-UiText -Key 'Language.English'))
        $languageComboBox.SelectedIndex = if ($script:UiLanguage -eq 'zh-CN') { 0 } else { 1 }

        Update-Status
    } finally {
        $script:IsApplyingLanguage = $false
    }
}

function Refresh-UsbList {
    try {
        Update-Status
        $listView.BeginUpdate()
        $listView.Items.Clear()

        $devices = Get-UsbipdDevices
        foreach ($device in $devices) {
            $item = New-Object System.Windows.Forms.ListViewItem($device.BusId)
            [void]$item.SubItems.Add($device.VidPid)
            [void]$item.SubItems.Add($device.Device)
            [void]$item.SubItems.Add($device.State)
            $item.Tag = $device
            [void]$listView.Items.Add($item)
        }

        Add-Log (Get-UiText -Key 'Log.Refreshed' -Values @($devices.Count))
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (Get-UiText -Key 'Dialog.RefreshFailed'), 'OK', 'Warning') | Out-Null
        Add-Log (Get-UiText -Key 'Log.RefreshFailed' -Values @($_.Exception.Message))
    } finally {
        $listView.EndUpdate()
    }
}

function Get-SelectedUsbDevice {
    if ($listView.SelectedItems.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show((Get-UiText -Key 'Dialog.NoSelectionMessage'), (Get-UiText -Key 'Dialog.NoSelectionTitle'), 'OK', 'Information') | Out-Null
        return $null
    }

    return $listView.SelectedItems[0].Tag
}

function Invoke-SelectedDeviceAction {
    param(
        [Parameter(Mandatory = $true)][string] $ActionName,
        [Parameter(Mandatory = $true)][string[]] $Arguments,
        [switch] $RequiresAdmin,
        [string] $WaitForBusIdBeforeRefresh
    )

    try {
        Add-Log (Get-UiText -Key 'Log.Execute' -Values @((Join-CommandArguments -Arguments $Arguments)))
        $result = Invoke-UsbipdAction -Arguments $Arguments -RequiresAdmin:$RequiresAdmin

        if ($result.ExitCode -eq 0) {
            if (-not [string]::IsNullOrWhiteSpace($result.StdOut)) {
                Add-Log $result.StdOut
            }
            Add-Log (Get-UiText -Key 'Log.ActionDone' -Values @($ActionName))
            if (-not [string]::IsNullOrWhiteSpace($WaitForBusIdBeforeRefresh)) {
                Add-Log (Get-UiText -Key 'Log.WaitDevice' -Values @($WaitForBusIdBeforeRefresh))
                [void](Wait-UsbDevicePresent -BusId $WaitForBusIdBeforeRefresh)
            }
            Refresh-UsbList
            return
        }

        $message = $result.StdErr
        if ([string]::IsNullOrWhiteSpace($message)) {
            $message = $result.StdOut
        }
        throw (Get-UiText -Key 'Error.ActionFailed' -Values @($ActionName, $message))
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, $ActionName, 'OK', 'Warning') | Out-Null
        Add-Log (Get-UiText -Key 'Log.ActionFailed' -Values @($ActionName, $_.Exception.Message))
    }
}

function Invoke-SelectedDeviceActionPlan {
    param(
        [Parameter(Mandatory = $true)] [object[]] $Steps
    )

    try {
        foreach ($step in $Steps) {
            Add-Log (Get-UiText -Key 'Log.Execute' -Values @((Join-CommandArguments -Arguments $step.Arguments)))
            $result = Invoke-UsbipdAction -Arguments $step.Arguments -RequiresAdmin:$step.RequiresAdmin

            if ($result.ExitCode -ne 0) {
                $message = $result.StdErr
                if ([string]::IsNullOrWhiteSpace($message)) {
                    $message = $result.StdOut
                }
                throw (Get-UiText -Key 'Error.ActionFailed' -Values @($step.ActionName, $message))
            }

            if (-not [string]::IsNullOrWhiteSpace($result.StdOut)) {
                Add-Log $result.StdOut
            }
            Add-Log (Get-UiText -Key 'Log.ActionDone' -Values @($step.ActionName))
        }

        Refresh-UsbList
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (Get-UiText -Key 'Action.Attach'), 'OK', 'Warning') | Out-Null
        Add-Log (Get-UiText -Key 'Log.ActionFailed' -Values @((Get-UiText -Key 'Action.Attach'), $_.Exception.Message))
    }
}

$installButton.Add_Click({
    try {
        if (-not (Test-CommandAvailable -Name 'winget')) {
            throw (Get-UiText -Key 'Install.WingetMissing')
        }

        Add-Log (Get-UiText -Key 'Install.Start')
        Start-ElevatedPowerShellCommand -Command 'winget install --interactive --exact dorssel.usbipd-win' -Pause
        Add-Log (Get-UiText -Key 'Install.Done')
        Update-Status
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (Get-UiText -Key 'Action.Install'), 'OK', 'Warning') | Out-Null
        Add-Log (Get-UiText -Key 'Install.Failed' -Values @($_.Exception.Message))
    }
})

$refreshButton.Add_Click({ Refresh-UsbList })

$languageComboBox.Add_SelectedIndexChanged({
    if ($script:IsApplyingLanguage) { return }

    if ($languageComboBox.SelectedIndex -eq 0) {
        Set-UiLanguage -Language 'zh-CN'
    } else {
        Set-UiLanguage -Language 'en-US'
    }

    Apply-UiLanguage
})

$bindButton.Add_Click({
    $device = Get-SelectedUsbDevice
    if ($null -eq $device) { return }
    Invoke-SelectedDeviceAction -ActionName (Get-UiText -Key 'Action.Bind') -Arguments @('bind', '--busid', $device.BusId) -RequiresAdmin
})

$unbindButton.Add_Click({
    $device = Get-SelectedUsbDevice
    if ($null -eq $device) { return }
    Invoke-SelectedDeviceAction -ActionName (Get-UiText -Key 'Action.Unbind') -Arguments @('unbind', '--busid', $device.BusId) -RequiresAdmin
})

$attachButton.Add_Click({
    $device = Get-SelectedUsbDevice
    if ($null -eq $device) { return }
    Invoke-SelectedDeviceActionPlan -Steps (Get-ConnectUsbDevicePlan -Device $device)
})

$detachButton.Add_Click({
    $device = Get-SelectedUsbDevice
    if ($null -eq $device) { return }
    Invoke-SelectedDeviceAction -ActionName (Get-UiText -Key 'Action.Detach') -Arguments @('detach', '--busid', $device.BusId) -WaitForBusIdBeforeRefresh $device.BusId
})

$form.Add_Shown({
    Apply-UiLanguage
    Update-Status
    Refresh-UsbList
})

[void][System.Windows.Forms.Application]::Run($form)
