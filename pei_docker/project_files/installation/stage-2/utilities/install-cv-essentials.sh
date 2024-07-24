#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt update

# # dev tools
apt-get install cmake cmake-curses-gui pkg-config -y
apt-get install python python3 python3-pip -y

# opencv
apt-get install build-essential qimgv -y
apt-get install ffmpeg libsm6 libxext6 -y
apt-get install libopencv-dev -y
# apt-get install libboost-all-dev -y
