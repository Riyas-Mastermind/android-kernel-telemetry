# 🐧 Android Kernel Telemetry: Live Command Center
### High-Fidelity Hardware Diagnostics for Snapdragon 626 (Samsung Galaxy C7 Pro)

[![Docker Support](https://img.shields.io/badge/Docker-Supported-blue?logo=docker)](https://www.docker.com/)
[![Kernel](https://img.shields.io/badge/Kernel-3.18.71-green?logo=linux)](https://kernel.org)
[![Python](https://img.shields.io/badge/Powered%20By-Streamlit-FF4B4B?logo=streamlit)](https://streamlit.io)

This project is a "bare-metal" monitoring suite that bypasses standard Android APIs to interface directly with the **Linux Kernel virtual filesystems (`/proc` and `/sys`)**. It provides real-time, high-frequency telemetry visualization through a Dockerized Web Dashboard.



## 🔍 Project Overview
The suite establishes a low-level bridge via ADB to pull raw hardware states. It is designed to analyze **Thermal Throttling**, **Interactive Governor behavior**, and **Power Delivery** performance under controlled stress-test conditions.

### Key Metrics Monitored:
* **SoC Temperature:** Real-time thermistor data from `thermal_zone1`.
* **Big.LITTLE Frequencies:** Synchronized tracking of Efficiency (Cortex-A53) and Performance clusters.
* **Battery Dynamics:** High-resolution Voltage monitoring to detect "Voltage Sag" under load.
* **Memory Pressure:** Live calculation of used vs. available RAM via `/proc/meminfo`.
* **Process Analysis:** Real-time tracking of top resource-consuming PIDs.

---

## 🛠 Technical Architecture
The suite is containerized to ensure a stable environment regardless of the host OS.

* **Backend:** Python 3.10 + ADB (Android Debug Bridge)
* **Frontend:** Streamlit (Reactive Web Framework)
* **Visualization:** Plotly (Interactive Dual-Axis Graphs)
* **Deployment:** Docker with USB Passthrough

---

## 🚀 Deployment Guide

### 1. Prerequisites
* Samsung Galaxy C7 Pro (or any Snapdragon 626 device)
* USB Debugging Enabled
* Docker installed on Ubuntu/Linux host

### 2. Build the Environment
```bash
# Clone the repository
git clone [https://github.com/Riyas-Mastermind/c7-telemetry-suite.git]
cd c7-telemetry-suite

# Build the Docker Image
docker build -t c7-telemetry-suite .
```

### 3. Launch the Command Center
Ensure the phone is connected via USB and run the container with privileged access to the USB bus:
```bash
docker run -d \
    --name c7_monitor \
    --privileged \
    -v /dev/bus/usb:/dev/bus/usb \
    -p 8501:8501 \
    c7-telemetry-suite
```

### 4. Access the Dashboard
Open your browser and navigate to:
http://localhost:8501

---

## 📊 Methodology: The Thermal Lag Test
The suite is designed to execute a 4-phase experimental stress test to analyze kernel behavior:

1. **Baseline Phase:** Observe ambient idle states (~31°C - 33°C) to establish a thermal floor.
2. **Saturation Phase:** Trigger high-intensity tasks (e.g., 4K Video recording) to force CPU frequencies to the **2.2GHz** maximum.
3. **Throttling Analysis:** Observe the Kernel's "Step Function" drop in frequency as the SoC approaches the **50°C** thermal trip point.
4. **Recovery Phase:** Measure the passive cooling efficiency through the thermal dissipation curve once the load is removed.

---

## 🛠 Control Panel Features
* **Live Metrics:** High-visibility "Metric Cards" providing real-time data for SoC Temp, CPU Frequencies, and Battery Voltage.
* **Dual-Axis Plotting:** A synchronized timeline correlateing Temperature vs. Frequency to visualize throttling in real-time.
* **Data Persistence:** Integrated sidebar feature to export all captured session telemetry to a **CSV file** for offline academic analysis.
* **Process Tracking:** A live-updating table showcasing the top 5 memory-hungry processes currently managed by the kernel.

---

## ⚖ License
Distributed under the MIT License. See the [LICENSE](LICENSE) file for more information.
