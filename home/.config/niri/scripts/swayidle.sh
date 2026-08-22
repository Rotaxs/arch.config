#!/usr/bin/env bash

# 5 分钟锁屏，10 分钟熄屏，20 分钟休眠
swayidle -w \
    timeout 300  'swaylock -f' \
    timeout 600  'niri msg action power-off-monitors' resume 'niri msg action power-on-monitors' \
    timeout 1200 'systemctl suspend'
