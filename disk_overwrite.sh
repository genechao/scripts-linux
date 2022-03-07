#!/bin/bash
# Usage: disk_overwrite.sh device
# By: Gene Chao - Last updated: 3/7/2022
REPEAT=2
PAUSE=300

if [ -z "$1" ]; then
	echo "Usage: $0 device"
	return 1 2>/dev/null
	exit 1
fi

DEV=$1
if [ ! -b "$DEV" ]; then
	echo "Error: $DEV is not a block device"
	return 1 2>/dev/null
	exit 1
fi
SIZE=$(blockdev --getsize64 $DEV 2>/dev/null)
if [ -z $SIZE ]; then
	echo "Error: Unable to get size of $DEV"
	return 1 2>/dev/null
	exit 1
fi
LOG=disk_overwrite_$(basename $DEV).log

for n in $(seq 1 $REPEAT); do

	echo "***" n=$n

	perl -e 'while(1){print"disk_overwrite!"x1000}' | dd of=$DEV bs=4K conv=sync,noerror status=progress
	pv $DEV -petar --size $SIZE --stop-at-size | md5sum -b - | tee -a "$LOG"
	cat /dev/zero | dd of=$DEV bs=4K conv=sync,noerror status=progress
	pv $DEV -petar --size $SIZE --stop-at-size | md5sum -b - | tee -a "$LOG"

	if [ $n -lt $REPEAT ]; then
		echo "***" Pausing for $PAUSE seconds...
		sleep $PAUSE
		echo
	fi

done
