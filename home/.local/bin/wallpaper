#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

wallpaper=$(
    find "$WALLPAPER_DIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        | sed "s|$WALLPAPER_DIR/||" \
        | fuzzel --dmenu --prompt="Wallpaper > "
)

[ -z "$wallpaper" ] && exit 0

awww img "$WALLPAPER_DIR/$wallpaper" \
    --transition-type grow \
    --transition-duration 1 \
    --transition-fps 60
