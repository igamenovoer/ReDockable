#!/bin/bash

# get dir of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# get filename of this script
FILENAME=$(basename $0)
echo "running $DIR/$FILENAME"

# install dev tools
export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Shanghai

# for general development
apt-get install python3 python3-pip -y
apt-get install cmake cmake-curses-gui pkg-config -y

# install this to avoid tzdata asking for timezone in the future
apt-get install tzdata -y

# you need these to make opencv work
apt-get install ffmpeg libsm6 libxext6 -y
