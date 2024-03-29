#!/usr/bin/env bash

# https://askubuntu.com/questions/930372/setting-intel-gpu-limits-in-ubuntu-17-04-no-longer-works
# https://manpages.ubuntu.com/manpages/noble/man1/intel_gpu_frequency.1.html

set -e

# MAX_FREQ=1100
MAX_FREQ=1300

sudo cat /sys/kernel/debug/dri/0/i915_rps_boost_info
cat /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw
sudo intel_gpu_frequency -g

sudo intel_gpu_frequency -c max=$MAX_FREQ
echo "$MAX_FREQ" | sudo tee /sys/class/drm/card0/gt_max_freq_mhz
echo "$MAX_FREQ" | sudo tee /sys/class/drm/card0/gt_boost_freq_mhz
# echo 30000000 | sudo tee /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw
sudo intel_gpu_frequency -g
