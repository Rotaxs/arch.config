#!/bin/bash

# 获取当前处于激活状态的无线连接名称
active_wifi=$(nmcli -t -f NAME,TYPE connection show --active | grep 'wireless' | cut -d: -f1)

if [ -n "$active_wifi" ]; then
    # 如果当前连着网，则安全断开 wlan0 设备（保持图标和射频在线）
    nmcli device disconnect wlan0
    notify-send "Wi-Fi" "已断开连接" -t 1500
else
    # 如果当前没连网，则尝试重新激活最近一次使用的无线连接
    last_wifi=$(nmcli -t -f NAME,TYPE connection show | grep 'wireless' | head -n1 | cut -d: -f1)
    
    if [ -n "$last_wifi" ]; then
        nmcli connection up id "$last_wifi"
        notify-send "Wi-Fi" "Connecting: $last_wifi" -t 1500
    else
        notify-send "Wi-Fi" "Cannot find accessible wifi" -t 1500
    fi
fi
