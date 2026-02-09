#!/bin/bash

# --- STYLING ---
BOLD=$(tput bold)
NORM=$(tput sgr0)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
REVERSE=$(tput rev)

# --- VARIABLES FOR CPU CALC ---
PREV_TOTAL=0
PREV_IDLE=0

get_cpu_usage() {
    CPU_LINE=$(adb shell cat /proc/stat | head -n 1)
    USER=$(echo $CPU_LINE | awk '{print $2}')
    NICE=$(echo $CPU_LINE | awk '{print $3}')
    SYSTEM=$(echo $CPU_LINE | awk '{print $4}')
    IDLE=$(echo $CPU_LINE | awk '{print $5}')
    IOWAIT=$(echo $CPU_LINE | awk '{print $6}')
    IRQ=$(echo $CPU_LINE | awk '{print $7}')
    SOFTIRQ=$(echo $CPU_LINE | awk '{print $8}')

    IDLE_TIME=$((IDLE + IOWAIT))
    TOTAL_TIME=$((USER + NICE + SYSTEM + IDLE + IOWAIT + IRQ + SOFTIRQ))

    DIFF_IDLE=$((IDLE_TIME - PREV_IDLE))
    DIFF_TOTAL=$((TOTAL_TIME - PREV_TOTAL))
    
    if [ $DIFF_TOTAL -ne 0 ]; then
        USAGE=$(( (100 * (DIFF_TOTAL - DIFF_IDLE)) / DIFF_TOTAL ))
    else
        USAGE=0
    fi

    PREV_TOTAL=$TOTAL_TIME
    PREV_IDLE=$IDLE_TIME
    echo $USAGE
}

# --- MAIN MONITORING LOOP ---
clear
echo "${CYAN}Starting ADB Kernel Bridge...${NORM}"

while true; do
    # 1. Fetch CPU Stats
    LOAD=$(get_cpu_usage)
    FREQ0=$(adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)
    FREQ7=$(adb shell cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq 2>/dev/null)
    GOV=$(adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)

    # 2. Fetch Memory Stats
    MEM_TOTAL=$(adb shell grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_FREE=$(adb shell grep MemFree /proc/meminfo | awk '{print $2}')
    MEM_USED=$((MEM_TOTAL - MEM_FREE))
    MEM_PERC=$(( (MEM_USED * 100) / MEM_TOTAL ))

    # 3. Fetch Thermal & Battery (Using Zone 1 as verified)
    TEMP_C=$(adb shell cat /sys/class/thermal/thermal_zone1/temp 2>/dev/null)
    BATT=$(adb shell cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    VOLT=$(adb shell cat /sys/class/power_supply/battery/voltage_now 2>/dev/null)

    # 4. Kernel Info
    KVER=$(adb shell uname -r)

    # --- RENDER DASHBOARD ---
    clear
    echo "${REVERSE}${BOLD}  ADB KERNEL MONITOR: SAMSUNG GALAXY C7 PRO (Android 8.0)  ${NORM}"
    echo ""
    
    # CPU Header
    echo "${BOLD}[CPU CLUSTER]${NORM}"
    if [ "$LOAD" -gt 70 ]; then LOAD_COL=$RED; else LOAD_COL=$GREEN; fi
    echo "  Total Load:    ${LOAD_COL}${LOAD}%${NORM}"
    echo "  Governor:      ${YELLOW}${GOV}${NORM}"
    echo "  Core 0 (Min):  $((FREQ0 / 1000)) MHz"
    echo "  Core 7 (Max):  $((FREQ7 / 1000)) MHz"
    echo ""

    # Memory Header
    echo "${BOLD}[MEMORY]${NORM}"
    echo "  RAM Usage:     ${MEM_PERC}% ($((MEM_USED / 1024)) MB / $((MEM_TOTAL / 1024)) MB)"
    echo ""

    # Health Header
    echo "${BOLD}[THERMAL & POWER]${NORM}"
    if [ "$TEMP_C" -gt 45 ]; then T_COL=$RED; else T_COL=$CYAN; fi
    echo "  System Temp:   ${T_COL}${TEMP_C}°C${NORM}"
    echo "  Battery:       ${GREEN}${BATT}%${NORM} ($((VOLT / 1000)) mV)"
    echo ""

    # Bottom Info Bar
    echo "${BOLD}==========================================================${NORM}"
    echo " Kernel: $KVER"
    echo " Status: ${GREEN}Connected via ADB${NORM}          Press [CTRL+C] to stop"
    echo "${BOLD}==========================================================${NORM}"

    sleep 1
done
