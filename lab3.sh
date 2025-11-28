#!/bin/bash

#Checks i f verbose is enabled or not
VERBOSE=false

option_message() {
	local message="$1"
	if [ "$VERBOSE" = true ]; then
		echo "$message"
	fi
	logger "$message"
}

#Arguments parse command line
while [ $# -gt 0 ]; do
	case "$1" in
		-VERBOSE) VERBOSE=true ;;
		*) echo "Option unknown: $1"; exit 1 ;;
	esac
done

