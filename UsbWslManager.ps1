Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
        return '未安装'
    }

    try {
        $result = Invoke-ProcessCommand -FilePath 'usbipd' -Arguments @('--version')
        if ($result.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($result.StdOut)) {
            return $result.StdOut
        }
    } catch {
    }

    return '已安装'
}

function Get-UsbipdDevices {
    if (-not (Test-CommandAvailable -Name 'usbipd')) {
        throw '未找到 usbipd。请先点击“安装 usbipd-win”。'
    }

    $result = Invoke-ProcessCommand -FilePath 'usbipd' -Arguments @('list')
    if ($result.ExitCode -ne 0) {
        $message = $result.StdErr
        if ([string]::IsNullOrWhiteSpace($message)) {
            $message = $result.StdOut
        }
        throw "usbipd list 失败：$message"
    }

    return ConvertFrom-UsbipdListOutput -Text $result.StdOut
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
            ActionName    = '共享设备'
            Arguments     = @('bind', '--busid', $Device.BusId)
            RequiresAdmin = $true
        }
    }

    $steps += [pscustomobject]@{
        ActionName    = '连接到 WSL'
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
$statusLabel.Size = New-Object System.Drawing.Size(998, 28)
$statusLabel.Anchor = 'Top,Left,Right'
$form.Controls.Add($statusLabel)

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
    $adminText = if (Test-IsAdministrator) { '管理员' } else { '普通用户' }
    $statusLabel.Text = "usbipd: $versionText    当前权限: $adminText    提示: 工具启动时会请求管理员权限，便于直接执行 bind/unbind/安装。"
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

        Add-Log "已刷新，找到 $($devices.Count) 个 USB 设备。"
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '刷新失败', 'OK', 'Warning') | Out-Null
        Add-Log "刷新失败：$($_.Exception.Message)"
    } finally {
        $listView.EndUpdate()
    }
}

function Get-SelectedUsbDevice {
    if ($listView.SelectedItems.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('请先在列表中选择一个 USB 设备。', '未选择设备', 'OK', 'Information') | Out-Null
        return $null
    }

    return $listView.SelectedItems[0].Tag
}

function Invoke-SelectedDeviceAction {
    param(
        [Parameter(Mandatory = $true)][string] $ActionName,
        [Parameter(Mandatory = $true)][string[]] $Arguments,
        [switch] $RequiresAdmin
    )

    try {
        Add-Log "执行：usbipd $(Join-CommandArguments -Arguments $Arguments)"
        $result = Invoke-UsbipdAction -Arguments $Arguments -RequiresAdmin:$RequiresAdmin

        if ($result.ExitCode -eq 0) {
            if (-not [string]::IsNullOrWhiteSpace($result.StdOut)) {
                Add-Log $result.StdOut
            }
            Add-Log "$ActionName 完成。"
            Refresh-UsbList
            return
        }

        $message = $result.StdErr
        if ([string]::IsNullOrWhiteSpace($message)) {
            $message = $result.StdOut
        }
        throw "$ActionName 失败：$message"
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, $ActionName, 'OK', 'Warning') | Out-Null
        Add-Log "$ActionName 失败：$($_.Exception.Message)"
    }
}

function Invoke-SelectedDeviceActionPlan {
    param(
        [Parameter(Mandatory = $true)] [object[]] $Steps
    )

    try {
        foreach ($step in $Steps) {
            Add-Log "执行：usbipd $(Join-CommandArguments -Arguments $step.Arguments)"
            $result = Invoke-UsbipdAction -Arguments $step.Arguments -RequiresAdmin:$step.RequiresAdmin

            if ($result.ExitCode -ne 0) {
                $message = $result.StdErr
                if ([string]::IsNullOrWhiteSpace($message)) {
                    $message = $result.StdOut
                }
                throw "$($step.ActionName) 失败：$message"
            }

            if (-not [string]::IsNullOrWhiteSpace($result.StdOut)) {
                Add-Log $result.StdOut
            }
            Add-Log "$($step.ActionName) 完成。"
        }

        Refresh-UsbList
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '连接到 WSL', 'OK', 'Warning') | Out-Null
        Add-Log "连接到 WSL 失败：$($_.Exception.Message)"
    }
}

$installButton.Add_Click({
    try {
        if (-not (Test-CommandAvailable -Name 'winget')) {
            throw '未找到 winget。请先安装 Windows App Installer，或手动安装 usbipd-win。'
        }

        Add-Log '准备通过 winget 安装 usbipd-win。'
        Start-ElevatedPowerShellCommand -Command 'winget install --interactive --exact dorssel.usbipd-win' -Pause
        Add-Log '安装命令已执行。若刚安装完成，请关闭并重新打开本工具。'
        Update-Status
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '安装 usbipd-win', 'OK', 'Warning') | Out-Null
        Add-Log "安装失败：$($_.Exception.Message)"
    }
})

$refreshButton.Add_Click({ Refresh-UsbList })

$bindButton.Add_Click({
    $device = Get-SelectedUsbDevice
    if ($null -eq $device) { return }
    Invoke-SelectedDeviceAction -ActionName '共享设备' -Arguments @('bind', '--busid', $device.BusId) -RequiresAdmin
})

$unbindButton.Add_Click({
    $device = Get-SelectedUsbDevice
    if ($null -eq $device) { return }
    Invoke-SelectedDeviceAction -ActionName '取消共享' -Arguments @('unbind', '--busid', $device.BusId) -RequiresAdmin
})

$attachButton.Add_Click({
    $device = Get-SelectedUsbDevice
    if ($null -eq $device) { return }
    Invoke-SelectedDeviceActionPlan -Steps (Get-ConnectUsbDevicePlan -Device $device)
})

$detachButton.Add_Click({
    $device = Get-SelectedUsbDevice
    if ($null -eq $device) { return }
    Invoke-SelectedDeviceAction -ActionName '从 WSL 断开' -Arguments @('detach', '--busid', $device.BusId)
})

$form.Add_Shown({
    Update-Status
    Refresh-UsbList
})

[void][System.Windows.Forms.Application]::Run($form)
