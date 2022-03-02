#!/bin/bash
# smartctl check
# By: Gene Chao - Last updated: 1/26/2018

if [ -z $2 ]; then
	echo "Usage: $0 device short/long"
	return 2>/dev/null
	exit
fi

in_progress_string="in progress..."
log_file="smartctl_check.log"

smartctl -t "$2" "$1"
if [ $? != 0 ]; then
	return 2>/dev/null
	exit
fi

echo "Waiting for smartctl $1 $2 test start..." | tee -a "$log_file"
while true; do
	smartctl --all "$1" | grep "$in_progress_string" >/dev/null
	if [ $? == 0 ]; then break; fi
	sleep 0.1
done
timestamp_start=$(date +%s)

while true; do
	out2=$(smartctl --all "$1" | grep "$in_progress_string" -A 1)
	if [ $? != 0 ]; then break; fi
        if [ "$out2" != "$out1" ]; then
		date | tee -a "$log_file"
		echo "$out2" | tee -a "$log_file"
		out1=$out2
	fi
	sleep 1
done
timestamp_end=$(date +%s)

date | tee -a "$log_file"
echo "smartctl $1 $2 test done in $(($timestamp_end-$timestamp_start))s" | tee -a "$log_file"
