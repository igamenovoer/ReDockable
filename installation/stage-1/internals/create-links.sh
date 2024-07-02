#!/bin/bash

# create links in soft/ based on configuration

# create links
link_source="$X_PATH_SOFT_BASE/$X_PREFIX_APPS $X_PATH_SOFT_BASE/$X_PREFIX_DATA $X_PATH_SOFT_BASE/$X_PREFIX_WORKSPACE"

# link source to target according to X_STORAGE_CHOICE
for source in $link_source; do
    target_volume="$X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$(basename $source)"
    target_image="$X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$(basename $source)"

    # if link_source exists, skip
    if [ -L "$source" ]; then
        echo "Link for $source exists, skipping"
        continue
    fi

    echo "Creating link for $source ..."

    # if X_STORAGE_CHOICE is volume_only, link source to target_volume if target_volume exists
    if [ "$X_STORAGE_CHOICE" == "volume_only" ]; then
        if [ -d "$target_volume" ]; then
            echo "Linking $source to $target_volume"
            ln -s $target_volume $source
        else
            echo "Target volume $target_volume not found, skipping"
        fi
        continue
    fi

    # if X_STORAGE_CHOICE is image_only, link source to target_image if target_image exists
    if [ "$X_STORAGE_CHOICE" == "image_only" ]; then
        if [ -d "$target_image" ]; then
            echo "Linking $source to $target_image"
            ln -s $target_image $source
        else
            echo "Target image $target_image not found, skipping"
        fi
        continue
    fi

    # if X_STORAGE_CHOICE is volume_first, link source to target_volume if target_volume exists,
    # otherwise link source to target_image
    if [ "$X_STORAGE_CHOICE" == "volume_first" ]; then
        if [ -d "$target_volume" ]; then
            echo "Linking $source to $target_volume"
            ln -s $target_volume $source
        else
            echo "Linking $source to $target_image"
            ln -s $target_image $source
        fi
        continue
    fi

    # if X_STORAGE_CHOICE is image_first, link source to target_image if target_image exists,
    # otherwise link source to target_volume
    if [ "$X_STORAGE_CHOICE" == "image_first" ]; then
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