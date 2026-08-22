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

首先开启 `systemd-resolved` 服务

```bash
systemctl enable --now systemd-resolved
```

再把 `/etc/resolv.conf` 软链接到 `systemd` 托管的文件

```bash
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

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
sudo pacman -S tlp swayidle swaylock-effects upower

sudo systemctl enable --now tlp.service
```

- `tlp`: 电源调优，负责 CPU 调频、磁盘/USB 节能、电池充放电阈值管理等
- `swayidle`: 空闲时间监听，监听鼠标/键盘输入，超时自动触发熄屏
- `swaylock`: 提供 Wayland 下的图形锁屏界面
- `upower`: 状态查询接口

### 音频管理

```bash
sudo pacman -S alsa-utils sof-firmware pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber wiremix

systemctl --user enable --now pipewire pipewire-pulse wireplumber
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

### 显卡驱动

```bash
sudo pacman -S mesa vulkan-intel intel-media-driver
```

- `mesa`: 提供 OpenGl 支持
- `vulkan-intel`: Interl Arc 核显的 Vulkan 驱动
- `intel-meida-driver`: 提供 VA-API 的视频硬件解码支持

### 剪切板和截屏

```bash
sudo pacman -S wl-clipboard cliphist fuzzel grim slurp swappy
```

- `wl-clipboard`: Wayland 下的底层剪切板工具，提供 `wl-copy` 和 `wl-paste` 工具
- `cliphist`: 提供支持文本和图片的后台历史记录守护进程
- `fuzzel`: 应用程序启动器，作为剪切板的前端显示部分
- `grim`: Wayland 原生截图底层工具
- `slurp`: 用于获取屏幕上指定区域
- `swappy`: 图片标注工具


然后需要在 `niri` 的配置文件中添加如下内容

```kdl
spawn-at-startup "wl-paste" "--watch" "cliphist" "store"    

binds {
    // 使用 fuzzel 查看并选择剪切板历史
    Mod+V { spawn "sh" "-c" "cliphist list | fuzzel -d -p ' Clipboard: ' | cliphist decode | wl-copy"; }
    // 区域截图：选区 -> 自动复制到剪贴板 -> 存入图片目录
    Mod+Shift+S { spawn "sh" "-c" "grim -g \"$(slurp)\" - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot_$(date +'%Y%m%m_%H%M%S').png"; }
    // 交互式标注截图：选区 -> 唤起 Swappy 标注 -> 自由保存/复制
    Print { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }
}
```

## 其他

Chrome 标签栏字体不是中文字体

```bash
# 1. 设置颜色模式为暗色
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# 2. 设置系统界面字体
gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK SC 11'
```

