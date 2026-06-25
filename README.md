# USB WSL Manager

English | [中文](README.zh-CN.md)

A small Windows PowerShell GUI tool for managing `usbipd-win` and sharing USB devices from Windows into WSL2.

## Features

- Detect and install `usbipd-win`
- List Windows USB devices
- Share selected devices with `usbipd bind`
- Stop sharing devices with `usbipd unbind`
- Attach devices to WSL with `usbipd attach --wsl`
- Detach devices from WSL with `usbipd detach`
- Built-in WSL notes for `lsusb`, serial device permissions, and `udev` rules

## Usage

Double-click:

```text
Run-UsbWslManager.bat
```

Or run from PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File ".\UsbWslManager.ps1"
```

The tool requests administrator permission at startup so it can run `usbipd bind`, `usbipd unbind`, and installation commands.
The UI supports English and Chinese. It follows the system language by default, and you can switch languages from the top-right corner of the window.

## Common Workflow

1. Open the tool.
2. If `usbipd-win` is not installed, click "Install usbipd-win".
3. Click "Refresh".
4. Select the target USB device.
5. Click "Connect to WSL"; if the device is not shared yet, the tool automatically runs `usbipd bind` first.
6. In WSL, run `lsusb` to confirm that the device is visible.

After rebooting Windows, restarting WSL, or unplugging/replugging the device, you usually only need to run "Connect to WSL" again. The `bind` state is normally preserved.

## WSL Permission Setup

If `lsusb` can see the device in WSL but your software cannot access it, test with:

```bash
sudo your-command
```

If `sudo` works, the issue is usually permissions.

For serial devices:

```bash
ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
sudo usermod -aG dialout $USER
```

Exit WSL and open it again, or run:

```bash
newgrp dialout
```

For libusb/raw USB devices, add a `udev` rule. First find the VID/PID:

```bash
lsusb
```

Then replace `2341` and `0043` in this example:

```bash
sudo tee /etc/udev/rules.d/99-usb-wsl.rules <<'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="2341", ATTR{idProduct}=="0043", MODE="0666", TAG+="uaccess"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger
```

If `udev` does not work, enable systemd in `/etc/wsl.conf`:

```ini
[boot]
systemd=true
```

Then run this in Windows PowerShell:

```powershell
wsl --shutdown
```

## Security And Privacy

This project does not include local usernames, absolute paths, GitHub credentials, device serial numbers, or other private configuration. The launcher uses its own directory (`%~dp0`) to locate the PowerShell script, so the tool can be moved to another directory.

## Requirements

- Windows 10/11
- WSL2
- PowerShell 5.1 or later
- `usbipd-win`
- `winget`, only for the one-click `usbipd-win` installation inside the tool

## License

MIT License. See [LICENSE](LICENSE).
