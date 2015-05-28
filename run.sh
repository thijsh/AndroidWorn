#! /bin/bash

# Store script dir
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Perform forensic capture
$DIR/forensic_capture.sh

# Mount partitions
$DIR/mount_flash.sh

# Perform forensic analysis
$DIR/forensic_analysis.sh
