#!/usr/bin/python3
"""Two-level BlueZ menu with a wofi pairing agent."""
import fcntl
import os
import subprocess
from pathlib import Path

from gi.repository import Gio, GLib

CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "wofi"
ADAPTER = "org.bluez.Adapter1"
DEVICE = "org.bluez.Device1"
AGENT_PATH = "/org/wofi/BluetoothAgent"
AGENT_XML = """
<node><interface name="org.bluez.Agent1">
  <method name="Release"/>
  <method name="Cancel"/>
  <method name="RequestPinCode"><arg type="o" direction="in"/><arg type="s" direction="out"/></method>
  <method name="RequestPasskey"><arg type="o" direction="in"/><arg type="u" direction="out"/></method>
  <method name="DisplayPinCode"><arg type="o" direction="in"/><arg type="s" direction="in"/></method>
  <method name="DisplayPasskey"><arg type="o" direction="in"/><arg type="u" direction="in"/><arg type="q" direction="in"/></method>
  <method name="RequestConfirmation"><arg type="o" direction="in"/><arg type="u" direction="in"/></method>
  <method name="RequestAuthorization"><arg type="o" direction="in"/></method>
  <method name="AuthorizeService"><arg type="o" direction="in"/><arg type="s" direction="in"/></method>
</interface></node>
"""


def notify(message):
    subprocess.run(["notify-send", "蓝牙", message], check=False)


def label(text):
    return " ".join(str(text).split())


def wofi_args(prompt, height):
    return [
        "wofi", "--show", "dmenu", "--prompt", prompt,
        "--style", str(CONFIG / "css/bluetooth.css"),
        "--width", "640", "--height", str(height), "--columns", "1",
        "--cache-file", "/dev/null", "--define", "allow_images=false",
        "--define", "allow_markup=false", "--define", "line_wrap=word_char",
    ]


def menu(items, prompt, height=480):
    result = subprocess.run(
        wofi_args(prompt, height) + ["--no-custom-entry", "--define", "dmenu-print_line_num=true"],
        input="\n".join(text for text, action in items) + "\n",
        text=True, stdout=subprocess.PIPE,
    )
    selected = result.stdout.strip()
    if result.returncode or not selected.isdigit():
        return None
    index = int(selected)
    return items[index][1] if index < len(items) else None


def input_code(prompt):
    result = subprocess.run(
        wofi_args(prompt, 160) + ["--define", "exec_search=true",
                                 "--define", "no_custom_entry=false",
                                 "--define", "dmenu-print_line_num=false"],
        input="", text=True, stdout=subprocess.PIPE,
    )
    return result.stdout.removesuffix("\n") if result.returncode == 0 else None


class BlueZ:
    def __init__(self):
        self.bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
        adapters = [(path, interfaces[ADAPTER]) for path, interfaces in self.objects().items()
                    if ADAPTER in interfaces]
        if not adapters:
            raise RuntimeError("没有找到蓝牙适配器，请检查蓝牙服务或设备")
        adapters.sort(key=lambda item: (not item[1].get("Powered", False), item[0]))
        self.adapter = adapters[0][0]

    def call(self, path, interface, method, parameters=None, timeout=30000):
        return self.bus.call_sync("org.bluez", path, interface, method, parameters,
                                  None, Gio.DBusCallFlags.NONE, timeout, None)

    def objects(self):
        return self.call("/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects",
                         timeout=5000).unpack()[0]

    def properties(self, path, interface):
        return self.call(path, "org.freedesktop.DBus.Properties", "GetAll",
                         GLib.Variant("(s)", (interface,)), timeout=5000).unpack()[0]

    def set_property(self, path, interface, name, value):
        self.call(path, "org.freedesktop.DBus.Properties", "Set",
                  GLib.Variant("(ssv)", (interface, name, GLib.Variant("b", value))))

    def devices(self):
        devices = []
        for path, interfaces in self.objects().items():
            info = interfaces.get(DEVICE)
            if info is not None and info.get("Adapter") == self.adapter:
                devices.append({**info, "path": path})
        return sorted(devices, key=lambda d: (not d.get("Connected", False),
                      not d.get("Paired", False), label(d.get("Alias", "")).casefold()))

    def scan(self):
        # Discovery belongs to this D-Bus connection; stop only our own session.
        self.call(self.adapter, ADAPTER, "StartDiscovery")
        loop = GLib.MainLoop()
        def finish():
            loop.quit()
            return GLib.SOURCE_REMOVE
        GLib.timeout_add_seconds(8, finish)
        try:
            loop.run()
        finally:
            self.call(self.adapter, ADAPTER, "StopDiscovery")

    def agent_request(self, connection, sender, path, interface, method, parameters, invocation):
        args = parameters.unpack()
        try:
            if method in ("Release", "Cancel"):
                invocation.return_value(GLib.Variant("()", ()))
                return
            info = self.properties(args[0], DEVICE)
            name = label(info.get("Alias", info.get("Address", "设备")))
            if method in ("DisplayPinCode", "DisplayPasskey"):
                code = args[1] if method == "DisplayPinCode" else f"{args[1]:06d}"
                notify(f"请在 {name} 上输入配对码 {code}，并按确认键")
                invocation.return_value(GLib.Variant("()", ()))
                return
            if method in ("RequestPinCode", "RequestPasskey"):
                code = input_code(f"{name} · 输入配对码")
                if method == "RequestPasskey":
                    if code is None or not code.isascii() or not code.isdigit() or len(code) > 6:
                        raise ValueError("无效配对码")
                    invocation.return_value(GLib.Variant("(u)", (int(code),)))
                else:
                    if not code or not 1 <= len(code) <= 16:
                        raise ValueError("无效 PIN")
                    invocation.return_value(GLib.Variant("(s)", (code,)))
                return
            if method == "RequestConfirmation":
                prompt = f"{name} · 配对码 {args[1]:06d}"
                question = "配对码一致，确认配对"
            else:
                prompt = f"{name} · 蓝牙授权"
                question = "允许配对" if method == "RequestAuthorization" else "允许连接服务"
            if menu([(question, True), ("拒绝", False)], prompt, height=240) is not True:
                raise ValueError("已取消")
            invocation.return_value(GLib.Variant("()", ()))
        except (OSError, GLib.Error, ValueError):
            invocation.return_dbus_error("org.bluez.Error.Rejected", "Pairing rejected")

    def pair(self, path):
        node = Gio.DBusNodeInfo.new_for_xml(AGENT_XML)
        registration = self.bus.register_object(AGENT_PATH, node.interfaces[0],
                                                 self.agent_request, None, None)
        registered = False
        loop = GLib.MainLoop()
        errors = []
        def finished(connection, result, user_data):
            try:
                connection.call_finish(result)
            except GLib.Error as error:
                errors.append(error)
            loop.quit()
        try:
            self.call("/org/bluez", "org.bluez.AgentManager1", "RegisterAgent",
                      GLib.Variant("(os)", (AGENT_PATH, "KeyboardDisplay")))
            registered = True
            self.bus.call("org.bluez", path, DEVICE, "Pair", None, None,
                          Gio.DBusCallFlags.NONE, 90000, None, finished, None)
            loop.run()
            if errors:
                # Cancel server-side pairing after timeout or rejection.
                try:
                    self.call(path, DEVICE, "CancelPairing", timeout=5000)
                except GLib.Error:
                    pass
                raise errors[0]
        finally:
            try:
                if registered:
                    self.call("/org/bluez", "org.bluez.AgentManager1", "UnregisterAgent",
                              GLib.Variant("(o)", (AGENT_PATH,)))
            finally:
                self.bus.unregister_object(registration)


def choose_device(bluez, action):
    if action == "scan":
        notify("正在扫描附近蓝牙设备（约 8 秒）…")
        bluez.scan()
    devices = bluez.devices()
    if action == "connect":
        devices = [d for d in devices if d.get("Paired") or d.get("Bonded")]
    elif action == "disconnect":
        devices = [d for d in devices if d.get("Connected")]
    if not devices:
        notify("没有可选设备，请先扫描并让设备进入配对模式")
        return
    items = [("‹ 返回蓝牙菜单", None)]
    for device in devices:
        name = label(device.get("Alias", device.get("Address", "未知设备")))
        state = "已连接" if device.get("Connected") else "已配对" if device.get("Paired") else "未配对"
        address = device.get("Address", "")
        items.append((f"{'✓ ' if device.get('Connected') else ''}{name}    {state} · {address}", device))
    prompts = {"connect": "连接设备", "disconnect": "断开设备", "scan": "选择设备并配对"}
    selected = menu(items, f"蓝牙 › {prompts[action]}")
    if selected is None:
        return
    path = selected["path"]
    info = bluez.properties(path, DEVICE)
    name = label(info.get("Alias", info.get("Address", "设备")))
    if action == "disconnect":
        bluez.call(path, DEVICE, "Disconnect")
        notify(f"已断开：{name}")
        return
    if info.get("Connected"):
        notify(f"已经连接：{name}")
        return
    if not info.get("Paired"):
        if menu([("配对并信任此设备", True), ("取消", False)], f"配对：{name}", 240) is not True:
            return
        notify(f"正在配对：{name}")
        bluez.pair(path)
        bluez.set_property(path, DEVICE, "Trusted", True)
    notify(f"正在连接：{name}")
    # Pairing may already have established a connection.
    if not bluez.properties(path, DEVICE).get("Connected"):
        bluez.call(path, DEVICE, "Connect")
    notify(f"连接成功：{name}")


def main():
    bluez = BlueZ()
    while True:
        try:
            enabled = bluez.properties(bluez.adapter, ADAPTER).get("Powered", False)
            connected = [d for d in bluez.devices() if d.get("Connected")] if enabled else []
            status = f"已连接 {len(connected)} 个设备" if connected else "未连接" if enabled else "已关闭"
            items = []
            if enabled:
                items += [("连接已配对设备 ›", ("connect", None)),
                          ("扫描并配对设备 ›", ("scan", None))]
                if connected:
                    items.append(("断开设备 ›", ("disconnect", None)))
            items += [("关闭蓝牙" if enabled else "开启蓝牙", ("power", not enabled)),
                      ("完整蓝牙设置（bluetui）", ("settings", None))]
            choice = menu(items, f"蓝牙 · {status}", height=360)
            if choice is None:
                return
            action, value = choice
            if action == "power":
                bluez.set_property(bluez.adapter, ADAPTER, "Powered", value)
                notify("蓝牙已开启" if value else "蓝牙已关闭")
            elif action == "settings":
                subprocess.Popen(["wezterm", "start", "--", "bluetui"], start_new_session=True)
                return
            else:
                choose_device(bluez, action)
        except (OSError, GLib.Error, RuntimeError, subprocess.SubprocessError) as error:
            notify(f"蓝牙操作失败：{str(error)[:250]}")
            return


if __name__ == "__main__":
    try:
        runtime = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
        with (runtime / f"wofi-bluetooth-{os.getuid()}.lock").open("w") as lock:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                raise SystemExit(0)
            main()
    except (OSError, GLib.Error, RuntimeError, subprocess.SubprocessError) as error:
        notify(f"蓝牙操作失败：{str(error)[:250]}")
