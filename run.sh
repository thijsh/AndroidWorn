#! /bin/bash

# Perform forensic capture
./forensic_capture.sh

# Mount partitions
./mount_flash.sh

# Perform forensic analysis
./forensic_analysis.sh
