#!/bin/bash

# require sudo permission
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Shanghai

apt update && apt install -y locales tzdata
locale-gen en_US en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

locale  # verify settings