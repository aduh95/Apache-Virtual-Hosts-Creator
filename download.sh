#!/bin/sh

# This script aims to make creation of Virtual Hosts within Apache automatic
# The user that executes the file need sudo access
#
# Those command should be executed directly in the console
# It only aims to download the real setup file from the Github repo
#
# @author aduh95
# @github https://github.com/aduh95/Apache-Virtual-Hosts-Creator/
#
setupScript=`mktemp`

echo "Downloading the scripts..."
wget -qO "$setupScript" https://raw.githubusercontent.com/aduh95/Apache-Virtual-Hosts-Creator/master/setup.sh

chmod +x "$setupScript"

echo
echo "Checking SHA1 sum..."
echo "e8a428fcc655308feb8c08cca1b7d07d2d0f9338 $setupScript" | sha1sum -c - && bash "$setupScript"

rm -f "$setupScript"
