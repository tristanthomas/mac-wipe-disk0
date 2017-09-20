#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Execute this script under macOS Recovery from a bootable USB drive to wipe and repartition disk0.

# Checks if the computer is booted under macOS Recovery
BOOT_MODE=$(system_profiler SPSoftwareDataType 2>/dev/null | grep 'Boot Mode: Booted from installation CD/DVD')
if [[  "${BOOT_MODE}" == "" ]] ; then
	echo "WARNING: This script wipes disk0 if executed. If you intended to wipe disk0, execute this script under macOS Recovery from a bootable macOS USB install drive."
	exit 130
fi

# Locate the recovery partition
RECOVERY_PARTITION_ID=$(diskutil list | grep Apple_Boot | grep disk0 | awk '{print $7}')

# Force unmount disk0 and disk1
diskutil quiet unmountDisk force /dev/disk1
diskutil quiet unmountDisk force /dev/disk0

# Check the status of FileVault
FILEVAULT_ON=$(diskutil cs list | grep disk0 -A 8 | grep 'Conversion Status' | awk -F ' ' '{print $3}')

# If the drive is encrypted with FileVault, just the recovery partition will be wiped.
# If FileValult is not enabled, the entire drive will be wiped.

if [[  "${FILEVAULT_ON}" == "Complete" ]] ; then
	echo "Wiping the recovery partition /dev/"${RECOVERY_PARTITION_ID}
	diskutil zeroDisk /dev/${RECOVERY_PARTITION_ID} || {
		echo "Failed to wipe the recovery partition /dev/"${RECOVERY_PARTITION_ID}
		exit 131
	}
	echo "The recovery partition has been wiped."
else
	echo "FileVault is not enabled, wiping the entire drive."
	diskutil zeroDisk /dev/disk0 || {
		echo "Failed to wipe drive /dev/disk0"
		exit 132
	}
	echo "The entire drive has been wiped."
fi

diskutil partitionDisk /dev/disk0 GPT JHFS+ "Macintosh HD" 0b > /dev/null || {
	echo "Failed to format drive /dev/disk0"
	exit 133
}

# Output the system serial number
system_profiler SPHardwareDataType | grep "Serial Number (system)" | sed -e 's/^ *//'
