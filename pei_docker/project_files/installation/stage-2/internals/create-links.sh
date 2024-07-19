#!/bin/bash

# create links in soft/ based on configuration

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Executing $DIR/create-links.sh ..."

# create links
link_source="$PEI_SOFT_APPS $PEI_SOFT_DATA $PEI_SOFT_WORKSPACE"
X_STORAGE_CHOICE="volume-first" # default value, can be image-first

# link source to target according to X_STORAGE_CHOICE
for source in $link_source; do
    target_volume="$PEI_PATH_HARD/$PEI_PREFIX_VOLUME/$(basename $source)"
    target_image="$PEI_PATH_HARD/$PEI_PREFIX_IMAGE/$(basename $source)"

    # if source exists, remove it if it is a link, report error if it is a directory
    if [ -e $source ]; then
        if [ -L $source ]; then
            echo "Removing existing link $source ..."
            rm $source
        elif [ -d $source ]; then
            echo "Error: $source is a directory, please remove it manually"
            continue
        fi
    fi

    echo "Creating link for $source ..."

    # if target volume permission is not 777, change it
    if [ -d "$target_volume" ]; then
        if [ "$(stat -c %a $target_volume)" != "777" ]; then
            echo "Changing permission of $target_volume to 777"
            chmod 777 -R $target_volume
        fi
    fi

    # if X_STORAGE_CHOICE is volume-first, link source to target_volume if target_volume exists,
    # otherwise link source to target_image
    if [ "$X_STORAGE_CHOICE" == "volume-first" ]; then
        if [ -d "$target_volume" ]; then
            echo "Linking $source to $target_volume"
            ln -s $target_volume $source
        else
            echo "Linking $source to $target_image"
            ln -s $target_image $source
        fi
        continue
    fi

    # if X_STORAGE_CHOICE is image-first, link source to target_image if target_image exists,
    # otherwise link source to target_volume
    if [ "$X_STORAGE_CHOICE" == "image-first" ]; then
        if [ -d "$target_image" ]; then
            echo "Linking $source to $target_image"
            ln -s $target_image $source
        else
            echo "Linking $source to $target_volume"
            ln -s $target_volume $source
        fi
        continue
    fi
done