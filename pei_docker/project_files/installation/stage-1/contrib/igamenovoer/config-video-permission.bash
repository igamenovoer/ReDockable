#!/bin/bash

# required root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# let all users to access /dev/video*, by adding them to the video group
groupadd video
for user in $(ls /home); do
    echo "Adding $user to video group"
    usermod -aG video $user
done

echo "Done"
echo "Please reboot the system to apply the changes"
