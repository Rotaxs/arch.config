#!/usr/bin/python3
"""NetworkManager Wi-Fi menu for Waybar; no shell interpolation."""
import fcntl
import os
import subprocess
from pathlib import Path

CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "wofi"
ENV = {**os.environ, "LC_ALL": "C"}


def notify(message):
    subprocess.run(["notify-send", "Wi-Fi", message], check=False)


def nm(*args, secret=None):
    result = subprocess.run(
        ["nmcli", "--colors", "no", "--wait", "30", *args],
        input=secret, text=True, capture_output=True, env=ENV, timeout=40,
    )
    if result.returncode:
        # Do not include argv or input: password input must never enter notices.
        raise RuntimeError((result.stderr or result.stdout).strip() or "操作失败")
    return result.stdout.rstrip("\n")


def fields(line):
    """Split nmcli terse rows, respecting escaped colons and backslashes."""
    result, current, escaped = [], [], False
    for char in line:
        if escaped:
            current.append(char)
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == ":":
            result.append("".join(current))
            current = []
        else:
            current.append(char)
    if escaped:
        current.append("\\")
    return result + ["".join(current)]


def label(text):
    return " ".join(text.split())


def menu(items, prompt, height=480):
    result = subprocess.run([
        "wofi", "--show", "dmenu", "--prompt", prompt,
        "--style", str(CONFIG / "css/wifi.css"),
        "--width", "640", "--height", str(height), "--columns", "1",
        "--cache-file", "/dev/null", "--no-custom-entry",
        "--define", "allow_images=false", "--define", "allow_markup=false",
        "--define", "line_wrap=word_char",
        "--define", "dmenu-print_line_num=true",
    ], input="\n".join(text for text, action in items) + "\n",
       text=True, stdout=subprocess.PIPE)
    selected = result.stdout.strip()
    if result.returncode or not selected.isdigit():
        return None
    index = int(selected)
    return items[index][1] if index < len(items) else None


def password(ssid):
    result = subprocess.run([
        "wofi", "--show", "dmenu", "--prompt", f"密码：{label(ssid)}",
        "--style", str(CONFIG / "css/wifi.css"),
        "--width", "640", "--height", "160", "--columns", "1",
        "--cache-file", "/dev/null", "--password", "*",
        "--define", "exec_search=true", "--define", "no_custom_entry=false",
        "--define", "allow_images=false", "--define", "allow_markup=false",
        "--define", "dmenu-print_line_num=false",
    ], input="", text=True, stdout=subprocess.PIPE)
    if result.returncode:
        return None
    value = result.stdout.removesuffix("\n")
    return value or None


def devices():
    rows = [fields(line) for line in nm("-t", "-f", "DEVICE,TYPE,STATE",
                                         "device", "status").splitlines()]
    wireless = [row for row in rows if len(row) == 3 and row[1] == "wifi"]
    if not wireless:
        raise RuntimeError("没有找到无线网卡")
    # Prefer a connected interface; never hard-code wlan0.
    wireless.sort(key=lambda row: row[2] != "connected")
    return wireless[0][0]


def networks(interface, rescan=False):
    output = nm("-t", "-f", "IN-USE,SSID,BSSID,SIGNAL,SECURITY",
                "device", "wifi", "list", "ifname", interface,
                "--rescan", "yes" if rescan else "no")
    unique = {}
    for line in output.splitlines():
        row = fields(line)
        if len(row) != 5 or not row[1] or not row[3].isdigit():
            continue
        active, ssid, bssid, strength, security = row
        ap = {"active": active == "*", "ssid": ssid, "bssid": bssid,
              "signal": int(strength), "security": security}
        key = (ssid, security)
        old = unique.get(key)
        if old is None or (ap["active"], ap["signal"]) > (old["active"], old["signal"]):
            unique[key] = ap
    return sorted(unique.values(), key=lambda ap: (not ap["active"], -ap["signal"]))


def saved_profile(ssid):
    for line in nm("-t", "-f", "UUID,TYPE", "connection", "show").splitlines():
        row = fields(line)
        if len(row) != 2 or row[1] != "802-11-wireless":
            continue
        stored = nm("--escape", "no", "-g", "802-11-wireless.ssid",
                    "connection", "show", "uuid", row[0])
        if stored == ssid:
            return row[0]
    return None


def connect(interface, ap):
    if ap["active"]:
        notify(f"已经连接：{label(ap['ssid'])}")
        return
    uuid = saved_profile(ap["ssid"])
    if uuid:
        notify(f"正在连接：{label(ap['ssid'])}")
        nm("connection", "up", "uuid", uuid, "ifname", interface, "ap", ap["bssid"])
    else:
        security = ap["security"].upper()
        if "802.1X" in security or "EAP" in security:
            notify("此网络需要企业认证，请使用菜单中的完整网络设置")
            return
        secured = security not in ("", "--")
        value = password(ap["ssid"]) if secured else None
        if secured and value is None:
            return
        notify(f"正在连接：{label(ap['ssid'])}")
        args = ["device", "wifi", "connect", ap["bssid"], "ifname", interface]
        if value is not None:
            # nmcli --ask reads the secret from stdin rather than argv.
            nm("--ask", *args, secret=value + "\n")
        else:
            nm(*args)
    notify(f"连接成功：{label(ap['ssid'])}")


def choose_network(interface, rescan=False):
    if rescan:
        notify("正在扫描附近网络…")
    aps = networks(interface, rescan)
    if not aps:
        notify("没有发现附近网络，可以返回后重新扫描")
        return
    items = [("‹ 返回 Wi-Fi 菜单", ("back", None))]
    for ap in aps:
        state = "✓ " if ap["active"] else "  "
        security = ap["security"] if ap["security"] not in ("", "--") else "开放"
        items.append((f"{state}{label(ap['ssid'])}    {ap['signal']}% · {security}",
                      ("connect", ap)))
    choice = menu(items, "Wi-Fi › 选择网络")
    # Esc returns to the parent menu without changing the connection.
    if choice is not None and choice[0] == "connect":
        connect(interface, choice[1])


def main():
    interface = devices()
    while True:
        enabled = nm("radio", "wifi") == "enabled"
        items = []
        status = "已关闭"
        if enabled:
            aps = networks(interface)
            active = next((ap for ap in aps if ap["active"]), None)
            status = f"已连接：{label(active['ssid'])}" if active else "未连接"
            items.append(("连接网络 ›", ("networks", None)))
            items.append(("扫描附近网络 ›", ("scan", None)))
            if active:
                items.append(("断开当前连接", ("disconnect", None)))
        items.append(("关闭 Wi-Fi" if enabled else "开启 Wi-Fi", ("power", not enabled)))
        items.append(("完整网络设置（nmtui）", ("settings", None)))
        choice = menu(items, f"Wi-Fi · {status}", height=360)
        if choice is None:
            return
        action, value = choice
        try:
            if action in ("networks", "scan"):
                choose_network(interface, rescan=action == "scan")
            elif action == "power":
                nm("radio", "wifi", "on" if value else "off")
                notify("Wi-Fi 已开启" if value else "Wi-Fi 已关闭")
            elif action == "disconnect":
                nm("device", "disconnect", interface)
                notify("已断开当前连接")
            elif action == "settings":
                subprocess.Popen(["wezterm", "start", "--", "nmtui"], start_new_session=True)
                return
        except (OSError, RuntimeError, subprocess.SubprocessError) as error:
            notify(str(error)[:300])


if __name__ == "__main__":
    try:
        # Avoid overlapping menus when Waybar is clicked repeatedly.
        runtime = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
        with (runtime / f"wofi-wifi-{os.getuid()}.lock").open("w") as lock:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                raise SystemExit(0)
            main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        notify(str(error)[:300])
