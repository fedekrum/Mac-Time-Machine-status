#!/bin/bash

# Check if we're root and re-run if not.
if [ $(id -u) -ne 0 ]; then
    echo "Script not running as root, trying to elevate to root..."
    sudo bash "$0" "$@"
    exit $?
fi

# Get the PID of the process "/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd"
PID=$(ps -ef | awk '$8=="'/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd'" {print $2}')

# If the process is not found, it alerts the user and quits
if [ -z "$PID" ]; then
    echo "The process '/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd' is not running"
    exit 1
fi

# Loop to continuously check the status
while true; do
    clear
    # Check if the output of "tmutil status" contains "ThinningPreBackup"
    if tmutil status | grep -q "ThinningPreBackup"; then
        # If it does, run "lsof -p $PID" and show the last line as the status
        printf "$(lsof -p $PID | tail -n 1 | awk -F'/[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}' '{print substr($2, 2)}')\n"
    else
        # If it doesn't, show the result of "tmutil status"
        printf "$(tmutil status)\n"
    fi

    # Wait for 10 seconds before the next round
    sleep 10
done
