#! /bin/bash

echo "You have 10 seconds to allow ADB connection"
sudo adb devices
sleep 10
echo "Rebooting device into bootloader... wait 30 seconds..."
fastboot devices
sudo adb reboot bootloader
sleep 30
echo "Loading forensic image... wait 30 seconds..."
fastboot boot twrp-2.8.6.0-dory.img
sleep 10
echo "Dumpping data..."
sudo adb shell "dd if=/dev/block/mmcblk0p21" | pv | dd of=data.img
sudo adb shell "dd if=/dev/block/mmcblk0p20" | pv | dd of=cache.img
