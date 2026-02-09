import streamlit as st
import pandas as pd
import subprocess
import time
import plotly.graph_objects as go
from datetime import datetime

# --- 1. INITIALIZATION ---
# We use 'data' consistently throughout the app
if 'data' not in st.session_state:
    st.session_state.data = pd.DataFrame(columns=["timestamp", "temperature", "freq_little", "freq_big", "voltage"])

# --- 2. CONFIGURATION ---
ADB_PATH = "adb"
HISTORY_LEN = 60 

# --- 3. HELPER FUNCTIONS ---
def get_adb_data(command):
    try:
        # Using a timeout to prevent the app from freezing if ADB hangs
        result = subprocess.check_output(f"{ADB_PATH} shell {command}", shell=True, timeout=2)
        return result.decode("utf-8").strip()
    except:
        return "0"

def get_telemetry():
    # Thermal
    temp_raw = get_adb_data("cat /sys/class/thermal/thermal_zone1/temp")
    try:
        temp = float(temp_raw)
        if temp > 1000: temp /= 1000
    except: temp = 0.0

    # CPU Freq
    f_low = get_adb_data("cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
    f_high = get_adb_data("cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq")
    
    # Battery
    v_raw = get_adb_data("cat /sys/class/power_supply/battery/voltage_now")
    try:
        voltage = float(v_raw)
        if voltage > 1000000: voltage /= 1000000
        elif voltage > 1000: voltage /= 1000
    except: voltage = 0.0
    
    return {
        "timestamp": datetime.now(),
        "temperature": temp,
        "freq_little": int(f_low) / 1000 if f_low.isdigit() else 0,
        "freq_big": int(f_high) / 1000 if f_high.isdigit() else 0,
        "voltage": round(voltage, 3)
    }

# --- 4. DASHBOARD UI SETUP ---
st.set_page_config(page_title="Snapdragon 626 Telemetry", layout="wide")
st.title("🐧 Android Kernel Telemetry: Live Command Center")

# --- 5. SIDEBAR (Placed outside the loop so it's always visible) ---
st.sidebar.title("🛠 Control Panel")
st.sidebar.info(f"Connected to: {get_adb_data('getprop ro.product.model')}")

if not st.session_state.data.empty:
    st.sidebar.success(f"Captured {len(st.session_state.data)} data points")
    csv = st.session_state.data.to_csv(index=False).encode('utf-8')
    st.sidebar.download_button(
        label="📥 Download Telemetry Log (.csv)",
        data=csv,
        file_name=f"c7_telemetry_{datetime.now().strftime('%H%M%S')}.csv",
        mime='text/csv',
    )
else:
    st.sidebar.warning("No data captured yet. Press Start.")

# --- 6. MAIN LAYOUT ELEMENTS ---
col1, col2, col3, col4 = st.columns(4)
metric_temp = col1.empty()
metric_little = col2.empty()
metric_big = col3.empty()
metric_volt = col4.empty()

st.subheader("Real-Time Thermal & Frequency Analysis")
chart_placeholder = st.empty()

# --- 7. MONITORING LOOP ---
if st.button('Start Monitoring'):
    # Note: Streamlit buttons don't work well as 'Stop' toggles inside while loops 
    # without advanced state handling, but this will run until you refresh or the app reruns.
    while True:
        new_data = get_telemetry()
        new_row = pd.DataFrame([new_data])
        
        # Append to session state
        st.session_state.data = pd.concat([st.session_state.data, new_row], ignore_index=True)
        
        # Keep recent history
        if len(st.session_state.data) > HISTORY_LEN:
            st.session_state.data = st.session_state.data.iloc[-HISTORY_LEN:]
            
        # Update Big Metrics
        metric_temp.metric("SoC Temp", f"{new_data['temperature']} °C")
        metric_little.metric("Little Core", f"{new_data['freq_little']} MHz")
        metric_big.metric("Big Core", f"{new_data['freq_big']} MHz")
        metric_volt.metric("Battery", f"{new_data['voltage']} V")

        # Update Plotly Chart
        fig = go.Figure()
        fig.add_trace(go.Scatter(
            x=st.session_state.data['timestamp'], 
            y=st.session_state.data['temperature'],
            name="Temp (°C)", line=dict(color='firebrick', width=3)
        ))
        fig.add_trace(go.Scatter(
            x=st.session_state.data['timestamp'], 
            y=st.session_state.data['freq_big'],
            name="Big Core (MHz)", line=dict(color='royalblue', width=2),
            yaxis="y2"
        ))

        fig.update_layout(
            yaxis=dict(title="Temperature (°C)", range=[20, 60]),
            yaxis2=dict(title="Frequency (MHz)", overlaying="y", side="right", range=[0, 2500]),
            height=500,
            legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1)
        )

        chart_placeholder.plotly_chart(fig, use_container_width=True)
        time.sleep(1)
