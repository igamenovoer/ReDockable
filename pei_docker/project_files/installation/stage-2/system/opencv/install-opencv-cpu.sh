#!/bin/bash

# download and install latest opencv

# install dependencies
sudo apt update

# use qt6 for gui
sudo apt install -y qt6-base-dev libqt6core5compat6-dev libglx-dev libgl1-mesa-dev 

# use ninja for building, hdf5-dev for reading and writing hdf5 files
sudo apt install -y libhdf5-dev ninja-build


# do we have PEI_STAGE_DIR_2 set?
# if yes, set tmp_dir to PEI_STAGE_DIR_2/tmp
# otherwise, set tmp_dir to ~/tmp
if [ -z "$PEI_STAGE_DIR_2" ]; then
    tmp_dir=~/tmp

    # mkdir ~/tmp if it doesn't exist
    if [ ! -d $tmp_dir ]; then
        mkdir $tmp_dir
    fi
else
    tmp_dir=$PEI_STAGE_DIR_2/tmp

    # do we have write-permission to $tmp_dir? if not, sudo to add read/write permission
    if [ ! -w $tmp_dir ]; then
        echo "no write permission to $tmp_dir, adding write permission now"
        sudo chmod -R 777 $tmp_dir
    fi
fi

# download opencv to tmp_dir from git, if it doesn't exist
# the git repo is https://github.com/opencv/opencv.git, branch is 4.x
if [ ! -d $tmp_dir/opencv ]; then
    echo "$tmp_dir/opencv is not found, cloning opencv to $tmp_dir/opencv"
    git clone --depth 1 -b 4.x https://github.com/opencv/opencv.git $tmp_dir/opencv
fi

# download opencv-contrib to tmp_dir from git, if it doesn't exist
# the git repo is https://github.com/opencv/opencv_contrib.git, branch is 4.x
if [ ! -d $tmp_dir/opencv_contrib ]; then
    echo "$tmp_dir/opencv_contrib is not found, cloning opencv_contrib to $tmp_dir/opencv_contrib"
    git clone --depth 1 -b 4.x https://github.com/opencv/opencv_contrib.git $tmp_dir/opencv_contrib
fi

# clean up the build directory
build_dir=$tmp_dir/opencv-build

# delete everything in $build_dir
if [ -d $build_dir ]; then
    rm -rf $build_dir
fi

# use cmake to build opencv, the build directory is $tmp_dir/opencv-build
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBUILD_opencv_apps=OFF \
    -DBUILD_DOCS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DBUILD_opencv_python2=OFF \
    -DBUILD_opencv_python3=OFF \
    -DBUILD_opencv_legacy=OFF \
    -DOPENCV_GENERATE_PKGCONFIG=ON \
    -DWITH_QT=ON \
    -DOPENCV_EXTRA_MODULES_PATH=$tmp_dir/opencv_contrib/modules \
    -DCUDA_ARCH_BIN=$compute_capability \
    -G Ninja \
    -S $tmp_dir/opencv \
    -B $build_dir

# build it
cmake --build $tmp_dir/opencv-build

# install it
sudo cmake --install $tmp_dir/opencv-build

# remove the build directory
echo "removing $build_dir"
rm -rf $build_dir

# good to go
echo "opencv-gpu is now installed"

# make sure the system can find the opencv libraries
sudo ldconfig -v