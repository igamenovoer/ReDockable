#!/bin/bash
# install invoke ai dependencies

export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y git python3 python3-pip python3-venv build-essential

apt install -y curl \
        vim \
        tmux \
        ncdu \
        iotop \
        bzip2 \
        gosu \
        magic-wormhole \
        libglib2.0-0 \
        libgl1-mesa-glx \
        libopencv-dev \
        libstdc++-10-dev

apt-get clean && apt-get autoclean

# read -r -d '' PIP_ALIYUN << EOM
# [global]
# index-url = https://mirrors.aliyun.com/pypi/simple

# [install]
# trusted-host=mirrors.aliyun.com
# EOM

# read -r -d '' PIP_TUNA << EOM
# [global]
# index-url = https://pypi.tuna.tsinghua.edu.cn/simple

# [install]
# trusted-host=pypi.tuna.tsinghua.edu.cn
# EOM

# mkdir -p /root/.pip
# echo "$PIP_TUNA" > /root/.pip/pip.conf