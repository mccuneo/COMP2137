#!/bin/bash

#Tells script to ignore all termination signals
trap ' ' TERM HUP INT

#Set verbose as default off
VERBOSE=false

#function to log whether verbose is enabled or not
option_message() {
local message="$1"
if ["$VERBOSE" = true ]; then
echo "$message"
fi
logger "$message"

}

#Handle hostname change
change_hostname() {
local desiredName="$2"
local currentName
currentName=$(hostname)
if ["$currentName" != "$desiredName"]; then
echo "Changing hostname to $desiredName"
echo "$desiredName" | sudo tee /etc/hostname >/dev/null
sudo hostnemctl set-hostname "$desiredName"
logger "Hostname was changed to $desiredName"
else
["$VERBOSE = true] && echo "The hostname was already set to $desiredName"
fi
}

#Handle IP change

change_ip() {
local desiredIP= "$2"
local currentIP
currentIP=$(hostname -I | awk '{print$1}')
if ["currentIP" != "$desiredIP"]; then
sudo sed -i "s/$currentIP/$desiredIP/" /etc/netplan/10-lxc.yaml
sudo netplan apply
option_message "IP was changed from $currentIP tp $desiredIP"
else
["$VERBOSE" = true ] && echo "IP was already set to $desiredIP"
fi
}

#Adding a host entry to /etc/hosts
change_hostrentry() {
local desiredName="$1"
local desiredIP="$2"

if ! grep -q "$desiredIP $desiredName" /etc/hosts; then
echo "$desiredIP $desiredName" >> /etc/hosts
option_message "The $desiredIP $desiredName have been added to /etc/hosts"
else
[ "$VERBOSE = true] && echo "The $desiredIP $desiredName are already in /etc/hosts"
fi
}

#Catch for unknown options
*)
echo "Unknown option: $1"
exit 1
;;
esac
done
