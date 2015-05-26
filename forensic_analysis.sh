#! /bin/bash

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

# Find all strings and perform rough filter for notifications
strings -n 4 flash.img > strings.txt
# egrep "<p dir=\"ltr\">(.{1,1000})<\/p>" strings.txt > notifications.txt
# grep -Pzo "<p dir=\"ltr\">.*</p>" strings.txt > notifications.txt
# grep "<p dir=\"ltr\">" strings.txt > notifications.txt

# Find notifications in the node.db file
# sudo grep -Pzo --binary-files=text '(?<=big_text_html........)[^\x00]*(?=..\x0A)' userdata/data/com.google.android.gms/databases/node.db > notifications.txt
sudo grep -Pzo --binary-files=text '<p dir=\"ltr\"\>[\S\s]*<\/p\>' userdata/data/com.google.android.gms/databases/node.db > notifications.txt

# Done
echo "DONE, please continue with manual forensic analysis."

