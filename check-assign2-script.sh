#!/bin/bash

# Name: Makayla Cuneo 
# Student ID: 200584156
# Assignment 2 COMP2137

# Function to exit on ANY failure
set -e

# Function to trap ANY errors and display an explanation before exiting
trap 'echo "### Error has been encountered. Now exiting the script..."; exit 1' ERR

# Check if the script is running as root
if [ "$UID" -ne 0 ]; then
    echo "Ensure you are running the script as root or sudo. Now exiting."
    exit 1
fi

# Check if package is installed
install_package(){
    if ! dpkg -l | grep -q "^ii $1"; then
        echo "Installing Package $1"
        apt update && apt install -y "$1"
    else
        echo "The package $1 is already installed."
    fi
}

# Network Interface Configuration
netplan_file="/etc/netplan/00-installer-config.yaml"
config_IP="192.168.16.21/24"
if [ -f "$netplan_file" ]; then
    if ! grep -q "$config_IP" "$netplan_file"; then
        echo "Network configuration is updating..."
        sed -i "s/addresses: \[.*\]/addresses: [$config_IP]/g" "$netplan_file"
        netplan apply
    else
        echo "The Network Configuration is already correct!"
    fi
else
    echo "The Netplan Configuration file is not found. Network Configuration is being skipped."
fi

# Update /etc/hosts
host_entry="192.168.16.21 server1"
if ! grep -q "^192.168.16.21" /etc/hosts; then
    echo "/etc/hosts is updating..."
    sed -i '/server1/d' /etc/hosts
    echo "$host_entry" >> /etc/hosts
else
    echo "/etc/hosts is already configured."
fi

# Apply netplan configuration
netplan apply

# Installation of required packages
install_packages=("apache2" "squid")

for package in "${install_packages[@]}"; do
    dpkg -s "$package" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Installing $package."
        apt install -y "$package" > /dev/null 2>&1
    else
        echo "$package has already been installed."
    fi
done

# Ensure that Apache and Squid are both up and running
systemctl enable apache2
systemctl start apache2
systemctl enable squid
systemctl start squid

# User account configuration
# List of users
users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

# Create user if not existent
for user in "${users[@]}"; do
    if ! id "$user" &>/dev/null; then
        sudo mkdir -p "/home/$user/.ssh"
        sudo useradd -m -s /bin/bash "$user"
        echo "User $user created."
    else
        echo "User $user already exists."
    fi

    # Create SSH keys
    for key_type in rsa ed25519; do
        key_path="/home/$user/.ssh/id_$key_type"
        if [ ! -f "$key_path" ]; then
            echo "Generating SSH $key_type key for $user."
            sudo -u "$user" ssh-keygen -t "$key_type" -f "$key_path" -N "" > /dev/null
        fi

        # Adding public key to authorized keys
        cat "$key_path.pub" >> "/home/$user/.ssh/authorized_keys"
    done

    # Check correct permissions on the user's .ssh folder/files
    chown -R "$user:$user" /home/"$user"/.ssh
    chmod 700 /home/"$user"/.ssh
    chmod 600 /home/"$user"/.ssh/*
    echo "User $user has configured SSH keys."
done

# Add dennis to sudo group
if ! groups dennis | grep -q sudo; then
    echo "Adding dennis to sudo group."
    usermod -aG sudo dennis
else
    echo "dennis is already a member of the sudo group."
fi

# Script completion remarks
echo "The script has successfully executed!"
exit 0

