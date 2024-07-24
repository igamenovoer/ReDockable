#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

apt-get -y install \
    libxext-dev \
    libx11-dev \
    libglvnd-dev \
    libglx-dev \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    freeglut3-dev \
    mesa-utils \
    mesa-utils-extra \
    glmark2 \
    && apt-get -y autoremove \
    && apt-get clean

# ENV LD_LIBRARY_PATH=/usr/lib/wsl/lib
# ENV LIBVA_DRIVER_NAME=d3d12

# echo "libGLVND installed, copying the nvidia json file"
# cp $DIR/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# setup environment for OpenGL
echo "Setting up environment for OpenGL"

# add the below env variables to profile.d opengl.sh
# export NVIDIA_VISIBLE_DEVICES="all"
# export NVIDIA_DRIVER_CAPABILITIES="graphics,utility,compute"
# export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64"

# echo "export LIBVA_DRIVER_NAME=d3d12" >> /etc/profile.d/opengl.sh
echo "export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA" >> /etc/profile.d/opengl.sh
echo "export NVIDIA_VISIBLE_DEVICES=\"all\"" >> /etc/profile.d/opengl.sh
echo "export NVIDIA_DRIVER_CAPABILITIES=\"all\"" >> /etc/profile.d/opengl.sh
echo "export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:/usr/lib/wsl/lib\"" >> /etc/profile.d/opengl.sh
