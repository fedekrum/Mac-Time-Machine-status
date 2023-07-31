#!/bin/bash

# Check if we're root and re-run if not.
if [ $(id -u) -ne 0 ]; then
    echo "Script not running as root, trying to elevate to root..."
    sudo bash "$0" "$@"
    exit $?
fi
clear

# Get the PID of the process "/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd"
PID=$(ps -ef | awk '$8=="'/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd'" {print $2}')

# If the process is not found, it alerts the user and quits
if [ -z "$PID" ]; then
    echo "The process '/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd' is not running"
    exit 1
fi
clear

# Loop to continuously check the status
while true; do
    echo -e "\033[H"

    # Check if the output of "tmutil status" contains "ThinningPreBackup"
    if tmutil status | grep -q "ThinningPreBackup"; then
        # If it does, run "lsof -p $PID" and show the last line as the status
        echo
        printf "$(lsof -p $PID | tail -n 1 | awk -F'/[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}' '{print substr($2, 2)}')\n"
    else
        # If it doesn't, show the result of "tmutil status"
        echo
        printf "$(tmutil status)\n"
    fi

    # Get the width of the terminal
width=$(tput cols)

# Generate a line filled with spaces
line=$(printf '%*s' $width)

# Do it for three lines
for i in {1..3}; do
    # Print a carriage return and the line of spaces, effectively overwriting the current line with spaces
    echo -en "\r$line\r"

    # Move to the next line
    echo
done

    # Wait for 10 seconds before the next round
    for i in {10..1}; do
      echo -e "\033[H"
      echo "$i "
      sleep 1
    done
done
