#!/bin/bash

current_percentage=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')

step=1

case "$1" in
    up)
        target=$((current_percentage + step))
        if [ "$target" -gt 100 ]; then
            target=100
        fi
        brightnessctl set "${target}%"
        ;;
    down)
        target=$((current_percentage - step))
        if [ "$target" -lt 1 ]; then
            target=1
        fi
        brightnessctl set "${target}%"
        ;;
    set)
        val=$2
        if [ -z "$val" ] || [ "$val" -lt 1 ]; then
            val=1
        elif [ "$val" -gt 100 ]; then
            val=100
        fi
        brightnessctl set "${val}%"
        ;;
    *)
        echo "用法: $0 {up|down|set <1-100>}"
        exit 1
        ;;
esac
