#!/bin/bash

# get dir of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# get filename of this script
FILENAME=$(basename $0)
echo "running $DIR/$FILENAME"

# install dev tools
export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Shanghai

# for x11 remote
apt-get install qimgv -y
apt-get install xauth x11-apps -y
apt-get install xvfb x11vnc -y