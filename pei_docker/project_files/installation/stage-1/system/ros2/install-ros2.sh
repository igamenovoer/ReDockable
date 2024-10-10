#!/bin/bash

#!/bin/bash

# Usage: ./install-ros2.sh [--distro <ros_distro>]
#
# This script installs ROS2 with selected packages.
#
# Options:
#   --distro <ros_distro>    Specify the ROS2 distribution to install (default: iron)
#
# Examples:
#   ./install-ros2.sh
#   ./install-ros2.sh --distro humble
#
# Note: This script must be run with root privileges.

# Display help if --help is used
if [ "$1" == "--help" ]; then
    echo "Usage: ./install-ros2.sh [--distro <ros_distro>]"
    echo "This script installs ROS2 with selected packages."
    echo "Options:"
    echo "  --distro <ros_distro>    Specify the ROS2 distribution to install (default: iron)"
    echo "Examples:"
    echo "  ./install-ros2.sh"
    echo "  ./install-ros2.sh --distro humble"
    echo "Note: This script must be run with root privileges."
    exit 0
fi


# require sudo permission
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# find --distro argument
if [ "$1" == "--distro" ]; then
    ROS_DISTRO=$2
else
    ROS_DISTRO=iron
fi

echo "Installing ROS2 with selected packages"

export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Shanghai

apt update
apt install -y --no-install-recommends ros-dev-tools \
 ros-$ROS_DISTRO-ros-base \
 ros-$ROS_DISTRO-rviz2 \
 ros-$ROS_DISTRO-rqt
