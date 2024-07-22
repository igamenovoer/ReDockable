#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# install these anyway
# apt update
# apt-get install --reinstall -y ca-certificates

# if WITH_ESSENTIAL_APPS is false or not set, exit
if [ "$WITH_ESSENTIAL_APPS" != "true" ]; then
  exit 0
fi

# apt-get install sudo nano mc ne software-properties-common -y
apt-get install sudo nano -y
apt-get install git net-tools curl tmux -y
apt-get install build-essential cmake pkg-config -y

# if ssh server is not installed, install it
dpkg -l | grep openssh-server
if [ $? -eq 0 ]; then
  echo "openssh-server is already installed"
else
  echo "openssh-server is not installed, installing..."
  apt-get install openssh-server -y
fi

# FIXME: skipping all the other installations for now
exit 0

# for general development
apt-get install python3 python3-pip -y
apt-get install git net-tools curl tmux -y
apt-get install cmake cmake-curses-gui pkg-config -y

# for x11 remote
apt-get install xauth xvfb x11vnc x11-apps qimgv -y

# you need these to make opencv work
apt-get install ffmpeg libsm6 libxext6 -y

# apt-get install python3 python3-pip -y