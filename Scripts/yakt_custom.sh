#!/usr/bin/env bash

# Log create
log-yakt() {
    local message="$1"
    echo "[$(date "+%H:%M:%S")] $message"
}

# Function to log error messages
log-error() {
    local message="$1"
    echo "[$(date "+%H:%M:S")] $message"
}

write(){
    local file="$1"
    local value="$2"

    # Check if the file exists
    if [ ! -f "$file" ]; then
        log-error "Error: File $file does not exist."
        return 1
    fi

    # Make file writable
    chmod +w "$file" 2>/dev/null

    # Write new value, bail out if it fails
    if ! echo "$value" > "$file" 2>/dev/null; then
        log-error "Error: Failed to write to $file."
        return 1
    else
        return 0
    fi
}

# Variables
TP=/dev/stune/top-app/uclamp.max
CP=/dev/cpuset
ML=/sys/module
WT=/proc/sys/vm/watermark_boost_factor
KL=/proc/sys/kernel
VM=/proc/sys/vm
MG=/sys/kernel/mm/lru_gen
BL=/dev/blkio
SCHED_PERIOD="$((6 * 1000 * 1000))"

# Info
log-yakt "Starting YAKT v13"

# Grouping tasks tweak
log-yakt ""
log-yakt "Enabling Sched Auto Group..."
write "$KL/sched_autogroup_enabled" 1
log-yakt "Done."
log-yakt ""

# Tweak scheduler to have less Latency
# Credits to RedHat & tytydraco & KTweak
log-yakt "Tweaking scheduler to reduce latency"
write "$KL/sched_migration_cost_ns" 5000000
write "$KL/sched_latency_ns" "$SCHED_PERIOD"
write "$KL/sched_nr_migrate" 8
sleep 0.5
log-yakt "Done."
log-yakt ""

# Disable CRF by default
log-yakt "Enabling child_runs_first"
write "$KL/sched_child_runs_first" 0
log-yakt "Done."
log-yakt ""

# Ram Tweak
# The stat_interval one reduces jitter (Credits to kdrag0n)
# Credits to RedHat for dirty_ratio
log-yakt "Applying Ram Tweaks"
sleep 0.5
write "$VM/vfs_cache_pressure" 50
write "$VM/stat_interval" 15
write "$VM/compaction_proactiveness" 0
write "$VM/page-cluster" 0
write "$VM/swappiness" 100
write "$VM/dirty_ratio" 30
log-yakt "Applied Ram Tweaks"
log-yakt ""

# Mglru
# Credits to Arter97
log-yakt "Checking if your kernel has mglru support..."
if [ -d "$MG" ]; then
    log-yakt "Found it."
    log-yakt "Tweaking it..."
    write "$MG/min_ttl_ms" 5000
    log-yakt "Done."
    log-yakt ""
else
    log-yakt "Your kernel doesn't support mglru :("
    log-yakt "Aborting it..."
    log-yakt ""
fi

# Set kernel.perf_cpu_time_max_percent to 10
log-yakt "Applying tweak for perf_cpu_time_max_percent"
write "$KL/perf_cpu_time_max_percent" 10
log-yakt "Done."
log-yakt ""

# Disable some scheduler logs/stats
# Also iostats & reduce latency
# Credits to tytydraco
log-yakt "Disabling some scheduler logs/stats"
if [ -e "$KL/sched_schedstats" ]; then
    write "$KL/sched_schedstats" 0
fi
write "$KL/printk" "0        0 0 0"
write "$KL/printk_devkmsg" "off"
for queue in /sys/block/*/queue
do
    write "$queue/iostats" 0
    write "$queue/nr_requests" 64
done
log-yakt "Done."
log-yakt ""

# Disable Timer migration
log-yakt "Disabling Timer Migration"
write "$KL/timer_migration" 0
log-yakt "Done."
log-yakt ""

# Cgroup Tweak
sleep 0.5
if [ -e "$TP" ]; then
    # Uclamp Tweak
    # All credits to @darkhz
    log-yakt ""
    log-yakt "You have uclamp scheduler"
    log-yakt "Applying tweaks for it..."
    sleep 0.3
    for ta in "$CP"/top-app
    do
        write "$ta/uclamp.max" max
        write "$ta/uclamp.min" 10
        write "$ta/uclamp.boosted" 1
        write "$ta/uclamp.latency_sensitive" 1
    done
    for fd in "$CP"/foreground
    do
        write "$fd/uclamp.max" 50
        write "$fd/uclamp.min" 0
        write "$fd/uclamp.boosted" 0
        write "$fd/uclamp.latency_sensitive" 0
    done
    for bd in "$CP"/background
    do
        write "$bd/uclamp.max" max
        write "$bd/uclamp.min" 20
        write "$bd/uclamp.boosted" 0
        write "$bd/uclamp.latency_sensitive" 0
    done
    for sb in "$CP"/system-background
    do
        write "$sb/uclamp.max" 40
        write "$sb/uclamp.min" 0
        write "$sb/uclamp.boosted" 0
        write "$sb/uclamp.latency_sensitive" 0
    done
    sysctl -w kernel.sched_util_clamp_min_rt_default=0
    sysctl -w kernel.sched_util_clamp_min=128
    log-yakt "Done,"
    log-yakt ""
fi

# Enable ECN negotiation by default
# By kdrag0n
log-yakt "Enabling ECN negotiation..."
write "/proc/sys/net/ipv4/tcp_ecn" 1
log-yakt "Done."
log-yakt ""

# Always allow sched boosting on top-app tasks
# Credits to tytydraco
log-yakt "Always allow sched boosting on top-app tasks"
write "$KL/sched_min_task_util_for_colocation" 0
log-yakt "Done."
log-yakt ""

# Watermark Boost Tweak
if [ -e "$WT" ]; then
    log-yakt "Disabling watermark boost..."
    write "$VM/watermark_boost_factor" 0
    log-yakt "Done."
    log-yakt ""
fi

log-yakt "Tweaking read_ahead overall..."
for queue2 in /sys/block/*/queue/read_ahead_kb
do
    write "$queue2" 128
done
log-yakt "Tweaked read_ahead."
log-yakt ""

# Extfrag
# Credits to @tytydraco
log-yakt "Increasing fragmentation index..."
write "$VM/extfrag_threshold" 750
sleep 0.5
log-yakt "Done."
log-yakt ""

# Disable Spi CRC
if [ -d "$ML/mmc_core" ]; then
    log-yakt "Disabling Spi CRC"
    write "$ML/mmc_core/parameters/use_spi_crc" 0
    log-yakt "Done."
    log-yakt ""
fi

# Zswap Tweak
log-yakt "Checking if your kernel supports zswap.."
if [ -d "$ML/zswap" ]; then
    log-yakt "Your kernel supports zswap, tweaking it.."
    write "$ML/zswap/parameters/compressor" lz4
    log-yakt "Set your zswap compressor to lz4 (Fastest compressor)."
    write "$ML/zswap/parameters/zpool" zsmalloc
    log-yakt "Set your zpool compressor to zsmalloc."
    log-yakt "Tweaked!"
    log-yakt ""
else
    log-yakt "Your kernel doesn't support zswap, aborting it..."
    log-yakt ""
fi

# Enable Power Efficient
log-yakt "Enabling Power Efficient..."
write "$ML/workqueue/parameters/power_efficient" 1
log-yakt "Done."
log-yakt ""

log-yakt "The Tweak is done enjoy :)"
