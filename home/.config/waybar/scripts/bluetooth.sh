#!/bin/bash

active=$(bluetoothctl show | grep "Powered: yes")

if [ -n "$active" ]; then
    bluetoothctl power off
    notify-send "Bluetooth" "Powered off" -t 1500
else
    bluetoothctl power on
    notify-send "Bluetooth" "Powered on" -t 1500
fi
