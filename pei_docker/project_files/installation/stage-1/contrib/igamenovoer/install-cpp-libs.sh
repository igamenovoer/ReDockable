#!/bin/bash


export DEBIAN_FRONTEND=noninteractive

apt-get update

# dev tools
apt-get -y install cmake cmake-curses-gui pkg-config mc
apt-get -y install ninja-build 
apt-get -y install clang clangd lldb gdb clang-format cmake-format

# heavy libs
apt-get -y install libopencv-dev libeigen3-dev libssl-dev ffmpeg libsm6 libxext6 libcgal-dev libboost-all-dev pybind11-dev pybind11-json-dev python3-pybind11

# algorithms
apt-get -y install libnanoflann-dev libxtensor-dev libflann-dev libglm-dev

# utilities
apt-get -y install libspdlog-dev libmsgpack-dev libzstd-dev libtbb-dev xtensor-dev

# file and serialization
apt-get -y install libcereal-dev nlohmann-json3-dev libflatbuffers-dev libyaml-cpp-dev libprotobuf-dev libtinyobjloader-dev

# visualization
apt-get -y install qimgv qt6-base-dev v4l-utils