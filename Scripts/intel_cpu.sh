#!/usr/bin/env bash

# https://www.kernel.org/doc/html/v6.7/admin-guide/pm/intel_pstate.html
# https://docs.kernel.org/admin-guide/pm/cpufreq.html
# https://www.reddit.com/r/linux_gaming/comments/rvd864/comment/hr8ciu8/?utm_source=share&utm_medium=web2x&context=3
# https://askubuntu.com/questions/619875/disabling-intel-turbo-boost-in-ubuntu

set -e

P_CORE_MAX_FREQ=4000000
E_CORE_MAX_FREQ=3700000

for i in {0..15}
do
cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
done

for i in {0..7}
do
echo "$P_CORE_MAX_FREQ" | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
done

for i in {8..15}
do
echo "$E_CORE_MAX_FREQ" | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
done

cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# sudo cpupower set --perf-bias 15

exit

echo "1" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
echo "0" | sudo tee /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost
