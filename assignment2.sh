#!/bin/bash

#Name: Makayla Cuneo 
#Student ID: 200584156
#Assigment 2 COMP2137

#Function to exit on ANY failure
set -e

#Function to trap ANY errors and display and explanation before exiting

trap 'echo "### Eror has been encountered. Now exiting the sccipt..."; exit 1' ERR

