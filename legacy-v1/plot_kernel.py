import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import glob
import os

# 1. Find the latest csv file
list_of_files = glob.glob('kernel_log_*.csv')
if not list_of_files:
    print("No log files found!")
    exit()
latest_file = max(list_of_files, key=os.path.getctime)

# 2. Load data and convert Timestamp to actual time objects
df = pd.read_csv(latest_file)
df['Timestamp'] = pd.to_datetime(df['Timestamp'], format='%H:%M:%S')

# 3. Create the plot
fig, ax1 = plt.subplots(figsize=(12, 6))

# Plot CPU Load on left axis
ax1.set_xlabel('Time (HH:MM:SS)')
ax1.set_ylabel('CPU Load (%)', color='tab:blue', fontweight='bold')
ax1.plot(df['Timestamp'], df['CPU_Load'], color='tab:blue', label='CPU Load', alpha=0.7)
ax1.tick_params(axis='y', labelcolor='tab:blue')
ax1.grid(True, linestyle='--', alpha=0.6)

# 4. Create a second axis for Temperature
ax2 = ax1.twinx()
ax2.set_ylabel('Temperature (°C)', color='tab:red', fontweight='bold')
ax2.plot(df['Timestamp'], df['Temp_C'], color='tab:red', label='Temp', linewidth=2.5)
ax2.tick_params(axis='y', labelcolor='tab:red')

# 5. NEAT TIME SCALE LOGIC
# Format the x-axis to show Time neatly
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
# This helper automatically decides how many ticks to show so they don't overlap
ax1.xaxis.set_major_locator(mdates.AutoDateLocator())

plt.title(f'Kernel Thermal & Load Analysis\nSource: {latest_file}', fontsize=14)
fig.autofmt_xdate() # Automatically tilts the dates for better fit
plt.tight_layout()

# 6. Save and Finish
plt.savefig('kernel_analysis_neat.png')
print(f"Successfully plotted {len(df)} data points.")
print("Neat graph saved as: kernel_analysis_neat.png")

# Only use plt.show() if you are on a desktop version of Ubuntu
# plt.show()
