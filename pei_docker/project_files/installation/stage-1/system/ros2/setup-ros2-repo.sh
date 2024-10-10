#!/bin/bash

# require sudo permission
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Check if PEI_HTTP_PROXY_1 is set and use it if available
if [ -n "$PEI_HTTP_PROXY_1" ]; then
    echo "PEI_HTTP_PROXY_1 is set, using it as HTTP proxy"
    export http_proxy="$PEI_HTTP_PROXY_1"
    export https_proxy="$PEI_HTTP_PROXY_1"
fi

# default to tuna repository
default_ros2_repo_url="http://mirrors.tuna.tsinghua.edu.cn/ros2"

if [ "$ROS2_REPO_NAME" == "ros2" ]; then
    echo "ROS2_REPO_NAME is ros2, use official repository"
    ros2_repo_url="http://packages.ros.org/ros2"
elif [ "$ROS2_REPO_NAME" == "tuna" ]; then
    echo "ROS2_REPO_NAME is set to tuna, use tuna ros2 repository"
    ros2_repo_url="http://mirrors.tuna.tsinghua.edu.cn/ros2"
else
    echo "ROS2_REPO_NAME is not set or invalid, use default repository"
    ros2_repo_url=$default_ros2_repo_url
fi

apt install -y software-properties-common curl wget

# use wget to download https://raw.githubusercontent.com/ros/rosdistro/master/ros.key
# and output to /usr/share/keyrings/ros-archive-keyring.gpg
wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O /usr/share/keyrings/ros-archive-keyring.gpg

# add ros2 apt repository

# do you have ros2.list in /etc/apt/sources.list.d/ ?
if [ -f /etc/apt/sources.list.d/ros2.list ]; then
    echo "ros2.list already exists, removing it"
    rm /etc/apt/sources.list.d/ros2.list
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] $ros2_repo_url/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
echo "ros2.list added to /etc/apt/sources.list.d/"
cat /etc/apt/sources.list.d/ros2.list