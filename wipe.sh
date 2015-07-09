#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Execute this script under OS X Recovery from a bootable USB drive to wipe and repartition disk0.

# Locate the recovery partition
RECOVERY_PARTITION_ID=$(diskutil list | grep Apple_Boot | grep disk0 | awk '{print $7}')

# Check the status of FileVault
FILEVAULT_ON=$(diskutil cs list | grep disk0 -A 11 | grep "Fully Secure" | sed 's/\|//g' | awk '{print $3}')

# If the drive is encrypted with FileVault, just the recovery partition will be wiped.
# If FileValult is not enabled, the entire drive will be wiped.

if [[  "${FILEVAULT_ON}" == "Yes" ]] ; then
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

diskutil partitionDisk /dev/disk0 GPT JHFS+ "Mac HD" 0b || {
	echo "Failed to format drive /dev/disk0"
	exit 133
}

echo "The drive has been formatted."
