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

# Mount userdata partition from flash image
mkdir userdata
sudo mount -t ext4 -o ro,noload,offset=`grep userdata partitions_img.txt | awk '{print $2*512}'` flash.img userdata/

# Mount cache partition from flash image
mkdir cache
sudo mount -t ext4 -o ro,noload,offset=`grep cache partitions_img.txt | awk '{print $2*512}'` flash.img cache/

# Mount system partition from flash image
mkdir system
sudo mount -t ext4 -o ro,noload,offset=`grep system partitions_img.txt | awk '{print $2*512}'` flash.img system/

# Generate bodyfile timeline of the userdata partition
fls -r -m "/sdcard/" -o `grep userdata partitions_img.txt | awk '{print $2}'` flash.img > userdata_timeline.txt
mactime -b userdata_timeline.txt -d > userdata_timeline.csv

# Generate bodyfile timeline of the cache partition
fls -r -m "/cache/" -o `grep cache partitions_img.txt | awk '{print $2}'` flash.img > cache_timeline.txt
mactime -b cache_timeline.txt -d > cache_timeline.csv

# Generate bodyfile timeline of the system partition
fls -r -m "/system/" -o `grep system partitions_img.txt | awk '{print $2}'` flash.img > system_timeline.txt
mactime -b system_timeline.txt -d > system_timeline.csv

# Run Photorec, move all files to one folder, and generate hashes
mkdir photorec
photorec /debug /log /d photorec /cmd flash.img partition_none,options,mode_ext2,fileopt,everything,enable,search
mv photorec.*/* photorec/
rmdir photorec.*/
for file in photorec/*; do sha256sum "$file"; done | sort > photorec.sha256

# Find all strings and filter out notifications
strings -n 4 flash.img > strings.txt
# egrep "<p dir=\"ltr\">(.{1,1000})<\/p>" strings.txt > notifications.txt
# grep -Pzo "<p dir=\"ltr\">.*</p>" strings.txt > notifications.txt
grep "<p dir=\"ltr\">" strings.txt > notifications.txt

# Done
echo "DONE, please continue with manual forensic analysis."

