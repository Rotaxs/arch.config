#!/usr/bin/env bash

# ============================================================
# niri wallpaper selector
#
# dependencies:
#   fuzzel
#   awww
#   mpvpaper
#   niri
#
# directory:
#   ~/Pictures/Wallpapers/
#       ├── images/
#       ├── gifs/
#       └── videos/
# ============================================================

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

IMAGE_DIR="$WALLPAPER_DIR/images"
GIF_DIR="$WALLPAPER_DIR/gifs"
VIDEO_DIR="$WALLPAPER_DIR/videos"


# ------------------------------------------------------------
# fuzzel 菜单
# ------------------------------------------------------------

menu() {
    fuzzel --dmenu --prompt="$1"
}


# ------------------------------------------------------------
# 1. 选择壁纸类型
# ------------------------------------------------------------

type=$(
    printf "%s\n" \
        "图片" \
        "动图" \
        "视频" |
    menu "类型 > "
)

[[ -z "$type" ]] && exit 0


# ------------------------------------------------------------
# 2. 根据类型确定目录和扩展名
# ------------------------------------------------------------

case "$type" in

    "图片")
        directory="$IMAGE_DIR"
        extensions=(
            jpg
            jpeg
            png
            webp
            bmp
        )
        ;;

    "动图")
        directory="$GIF_DIR"
        extensions=(
            gif
            webp
        )
        ;;

    "视频")
        directory="$VIDEO_DIR"
        extensions=(
            mp4
            webm
            mkv
            mov
        )
        ;;

    *)
        exit 0
        ;;
esac


# ------------------------------------------------------------
# 3. 查找壁纸
#
# 用数组保存完整路径。
# fuzzel 中只显示 basename。
# ------------------------------------------------------------

files=()

while IFS= read -r -d '' file; do
    files+=("$file")
done < <(
    find "$directory" -type f -print0 2>/dev/null
)


if [[ ${#files[@]} -eq 0 ]]; then
    notify-send "Wallpaper" "$directory 中没有找到壁纸"
    exit 1
fi


# ------------------------------------------------------------
# 过滤扩展名
# ------------------------------------------------------------

filtered_files=()

for file in "${files[@]}"; do

    extension="${file##*.}"
    extension="${extension,,}"

    for allowed in "${extensions[@]}"; do

        if [[ "$extension" == "$allowed" ]]; then
            filtered_files+=("$file")
            break
        fi

    done
done


if [[ ${#filtered_files[@]} -eq 0 ]]; then
    notify-send "Wallpaper" "没有找到 $type 文件"
    exit 1
fi


# ------------------------------------------------------------
# 4. 生成 fuzzel 显示列表
#
# 只显示：
#
#   wallpaper.jpg
#
# 而不是：
#
#   /home/xxx/Pictures/Wallpapers/images/wallpaper.jpg
# ------------------------------------------------------------

display_list=""

for file in "${filtered_files[@]}"; do
    display_list+="$(basename "$file")"$'\n'
done


selected_name=$(
    printf "%s" "$display_list" |
    menu "$type > "
)

[[ -z "$selected_name" ]] && exit 0


# ------------------------------------------------------------
# 根据选中的 basename 找到完整路径
# ------------------------------------------------------------

selected_file=""

for file in "${filtered_files[@]}"; do

    if [[ "$(basename "$file")" == "$selected_name" ]]; then
        selected_file="$file"
        break
    fi

done


[[ -z "$selected_file" ]] && exit 1


# ------------------------------------------------------------
# 5. 获取 niri 显示器
#
# niri msg outputs 一般类似：
#
# Output "BOE NE160QDM-NX3 Unknown" (eDP-1)
# Output "ViewSonic Corporation VA24G25 Y5K252320576" (HDMI-A-1)
#
# 提取行尾括号里的接口名；引号里是屏幕描述，不能用于壁纸工具。
# ------------------------------------------------------------

outputs=()

while IFS= read -r output; do
    [[ -n "$output" ]] && outputs+=("$output")
done < <(
    niri msg outputs |
    sed -n 's/^Output ".*" (\([^()]*\))$/\1/p'
)


if [[ ${#outputs[@]} -eq 0 ]]; then
    notify-send "Wallpaper" "无法获取 niri 显示器"
    exit 1
fi


# ------------------------------------------------------------
# 6. 选择显示器
# ------------------------------------------------------------

output_list="全部屏幕"$'\n'

for output in "${outputs[@]}"; do
    output_list+="$output"$'\n'
done


selected_output=$(
    printf "%s" "$output_list" |
    menu "显示器 > "
)

[[ -z "$selected_output" ]] && exit 0


# ------------------------------------------------------------
# 7. 设置壁纸
# ------------------------------------------------------------

case "$type" in

    "图片"|"动图")

        # 如果之前有视频壁纸，关闭 mpvpaper。
        #
        # 注意：
        # 这是最简单的处理方式，会关闭所有 mpvpaper。
        # 后面如果需要，我可以再给你改成
        # “只关闭当前 output 对应的 mpvpaper”。

        pkill mpvpaper 2>/dev/null

        if [[ "$selected_output" == "全部屏幕" ]]; then

            awww img "$selected_file" \
                --transition-type grow \
                --transition-duration 1

        else

            awww img \
                --outputs "$selected_output" \
                "$selected_file" \
                --transition-type grow \
                --transition-duration 1

        fi
        ;;


    "视频")

        # 关闭之前的视频壁纸
        pkill mpvpaper 2>/dev/null

        if [[ "$selected_output" == "全部屏幕" ]]; then

            mpvpaper \
                -f \
                -o "no-audio loop-file=inf hwdec=auto-safe panscan=1" \
                ALL \
                "$selected_file"

        else

            mpvpaper \
                -f \
                -o "no-audio loop-file=inf hwdec=auto-safe panscan=1" \
                "$selected_output" \
                "$selected_file"

        fi

        ;;

esac
