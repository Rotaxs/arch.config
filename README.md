# arch.conf

## 软件一览

- 窗口管理器: [niri](https://github.com/niri-wm/niri)
- 终端: [alacritty](https://github.com/alacritty/alacritty), [foot](https://codeberg.org/dnkl/foot)
- 应用启动器: [fuzzel](https://codeberg.org/dnkl/fuzzel)
- shell: [zsh](https://www.zsh.org/), [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)
- 文件编辑器: [neovim](https://github.com/neovim/neovim), [vscode](https://code.visualstudio.com/)
- 文件管理器: [yazi](https://github.com/sxyazi/yazi), [nautilus](https://github.com/GNOME/nautilus)
- 资源监视器: [btop](https://github.com/aristocratos/btop)
- 壁纸: [awww](https://codeberg.org/LGFae/awww)
- 浏览器: chrome

## 必要软件安装

### 网络管理

```bash
sudo pacman -S iwd impala

sudo systemctl enable --now iwd
```

- `iwd`: 提供网络连接的底层服务，提供 CLI 工具 `iwctl`
- `impala`: TUI 网络连接工具

注意，`iwd` 并没有默认开启 DHCP 客户端，需要配置 `/etc/iwd/main.conf` 手动开启

```conf
[General]
# 开启内置的 DHCP 客户端
EnableNetworkConfiguration=true

[Network]
# 使用内置的域名解析
NameResolvingService=systemd
```

然后重启 `iwd` 服务

```bash
sudo systemctl restart iwd
```

### 电源管理

```bash
sudo pacman -S tlp swayidle swaylock upower

sudo systemctl enable --now tlp.service
```

- `tlp`: 电源调优，负责 CPU 调频、磁盘/USB 节能、电池充放电阈值管理等
- `swayidle`: 空闲时间监听，监听鼠标/键盘输入，超时自动触发熄屏
- `swaylock`: 提供 Wayland 下的图形锁屏界面
- `upower`: 状态查询接口

### 音频管理

```bash
sudo pacman -S alsa-utils sof-firmware pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber wiremix

systemctl --user enable --now pipewire wireplumber
```

- `alsa-utils`: 提供驱动工具与排查命令
- `sof-firmware`: 加载声卡
- `pipewire` + `wireplumber`: 声音引擎与设备自动路由，分别提供 CLI 工具 `pactl` 和 `wpctl`
- `pipewire-alsa`, `pipewire-pulse`, `pipewire-jack`: 保证应用能够发声
- `wiremix`: TUI 音频管理工具

### 蓝牙管理

```bash
sudo pacman -S bluez bluez-utils bluetui

sudo systemctl enable --now bluetooth
```

- `bluez`: 提供蓝牙功能的底层服务
- `bluez-utils`: 基于 `bluez` 的工具集，提供 CLI 工具 `bluetoothctl`
- `bluetui`: TUI 蓝牙管理工具

### 屏幕亮度管理

```bash
sudo pacman -S brightnessctl
```

`brightnessctl`: 提供调节屏幕亮度的 CLI 工具

### 通知管理

```bash
sudo pacman -S libnotify mako
```

- `libnotify`: 提供 CLI 工具 `notify-send` 负责发送通知
- `mako`: Wayland 环境下的通知程序

### 权限认证代理

```bash
sudo pacman -S polkit-gnome
```

当普通用户需要管理员权限操作时，负责在屏幕上弹出密码输入框进行身份校验

### 桌面门户后端

```bash
sudo pacman -S xdg-desktop-portal-gnome xdg-desktop-portal-gtk
```

`xdg-desktop-portal` 提供应用调用原生桌面资源的接口，而 `xdg-desktop-portal-gnome/gtk` 是具体的图形后端实现

### 字体

```bash
sudo pacman -S noto-fonts-cjk noto-fonts-emoji ttf-firacode-nerd
```

- `noto-fonts-cjk`: 提供基本的中文字体和英文字体，如果有其他语言的需求可以装 `noto-fonts` 和 `noto-fonts-extra`
- `ttf-firacode-nerd`: 提供 `nerd` 字体和 `mono` 字体，适合终端显示图标和日常写代码

### 输入法

```bash
sudo pacman -S fcitx5-im fcitx5-chinese-addons fcitx5-rime
```

- `fcitx5-im`: 提供 fctix5 本体，配置工具和输入法
- `fcitx5-chinese-addons`: 提供中文输入法
- `fcitx5-rime`: 更好用的输入法（配合 [rime-ice](https://github.com/iDvel/rime-ice)


