# Contents of scripts/detect_usb.sh
#!/bin/bash
echo "USB Devices:"
lsusb
echo -e "\nUSB Device Details:"
for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
    syspath="${sysdevpath%/dev}"
    devname="$(udevadm info -q name -p $syspath)"
    if [[ "$devname" == "bus/"* ]]; then continue; fi
    eval "$(udevadm info -q property --export -p $syspath)"
    echo "/dev/$devname - $ID_VENDOR_ID:$ID_MODEL_ID"
done

# Contents of scripts/entrypoint.sh
#!/bin/bash
set -e

# Setup udev (needed for USB and GPIO)
if [ -e "/dev/gpiochip0" ]; then
    chmod 666 /dev/gpiochip0
fi

# Detect USB devices
/usr/local/bin/detect_usb.sh

# Source ROS 2
source "/opt/ros/humble/setup.bash"

# Execute the command passed to docker run
exec "$@"