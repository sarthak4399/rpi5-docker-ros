#!/bin/bash

# Detect all USB devices
for dev in $(ls /dev/bus/usb/*/*); do
  chmod 666 $dev || true
done

