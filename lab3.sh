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

move_excecute() {
	local server="$1"
	local name="$2"
	local ip="$3"
	local hostentryname="$4"
	local hostentryipa="$5"
	local verboseopt=" "
	[ "$VERBOSE" = true ] && verboseopt="-VERBOSE"
	echo "configure-host.sh is transferring to $server"
	scp configure-host.sh remoteadmin@"$server":/root || { option_message "Eroor: SCP failed to $server"; exit 1; }
	echo " configure-host.sh is executing on $server"
	ssh remoteadmin@"$server" "/root/configure-host.sh -name $name  -ip $ip -hostentry $hostentryname $hostentryipa $verboseopt" 
		|| { option_message "Error: configure-host.sh has failed on $server; exit 1; }
}

#Do update on server1
move_excecute "server1-mgmt" "loghost" 192.168.16.3" "webhost" "192.168.16.4"
#Do update on server2
move_xecute "server2-mgmt" "webhost" "192.168.16.4" "loghost" "192.168.16.3"

#Do update local /etc/hosts
[ "$VERBOSE" =  true ] && verboseopt="-VERBOSE"
./configure-host.sh -hostentry loghost 192.168.16.3 $verboseopt || { option_message "There is an error updating local hosts (loghost)"; exit 1; }
./configure-host.sh -hostentry webhost 192.168.16.4 $verbose_option || { log_message "There was an error updating local hosts (webhost)"; exit 1; }

echo "Deployment has been complete"

	
