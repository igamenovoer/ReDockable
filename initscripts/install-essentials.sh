#!/bin/sh
export DEBIAN_FRONTEND=noninteractive

# install these anyway
# apt update
# apt-get install --reinstall -y ca-certificates

# if WITH_ESSENTIAL_APPS is false or not set, exit
if [ "$WITH_ESSENTIAL_APPS" != "true" ]; then
  exit 0
fi

apt update && apt-get install -y \
    git \
    python3-venv \
    python3-pip \
    build-essential

# set pip source
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

apt update && apt install -y --no-install-recommends \
        git \
        curl \
        vim \
        tmux \
        ncdu \
        iotop \
        bzip2 \
        gosu \
        magic-wormhole \
        libglib2.0-0 \
        libgl1-mesa-glx \
        python3-venv \
        python3-pip \
        build-essential \
        libopencv-dev \
        libstdc++-10-dev
  
  apt-get clean && apt-get autoclean

# apt-get install sudo nano mc ne software-properties-common -y
# apt-get install openssh-server git net-tools curl tmux -y
# apt-get install cmake cmake-curses-gui pkg-config -y
# apt-get install python3 python3-pip -y
# apt-get install xauth x11-apps qimgv -y
# apt-get install ffmpeg -y