# USB WSL Manager

一个简单的 Windows PowerShell GUI 工具，用来管理 `usbipd-win`，把 Windows 上的 USB 设备共享并连接到 WSL2。

## 功能

- 检测并安装 `usbipd-win`
- 获取 Windows USB 设备列表
- 选择设备后执行 `usbipd bind` 共享
- 执行 `usbipd unbind` 取消共享
- 执行 `usbipd attach --wsl` 连接到 WSL
- 执行 `usbipd detach` 从 WSL 断开
- 内置 WSL 侧 `lsusb`、串口权限、`udev` 权限规则说明

## 使用方法

双击运行：

```text
Run-UsbWslManager.bat
```

或者在 PowerShell 中运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File ".\UsbWslManager.ps1"
```

## 常见流程

1. 打开工具。
2. 如果没有安装 `usbipd-win`，点击“安装 usbipd-win”。
3. 点击“刷新列表”。
4. 选择目标 USB 设备。
5. 首次使用时点击“共享 / bind”。
6. 点击“连接到 WSL”。
7. 在 WSL 中执行 `lsusb` 确认设备可见。

重启电脑、重启 WSL 或设备拔插后，通常只需要重新执行“连接到 WSL”。`bind` 状态一般会保留。

## WSL 权限设置

如果 WSL 中 `lsusb` 能看到设备，但软件读不到，先测试：

```bash
sudo 你的软件命令
```

如果 `sudo` 可以读到，通常是权限问题。

串口设备常见处理：

```bash
ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
sudo usermod -aG dialout $USER
```

退出 WSL 后重新进入，或执行：

```bash
newgrp dialout
```

libusb/raw USB 设备可以添加 udev 规则。先找 VID/PID：

```bash
lsusb
```

然后替换下面示例里的 `2341` 和 `0043`：

```bash
sudo tee /etc/udev/rules.d/99-usb-wsl.rules <<'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="2341", ATTR{idProduct}=="0043", MODE="0666", TAG+="uaccess"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger
```

如果 `udev` 不工作，可以在 `/etc/wsl.conf` 中启用 systemd：

```ini
[boot]
systemd=true
```

然后在 Windows PowerShell 中执行：

```powershell
wsl --shutdown
```

## 安全与隐私

项目中没有包含本机用户名、绝对路径、GitHub 凭据、设备序列号或其他私密配置。启动脚本使用自身目录 `%~dp0` 定位 PowerShell 脚本，可以移动到其他目录使用。

## 依赖

- Windows 10/11
- WSL2
- PowerShell 5.1 或更新版本
- `usbipd-win`
- `winget`，仅用于工具内一键安装 `usbipd-win`
