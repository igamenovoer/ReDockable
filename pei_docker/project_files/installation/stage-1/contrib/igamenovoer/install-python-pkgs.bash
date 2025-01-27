#!/bin/bash

# required root permission
# if [ "$EUID" -ne 0 ]; then
#     echo "Please run as root"
#     exit 1
# fi

required_packages=(
    "ipykernel"
    "scipy"
    "numpy"
    "opencv-contrib-python"
    "networkx"
    "matplotlib"
    "pyyaml"
    "attrs"
    "cattrs"
    "omegaconf"
    "rich"
    "click"
)

# Check if NVIDIA GPU is available
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA GPU detected, will install onnxruntime-gpu"
    required_packages+=("onnxruntime-gpu")
else
    echo "No NVIDIA GPU detected, will install CPU-only onnxruntime"
    required_packages+=("onnxruntime")
fi


echo "The following packages will be installed:"
for pkg in "${required_packages[@]}"; do
    echo "- $pkg"
done


for pkg in "${required_packages[@]}"; do
    pip3 install $pkg --break-system-packages
done
