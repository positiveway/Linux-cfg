sudo cpupower frequency-set --governor performance
sudo cpupower set -b 0
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

sudo iwconfig wlp1s0 power off
