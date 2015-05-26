#! /bin/bash

# Mount userdata partition from flash image
mkdir -p userdata
sudo mount -t ext4 -o ro,noload,offset=`grep userdata partitions_img.txt | awk '{print $2*512}'` flash.img userdata/

# Mount cache partition from flash image
mkdir -p cache
sudo mount -t ext4 -o ro,noload,offset=`grep cache partitions_img.txt | awk '{print $2*512}'` flash.img cache/

# Mount system partition from flash image
mkdir -p system
sudo mount -t ext4 -o ro,noload,offset=`grep system partitions_img.txt | awk '{print $2*512}'` flash.img system/
