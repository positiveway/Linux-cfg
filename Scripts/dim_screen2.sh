#!/usr/bin/env bash

Password="sf"

#fix tearing
#xrandr --output eDP-1 --set TearFree on

#dimming
xrandr --output eDP-1 --brightness 0.25
# xrandr --output eDP-1 --brightness 0.2
# xrandr --output eDP-1 --brightness 0.5
# xrandr --output eDP-1 --brightness 0.4

#confirm settings
xrandr --current --verbose

brightnessctl -l
sudo -S <<< "$Password" brightnessctl -d "intel_backlight" set 100%
