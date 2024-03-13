#!/bin/sh
export DEBIAN_FRONTEND=noninteractive

# install these anyway
# apt update
# apt-get install --reinstall -y ca-certificates

# if WITH_ESSENTIAL_APPS is false or not set, exit
if [ "$WITH_ESSENTIAL_APPS" != "true" ]; then
  exit 0
fi

apt-get install sudo nano mc ne software-properties-common -y
apt-get install openssh-server git net-tools curl -y
apt-get install cmake cmake-curses-gui pkg-config -y
apt-get install python3 python3-pip -y
apt-get install xauth x11-apps qimgv -y
apt-get install ffmpeg -y