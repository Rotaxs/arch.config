#!/bin/sh

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
start_script="$config_dir/scripts/start.sh"

output_state() {
    if niri msg --json outputs 2>/dev/null | grep -q '"HDMI-A-1"'; then
        printf dual
    else
        printf single
    fi
}

state=$(output_state)
pkill -x waybar 2>/dev/null || true
"$start_script" &

while sleep 2; do
    next_state=$(output_state)
    [ "$next_state" = "$state" ] && continue
    state="$next_state"

    # Preserve a manually stopped bar across display changes.
    pgrep -x waybar >/dev/null || continue
    pkill -x waybar
    while pgrep -x waybar >/dev/null; do
        sleep 0.1
    done
    "$start_script" &
done
