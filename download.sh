#!/bin/sh

# This script aims to make creation of Virtual Hosts within Apache automatic
# The user that executes the file need sudo access
#
# Those command should be executed directly in the console
# It only aims to download the real setup file : http://aduh95.free.fr/Apache-Virtual-Hosts-Creator/setup.sh
#
# @author aduh95
# @github https://github.com/aduh95/Apache-Virtual-Hosts-Creator/
#
setupScript=`mktemp`

echo "Downloading the scripts..."
wget -O "$setupScript" https://raw.githubusercontent.com/aduh95/Apache-Virtual-Hosts-Creator/master/setup.sh

chmod +x "$setupScript"

echo
echo "Checking SHA1 sum..."
echo "6d5ece45a6f3211f828a398c5e97711465d55381 $setupScript" | sha1sum -c - && bash "$setupScript"

rm "$setupScript"
