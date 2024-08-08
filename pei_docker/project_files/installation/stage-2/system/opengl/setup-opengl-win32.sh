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
    xvfb \
    glmark2 \
    && apt-get -y autoremove \
    && apt-get clean

# to use the NVIDIA GPU, set the below env variable
# otherwise it will use the integrated GPU
# if OPENGL_USE_NVIDIA_GPU is set to true, then use the NVIDIA GPU
if [ "$OPENGL_USE_NVIDIA_GPU" = "true" ]; then
    echo "export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA" >> /etc/profile.d/opengl.sh
fi

echo "export NVIDIA_VISIBLE_DEVICES=\"all\"" >> /etc/profile.d/opengl.sh
echo "export NVIDIA_DRIVER_CAPABILITIES=\"all\"" >> /etc/profile.d/opengl.sh
echo "export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:/usr/lib/wsl/lib\"" >> /etc/profile.d/opengl.sh
