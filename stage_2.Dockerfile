# syntax=docker/dockerfile:1

# the base image
ARG BASE_IMAGE

# -------------------------------------------
# create workspace for user
FROM ${BASE_IMAGE} AS default

# paths
ARG INSTALL_DIR_HOST_2
ARG INSTALL_DIR_CONTAINER_2
ARG WITH_ESSENTIAL_APPS=false
ARG WITH_CUSTOM_APPS=false

# setup paths
ENV X_PATH_HARD_BASE="/hard"
ENV X_PATH_SOFT_BASE="/soft"

ENV X_PREFIX_APPS="apps"
ENV X_PREFIX_DATA="data"
ENV X_PREFIX_WORKSPACE="workspace"

# subdirectories under this path is external mounted volumes
ENV X_PREFIX_VOLUME_STORAGE="volume"

# subdirectories under this path is internal to the image
ENV X_PREFIX_IMAGE_STORAGE="image"

# soft links are created in /soft pointing to /hard/image or /hard/volume
# e.g., /soft/apps -> /hard/image/apps or /hard/volume/apps
# depending on storage choice, can be
# volume_first: use volume if exists, otherwise use image
# image_first: use image if exists, otherwise use volume
ENV X_STORAGE_CHOICE="volume_first"

# path env for easy access
ENV X_APPS="${X_PATH_SOFT_BASE}/${X_PREFIX_APPS}"
ENV X_DATA="${X_PATH_SOFT_BASE}/${X_PREFIX_DATA}"
ENV X_WORKSPACE="${X_PATH_SOFT_BASE}/${X_PREFIX_WORKSPACE}"

ENV INSTALL_DIR_CONTAINER_2=${INSTALL_DIR_CONTAINER_2}

# copy the installation scripts to the image
ADD ${INSTALL_DIR_HOST_2} ${INSTALL_DIR_CONTAINER_2}

# convert CRLF to LF
RUN find $INSTALL_DIR_CONTAINER_2 -type f -not -path "$INSTALL_DIR_CONTAINER_2/tmp/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_2 -type f -name "*.sh" -exec chmod +x {} \;

# show env
RUN env

# create soft and hard directories
RUN $INSTALL_DIR_CONTAINER_2/internals/create-dirs.sh

# install essentials and custom apps
RUN $INSTALL_DIR_CONTAINER_2/internals/install-essentials.sh &&\
    $INSTALL_DIR_CONTAINER_2/internals/custom-on-build.sh &&\
    $INSTALL_DIR_CONTAINER_2/internals/cleanup.sh

# override the entrypoint
RUN cp $INSTALL_DIR_CONTAINER_2/internals/entrypoint.sh /entrypoint.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# install apps to the image
# FROM default AS store-in-image
# ENV X_STORAGE_CHOICE="image_first"
# RUN /installation/scripts/create-links.sh