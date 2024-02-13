#!/usr/bin/env bash

#xmodmap -e "pointer = 1 1 3 5 4 7 6 8 9 10 11 12"

# xinput set-prop "IMG4100:00 4D49:4150 Touchpad" "libinput Disable While Typing Enabled" 0

xinput list
DeviceName="IMG4100:00 4D49:4150 Touchpad"

xinput set-prop "$DeviceName" "libinput Tapping Enabled" 1
xinput set-prop "$DeviceName" "libinput Disable While Typing Enabled" 1
xinput set-prop "$DeviceName" "libinput Tapping Drag Enabled" 1
xinput set-prop "$DeviceName" "libinput Left Handed Enabled" 0
xinput set-prop "$DeviceName" "libinput Middle Emulation Enabled" 0
xinput set-prop "$DeviceName" "libinput Natural Scrolling Enabled" 0
xinput set-prop "$DeviceName" "libinput High Resolution Wheel Scroll Enabled" 1
xinput set-prop "$DeviceName" "libinput Scrolling Pixel Distance" 15
xinput set-prop "$DeviceName" "libinput Accel Speed" 0.0
xinput set-prop "$DeviceName" "libinput Click Method Enabled" 0, 1
# xinput set-prop "$DeviceName" "libinput Accel Profile Enabled" 1, 0

xinput list-props "$DeviceName"
