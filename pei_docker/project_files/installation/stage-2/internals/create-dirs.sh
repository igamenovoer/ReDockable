#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Executing $DIR/create-dirs.sh ..."

# create in-image storage paths
echo "creating hard storage directories"

# hard storage in image
hard_image_apps=$PEI_PATH_HARD/$PEI_PREFIX_IMAGE/$PEI_PREFIX_APPS
mkdir -p $hard_image_apps 
chmod 777 $hard_image_apps
echo "created $hard_image_apps"

hard_image_data=$PEI_PATH_HARD/$PEI_PREFIX_IMAGE/$PEI_PREFIX_DATA
mkdir -p $hard_image_data
chmod 777 $hard_image_data
echo "created $hard_image_data"

hard_image_workspace=$PEI_PATH_HARD/$PEI_PREFIX_IMAGE/$PEI_PREFIX_WORKSPACE
mkdir -p $hard_image_workspace
chmod 777 $hard_image_workspace
echo "created $hard_image_workspace"

# hard storage in volume
hard_storage_volume=$PEI_PATH_HARD/$PEI_PREFIX_VOLUME
mkdir -p $hard_storage_volume
chmod 777 $hard_storage_volume
echo "created $hard_storage_volume"

# creating soft directories
soft_storage=$PEI_PATH_SOFT
mkdir -p $soft_storage
chmod 777 $soft_storage
echo "created $soft_storage"