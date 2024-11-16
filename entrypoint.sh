#!/bin/bash

# Source ROS 2 Humble setup
source /opt/ros/humble/setup.bash

# Export DISPLAY for GUI applications
export DISPLAY=${DISPLAY}
export QT_X11_NO_MITSHM=1

# Allow access to X server
xhost +local:docker

# Ensure USB devices are accessible
/usr/local/bin/detect_usb.sh

exec "$@"

