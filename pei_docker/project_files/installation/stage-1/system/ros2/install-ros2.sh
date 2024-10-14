#!/bin/bash

# Usage: ./install-ros2.sh [--distro <ros_distro>]
#
# This script installs ROS2 with selected packages.
#
# Options:
#   --distro <ros_distro>    Specify the ROS2 distribution to install (default: based on Ubuntu version)
#
# Examples:
#   ./install-ros2.sh
#   ./install-ros2.sh --distro humble
#
# Note: This script must be run with root privileges.

# Function to print usage
print_usage() {
    echo "Usage: ./install-ros2.sh [--distro <ros_distro>]"
    echo "This script installs ROS2 with selected packages."
    echo "Options:"
    echo "  --distro <ros_distro>    Specify the ROS2 distribution to install (default: based on Ubuntu version)"
    echo "Examples:"
    echo "  ./install-ros2.sh"
    echo "  ./install-ros2.sh --distro humble"
    echo "Note: This script must be run with root privileges."
}

# Get user preferred ROS2 distro from environment variable
ros2_prefer_distro=${ROS2_PREFER_DISTRO:-""}

# If ROS2_PREFER_DISTRO is not set, use a default value
if [ -z "$ros2_prefer_distro" ]; then
    # Check Ubuntu version
    ubuntu_version=$(lsb_release -rs)
    if [ "${ubuntu_version%.*}" -ge 24 ]; then
        ros2_prefer_distro="jazzy"  # Prefer 'jazzy' for Ubuntu 24.04 and newer
    else
        ros2_prefer_distro="iron"   # Default to 'iron' for older Ubuntu versions
    fi
fi

# Display help if --help is used
if [ "$1" == "--help" ]; then
    print_usage
    exit 0
fi

# require sudo permission
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Parse command line arguments
ROS_DISTRO=$ros2_prefer_distro

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --distro)
        ROS_DISTRO="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        echo "Unknown option: $1"
        print_usage
        exit 1
        ;;
    esac
done

echo "Installing ROS2 $ROS_DISTRO with selected packages"

export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Shanghai

apt update
apt install -y --no-install-recommends ros-dev-tools \
 ros-$ROS_DISTRO-ros-base \
 ros-$ROS_DISTRO-rviz2 \
 ros-$ROS_DISTRO-rqt
