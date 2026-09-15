#!/usr/bin/env bash

# 仅电池供电时：5 分钟锁屏，10 分钟熄屏，20 分钟挂起。
on_battery() {
    local supply type online present
    local battery_found=false

    for supply in /sys/class/power_supply/*; do
        [[ -e "$supply" ]] || continue
        IFS= read -r type < "$supply/type" || return 1
        if [[ "$type" == Battery ]]; then
            if [[ -e "$supply/present" ]]; then
                IFS= read -r present < "$supply/present" || return 1
                [[ "$present" == 1 ]] || continue
            fi
            battery_found=true
        else
            IFS= read -r online < "$supply/online" || return 1
            [[ "$online" == 0 ]] || return 1
        fi
    done

    [[ "$battery_found" == true ]]
}

if [[ "${1:-}" == --on-battery ]]; then
    shift
    if on_battery; then
        exec "$@"
    fi
    exit 0
fi

script_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$(basename -- "${BASH_SOURCE[0]}")"
swayidle -w \
    timeout 300  "bash \"$script_path\" --on-battery hyprlock" \
    timeout 600  "bash \"$script_path\" --on-battery niri msg action power-off-monitors" resume 'niri msg action power-on-monitors' \
    timeout 1200 "bash \"$script_path\" --on-battery systemctl suspend"
