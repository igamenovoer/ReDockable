#!/bin/bash

# if INSTALL_DIR_CONTAINER_1 is not empty, use it as stage dir
if [ -n "$INSTALL_DIR_CONTAINER_1" ]; then
    stage_dir=$INSTALL_DIR_CONTAINER_1
fi

# if INSTALL_DIR_CONTAINER_2 is not empty, use it as stage dir
if [ -n "$INSTALL_DIR_CONTAINER_2" ]; then
    stage_dir=$INSTALL_DIR_CONTAINER_2
fi

echo "stage dir is set to $stage_dir"
tmp_dir=$stage_dir/tmp

# do we have /hard/volume/app?
if [ -d /hard/volume/app ]; then
    app_dir=/hard/volume/app
else
    app_dir=/hard/image/app
fi
echo "app_dir is set to $app_dir"

install_dst_dir=$app_dir/invokeai-src
echo "install_dst_dir is set to $install_dst_dir"

# install dst dir exists? delete it
if [ -d $install_dst_dir ]; then
    echo "install_dst_dir exists, remove it"
    rm -rf $install_dst_dir
fi

# InvokeAI dir exists?
if [ -d $tmp_dir/InvokeAI ]; then
    echo "Found InvokeAI directory, skipping git clone"
else
    echo "Cloning InvokeAI repository"
    git clone --depth 1 "https://github.com/invoke-ai/InvokeAI.git" "$tmp_dir/InvokeAI"
fi

# copy InvokeAI to install dir
cp -r $tmp_dir/InvokeAI $install_dst_dir
echo "Copied InvokeAI to $install_dst_dir"