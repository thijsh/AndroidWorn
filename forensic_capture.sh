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
sudo adb shell "dd if=/dev/block/mmcblk0" bs=512 conv=notrunc,noerror | pv -s 3909091432 | perl -pe 's/\x0D\x0A/\x0A/g' | dd of=flash.img
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

# Mount userdata partition from flash image
mkdir userdata
sudo mount -t ext4 -o ro,noload,offset=`grep userdata partitions_img.txt | awk '{print $2*512}'` flash.img userdata/

# Mount cache partition from flash image
mkdir cache
sudo mount -t ext4 -o ro,noload,offset=`grep cache partitions_img.txt | awk '{print $2*512}'` flash.img cache/

# Run Photorec
mkdir photorec
photorec /debug /log /d photorec /cmd flash.img partition_none,options,mode_ext2,fileopt,everything,enable,search

