#!/bin/sh

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"

if niri msg --json outputs 2>/dev/null | grep -q '"HDMI-A-1"'; then
    profile="config-dual.jsonc"
else
    profile="config-single.jsonc"
fi

exec waybar -c "$config_dir/$profile" -s "$config_dir/style.css"
