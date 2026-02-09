# Use a lightweight Python image
FROM python:3.10-slim

# Install ADB and system dependencies
RUN apt-get update && apt-get install -y \
    android-tools-adb \
    usbutils \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy and install Python requirements
# (We install them directly here to keep it simple)
RUN pip install --no-cache-dir streamlit pandas plotly

# Copy your dashboard script into the container
COPY dashboard.py .

# Streamlit uses port 8501 by default
EXPOSE 8501

# Run the dashboard
CMD ["streamlit", "run", "dashboard.py", "--server.address=0.0.0.0"]
