#! /bin/bash

# Store script dir
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Start dump perparation (reboot into forensic image)
echo "You have 10 seconds to allow ADB connection..."
sudo adb devices
sleep 10
echo "Rebooting device into bootloader... wait 10 seconds..."
sudo fastboot devices
sudo adb reboot bootloader
sleep 10
echo "Loading forensic image... wait 10 seconds..."
sudo fastboot boot "$DIR/twrp-2.8.6.0-dory.img"
sleep 10

# Perform the actual dump
echo "Dumping data..."
sudo adb shell "umount /cache"
sudo adb shell "umount /data"
sudo adb shell "umount /sdcard"
BYTES=$(sudo adb shell "blockdev --getsize64 /dev/block/mmcblk0" | sed 's/[^0-9]*//g')
echo "Android Wear reported flash size is: $BYTES"
sudo adb shell "dd if=/dev/block/mmcblk0" bs=512 conv=notrunc,noerror | pv -s $BYTES | perl -pe 's/\x0D\x0A/\x0A/g' | dd of=flash.img
sha256sum flash.img > flash.sha256
# sudo adb shell "dd if=/dev/block/mmcblk0p21" | pv -s 3258974312 | perl -pe 's/\x0D\x0A/\x0A/g' | dd of=data.img
# sha256sum data.img > data.sha256
# sudo adb shell "dd if=/dev/block/mmcblk0p20" | pv -s 268435558 | perl -pe 's/\x0D\x0A/\x0A/g'| dd of=cache.img
# sha256sum cache.img > cache.sha256

# Partition dump ADB + compared to img partitions
echo "REPORTED PARTITIONS BY ANDROID DEBUG BRIDGE:" > partitions_adb.txt
sudo adb shell "fdisk -l /dev/block/mmcblk0" >> partitions_adb.txt
echo "DUMPED PARTITIONS IN DD IMAGE:" > partitions_img.txt
sudo gdisk -l flash.img >> partitions_img.txt

# Calculate hashes per partition (NOTE: this dd command can be used to extract an individual partition)
echo "Calculating hashes for individual partitions..."
dd if=flash.img bs=512 skip=`grep userdata partitions_img.txt | awk '{print $2}'` count=`grep userdata partitions_img.txt | awk '{print $3-$2+1}'` | sha256sum >> userdata.sha256
dd if=flash.img bs=512 skip=`grep cache partitions_img.txt | awk '{print $2}'` count=`grep cache partitions_img.txt | awk '{print $3-$2}'` | sha256sum >> cache.sha256
dd if=flash.img bs=512 skip=`grep system partitions_img.txt | awk '{print $2}'` count=`grep system partitions_img.txt | awk '{print $3-$2}'` | sha256sum >> system.sha256
