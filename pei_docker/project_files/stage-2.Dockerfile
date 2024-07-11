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

# prefixes and paths
ARG PEI_PREFIX_DATA
ARG PEI_PREFIX_APPS
ARG PEI_PREFIX_WORKSPACE
ARG PEI_HARD_STORAGE_VOLUME
ARG PEI_HARD_STORAGE_IMAGE
ARG PEI_SOFT_STORAGE_APPS 
ARG PEI_SOFT_STORAGE_DATA
ARG PEI_SOFT_STORAGE_WORKSPACE

# prefixes and paths
ENV PEI_PREFIX_DATA=${PEI_PREFIX_DATA}
ENV PEI_PREFIX_APPS=${PEI_PREFIX_APPS}
ENV PEI_PREFIX_WORKSPACE=${PEI_PREFIX_WORKSPACE}
ENV PEI_HARD_STORAGE_VOLUME=${PEI_HARD_STORAGE_VOLUME}
ENV PEI_HARD_STORAGE_IMAGE=${PEI_HARD_STORAGE_IMAGE}
ENV PEI_SOFT_STORAGE_APPS=${PEI_SOFT_STORAGE_APPS}
ENV PEI_SOFT_STORAGE_DATA=${PEI_SOFT_STORAGE_DATA}
ENV PEI_SOFT_STORAGE_WORKSPACE=${PEI_SOFT_STORAGE_WORKSPACE}

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

# -------------------------------------------
# install essentials

# copy installation/internals and installation/system to the image, do apt installs first
ADD ${INSTALL_DIR_HOST_2}/internals ${INSTALL_DIR_CONTAINER_2}/internals
ADD ${INSTALL_DIR_HOST_2}/system ${INSTALL_DIR_CONTAINER_2}/system

# convert CRLF to LF for scripts in internals and system
RUN find $INSTALL_DIR_CONTAINER_2 -type f -not -path "$INSTALL_DIR_CONTAINER_2/tmp/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_2 -type f -name "*.sh" -exec chmod +x {} \;

# show env
RUN env

# create soft and hard directories
RUN $INSTALL_DIR_CONTAINER_2/internals/create-dirs.sh

# install things
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $INSTALL_DIR_CONTAINER_2/internals/install-essentials.sh

# -------------------------------------------
# run custom scripts

# copy the installation scripts to the image
# ADD ${INSTALL_DIR_HOST_2}/custom ${INSTALL_DIR_CONTAINER_2}/custom
# ADD ${INSTALL_DIR_HOST_2}/generated ${INSTALL_DIR_CONTAINER_2}/generated
# ADD ${INSTALL_DIR_HOST_2}/tmp ${INSTALL_DIR_CONTAINER_2}/tmp
ADD ${INSTALL_DIR_HOST_2} ${INSTALL_DIR_CONTAINER_2}

# convert CRLF to LF
RUN find $INSTALL_DIR_CONTAINER_2 -type f -not -path "$INSTALL_DIR_CONTAINER_2/tmp/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_2 -type f -name "*.sh" -exec chmod +x {} \;

# install custom apps
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
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