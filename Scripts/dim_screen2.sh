set -e

Password="sf"

brightnessctl -l
sudo -S <<< "$Password" brightnessctl -d "intel_backlight" set 20%
