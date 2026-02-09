#!/bin/bash

# --- STYLING ---
BOLD=$(tput bold); NORM=$(tput sgr0); GREEN=$(tput setaf 2); CYAN=$(tput setaf 6)

# --- CSV SETUP ---
LOG_FILE="kernel_log_$(date +%Y%m%d_%H%M%S).csv"
echo "Timestamp,CPU_Load,Freq0_MHz,Freq7_MHz,RAM_Used_MB,Temp_C,Battery_Perc,Voltage_mV" > "$LOG_FILE"

# --- VARIABLES FOR CPU CALC ---
PREV_TOTAL=0; PREV_IDLE=0

get_cpu_usage() {
    CPU_LINE=$(adb shell cat /proc/stat | head -n 1)
    read -r _ USER NICE SYS IDLE IOW IRQ SIRQ _ <<< "$CPU_LINE"
    IDLE_TIME=$((IDLE + IOW))
    TOTAL_TIME=$((USER + NICE + SYS + IDLE + IOW + IRQ + SIRQ))
    DIFF_IDLE=$((IDLE_TIME - PREV_IDLE))
    DIFF_TOTAL=$((TOTAL_TIME - PREV_TOTAL))
    [ $DIFF_TOTAL -ne 0 ] && USAGE=$(( (100 * (DIFF_TOTAL - DIFF_IDLE)) / DIFF_TOTAL )) || USAGE=0
    PREV_TOTAL=$TOTAL_TIME; PREV_IDLE=$IDLE_TIME
    echo $USAGE
}

echo "${CYAN}Logging kernel data to: ${BOLD}$LOG_FILE${NORM}"
echo "Press [CTRL+C] to stop logging and save file."

while true; do
    # Fetch Data
    LOAD=$(get_cpu_usage)
    FREQ0=$(($(adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null) / 1000))
    FREQ7=$(($(adb shell cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq 2>/dev/null) / 1000))
    MEM_TOTAL=$(adb shell grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_FREE=$(adb shell grep MemFree /proc/meminfo | awk '{print $2}')
    MEM_USED_MB=$(( (MEM_TOTAL - MEM_FREE) / 1024 ))
    TEMP_C=$(adb shell cat /sys/class/thermal/thermal_zone1/temp 2>/dev/null)
    BATT=$(adb shell cat /sys/class/power_supply/battery/capacity 2>/dev/null)
    VOLT=$(($(adb shell cat /sys/class/power_supply/battery/voltage_now 2>/dev/null) / 1000))
    TIME=$(date +%H:%M:%S)

    # 1. Write to CSV file
    echo "$TIME,$LOAD,$FREQ0,$FREQ7,$MEM_USED_MB,$TEMP_C,$BATT,$VOLT" >> "$LOG_FILE"

    # 2. Print simple status to screen so you know it's working
    echo "[$TIME] Recorded: Load: ${LOAD}% | Temp: ${TEMP_C}°C | RAM: ${MEM_USED_MB}MB"

    sleep 1
done
