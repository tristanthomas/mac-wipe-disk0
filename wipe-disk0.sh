#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Execute this script under macOS Recovery from a bootable USB drive to wipe and repartition disk0.

# Checks if the computer is booted under macOS Recovery
BOOT_MODE=$(sysctl -a | grep kern.bootsignature | awk '{print $2}')
if [[  "${BOOT_MODE}" != "" ]] ; then
	echo "WARNING: This script wipes disk0 if executed. If you intended to wipe disk0, execute this script under macOS Recovery from a bootable macOS USB install drive."
	exit 130
fi

# Force unmount disk0 and disk1
diskutil quiet unmountDisk force /dev/disk1
diskutil quiet unmountDisk force /dev/disk0

echo "Wiping the internal drive, disk0..."
	diskutil zeroDisk /dev/disk0 || {
		echo "Failed to wipe drive /dev/disk0"
		exit 132
	}
	echo "The entire drive has been wiped."

diskutil partitionDisk /dev/disk0 GPT JHFS+ "Macintosh HD" 0b > /dev/null || {
	echo "Failed to format drive /dev/disk0"
	exit 133
}

# Output the system serial number
SERIAL_NUMBER=$(ioreg -l | grep IOPlatformSerialNumber | awk -F \" '{print $4}')
echo "Serial Number: $SERIAL_NUMBER"
