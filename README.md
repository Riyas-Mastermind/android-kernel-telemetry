# 🐧 Android Kernel Telemetry: Live Command Center
### High-Fidelity Hardware Diagnostics for Snapdragon 626 (Samsung Galaxy C7 Pro)

[![Docker Support](https://img.shields.io/badge/Docker-Supported-blue?logo=docker)](https://www.docker.com/)
[![Kernel](https://img.shields.io/badge/Kernel-3.18.71-green?logo=linux)](https://kernel.org)
[![Python](https://img.shields.io/badge/Powered%20By-Streamlit-FF4B4B?logo=streamlit)](https://streamlit.io)

## 🚀 Project Overview
This project is a **"bare-metal" monitoring suite** that bypasses standard Android APIs to interface directly with the **Linux Kernel virtual filesystems** (`/proc` and `/sys`). By establishing a low-level bridge via ADB, this suite pulls raw hardware states to provide real-time, high-frequency telemetry visualization through a Dockerized Web Dashboard.

---

## 📂 Repository Structure
The project is organized into two primary development phases to separate modern visualization from historical logging:

### 📁 [c7-dashboard/](./c7-dashboard)
**The Modern Interface.** This folder contains the current, Dockerized version of the project:
* **`dashboard.py`**: The main application logic using Streamlit for UI and Plotly for interactive graphing.
* **`Dockerfile`**: Defines the environment, installing Python 3.10 and ADB for a "plug-and-play" deployment.
* **Key Metrics**: Real-time SoC Temperature, Big/Little Core Frequencies, Battery Voltage, and RAM Usage percentage.

### 📁 [legacy-v1/](./legacy-v1)
**Historical Root & Scripts.** This folder preserves the original shell-based foundation of the project:
* **Shell Scripts**: Original logging tools like `c7_logger.sh` and `monitor_c7.sh`.
* **Data Logs**: Historical CSV records of kernel telemetry captured during early development.
* **Analysis**: Original Python plotting scripts used for static data visualization.

---

## 💡 Applications & Use Cases
This suite is designed for developers, kernel maintainers, and hardware enthusiasts to analyze:

* **Thermal Throttling Analysis**: Correlate high CPU loads with temperature spikes to find the exact "trip point" where the kernel lowers clock speeds.
* **Battery Health & Power Delivery**: Monitor voltage sag under heavy processing loads to evaluate battery aging and discharge curves.
* **Memory Management Pressure**: Watch how the **Low Memory Killer (LMK)** daemon responds to high RAM usage by tracking the top 5 most resource-heavy processes.
* **Governor Optimization**: Verify if the interactive CPU governor is scaling frequencies correctly based on touch input or background tasks.

---

## 📊 Methodology: The Thermal Lag Test
The suite is optimized to execute a 4-phase experimental stress test:
1. **Baseline Phase**: Establish a thermal floor by observing ambient idle states (~31°C - 33°C).
2. **Saturation Phase**: Trigger high-intensity tasks (like 4K recording) to force frequencies to 2.2GHz.
3. **Throttling Phase**: Observe the kernel's frequency "Step Functions" as the SoC nears 50°C.
4. **Recovery Phase**: Measure the passive cooling efficiency of the Galaxy C7 Pro's chassis.

---

## ⚖ License
Distributed under the MIT License. See LICENSE for more information.
