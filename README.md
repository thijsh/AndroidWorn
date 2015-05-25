# Android Worn

Project to find all possible forensic traces left on an Android Wear device.

Run 'forensic_capture.sh' to perform the following forensic capture steps:
- Verify ADB connection to the Android Wear device
- Reboot the device into the bootloader
- Fastboot into TWRP OS (NOTE: the LG G Watch (dory) image is default, for other devices download the image at: https://twrp.me/Devices/)
- Perform a DD of the entire flash storage
- List all partitions as reported by ADB and as found in the image
- Calculate hashes of the entire flash.img as well as the most important partitions
- Mount the userdata, cache, and system partitions
- Generate forensic timelines for the userdata, cache, and system partitions
- Run Photorec (deleted) file recovery on the userdata partition
- Calculate hashes of all the recovered files
