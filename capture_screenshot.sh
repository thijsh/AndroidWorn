#! /bin/bash

# Use this small script to capture a screenshot in TWRP or any other bootloader that has root acces, but no screenshot utitity.
# The screen size is optimized for the image buffer of the LG G Watch.

# Check for ADB connection
sudo adb devices

# Get the image buffer from the device
sudo adb pull /dev/graphics/fb0

# Convert the image buffer to PNG
convert -size 288x280 -depth 8 rgba:fb0 fb0.png

# Crop the image to exclude black alignment border
convert -crop 280x280-0+0 fb0-1.png fb0-1.png

# Rename the correct screenshot (big buffer results in multiple images)
mv fb0-1.png ${1:-screenshot.png}

# Clean up
rm -f fb0*
