#fix tearing
#xrandr --output eDP-1 --set TearFree on

#dimming
# xrandr --output eDP-1 --brightness 0.25
xrandr --output eDP-1 --brightness 0.3

#confirm settings
xrandr --current --verbose

brightnessctl -l
brightnessctl -d "intel_backlight" set 100%
