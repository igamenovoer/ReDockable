#!/bin/bash

# require sudo permission
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Shanghai

apt update
apt install -y ros-dev-tools ros-iron-desktop