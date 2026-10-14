#!/usr/bin/python3
"""Waybar power menu: power off, reboot, lock, or turn off monitors."""
import fcntl
import os
import re
import subprocess
import time
from pathlib import Path

CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "wofi"
LOCK_CONFIG = CONFIG.parent / "hypr/hyprlock.conf"
ACTIONS = [
    ("关机", ["systemctl", "poweroff"]),
    ("重启", ["systemctl", "reboot"]),
    ("锁屏", ["hyprlock", "--config", str(LOCK_CONFIG)]),
    ("熄屏", ["niri", "msg", "action", "power-off-monitors"]),
]
BACKLIGHT = Path("/sys/class/backlight")
DRM = Path("/sys/class/drm")


def menu(labels, prompt, height=340):
    result = subprocess.run([
        "wofi", "--show", "dmenu", "--prompt", prompt,
        "--style", str(CONFIG / "css/power.css"),
        "--width", "420", "--height", str(height), "--columns", "1",
        "--cache-file", "/dev/null", "--no-custom-entry",
        "--define", "allow_images=false", "--define", "allow_markup=false",
        "--define", "dmenu-print_line_num=true",
    ], input="\n".join(labels) + "\n", text=True, stdout=subprocess.PIPE)
    selected = result.stdout.strip()
    if result.returncode or not selected.isdigit():
        return None
    index = int(selected)
    return index if index < len(labels) else None


def run(command):
    subprocess.run(command, check=True, text=True,
                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def monitor_state(connector):
    try:
        if (connector / "status").read_text().strip() != "connected":
            return None
        return (connector / "dpms").read_text().strip()
    except FileNotFoundError:
        return None


def screen_off():
    # Read raw values: saving rounded percentages loses brightness precision.
    saved = [(device.name, int((device / "brightness").read_text()))
             for device in sorted(BACKLIGHT.iterdir())
             if (device / "brightness").is_file()]
    monitors = [connector for connector in DRM.glob("card*-*")
                if monitor_state(connector) == "On"]
    if saved and not monitors:
        raise RuntimeError("无法读取显示器电源状态，未执行熄屏")
    run(["niri", "msg", "action", "power-off-monitors"])
    if not saved:
        return
    # Wait for the off transition before accepting a wake event.
    deadline = time.monotonic() + 5
    while not any(monitor_state(connector) == "Off" for connector in monitors):
        if time.monotonic() >= deadline:
            raise RuntimeError("未检测到熄屏状态，请检查显示器是否已重新点亮")
        time.sleep(0.1)
    while any(monitor_state(connector) not in ("On", None) for connector in monitors):
        # Exit with the compositor session rather than leaving a stale watcher.
        socket = os.environ.get("NIRI_SOCKET")
        if socket and not Path(socket).exists():
            return
        time.sleep(0.25)
    # Let the panel's wake transition finish before restoring its backlight.
    time.sleep(0.2)
    for name, value in saved:
        if (BACKLIGHT / name).exists():
            run(["brightnessctl", "--class=backlight", "--device", name,
                 "set", str(value)])


def main():
    selected = menu([name for name, command in ACTIONS], "电源")
    if selected is None:
        return
    name, command = ACTIONS[selected]
    if name in ("关机", "重启"):
        # Cancel is the default; only an explicit confirmation executes it.
        if menu(["取消", f"确认{name}"], f"确认{name}？", height=230) != 1:
            return
    if name == "熄屏":
        screen_off()
    else:
        run(command)


if __name__ == "__main__":
    try:
        runtime = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
        with (runtime / f"wofi-power-{os.getuid()}.lock").open("w") as lock:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                raise SystemExit(0)
            main()
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
        detail = getattr(error, "stderr", None) or getattr(error, "stdout", None) or str(error)
        detail = re.sub(r"\x1b\[[0-9;]*m", "", detail).strip()
        subprocess.run(["notify-send", "电源操作失败", detail[-500:]], check=False)
