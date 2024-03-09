#!/usr/bin/env bash

set -e

DeviceName="IMG4100:00 4D49:4150 Touchpad"
xinput set-prop "$DeviceName" "libinput Disable While Typing Enabled" 0
xinput list-props "$DeviceName"

sudo ./intel_cpu.sh
sudo ./intel_gpu.sh

# sudo ./yakt_custom.sh
