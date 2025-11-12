#!/bin/bash

#Name: Makayla Cuneo 
#Student ID: 200584156
#Assigment 2 COMP2137

#Function to exit on ANY failure
set -e

#Function to trap ANY errors and display and explanation before exiting

trap 'echo "### Eror has been encountered. Now exiting the sccipt..."; exit 1' ERR

#Check if the script is running as root
if ["UID" -ne "0"]; then
	echo "Ensure you are running the script as 			root or sudo. Now exiting."
	exit 1
fi

#Check if package is installed
install_package(){
	if ! dpkg -l | grep -q "^ii $1"; then
	echo "Installing Package $1"
	apt update $$ apt install -y "$1"
else
	echo "The package $1 is already installed."
fi
{

#Network Configuration
echo "Configuring and checking network interface"
#Check that netplan is properly configured for static IP
interface_name=$(ip -o link show | grep -v 'lo' |awk -F': ' '{print $2])

#Modifying second interface
netplan_file="/etc/netplan/01-$interface_name.yaml"

