# syntax=docker/dockerfile:1

# the base image
# FROM nvidia/cuda:11.8.0-base-ubuntu22.04
ARG BASE_IMAGE=nvidia/cuda:12.3.2-base-ubuntu22.04
FROM ${BASE_IMAGE} AS base

# installation parts on/off
ARG WITH_ESSENTIAL_APPS=false
ARG WITH_CUSTOM_APPS=false
ARG WITH_SSH=false

# if you want to use proxy for apt, set this to host proxy
# like http://host.docker.internal:7890
ARG APT_USE_PROXY

# keep the http proxy for apt after installation?
ARG APT_KEEP_PROXY

# use other apt source?
ARG APT_SOURCE_FILE

# keep the apt source file after installation?
ARG KEEP_APT_SOURCE_FILE=false

# ssh user and password
ARG SSH_USER_NAME
ARG SSH_USER_PASSWORD

# path to the public key file for the ssh user
# if specified, will be added to the authorized_keys
ARG SSH_PUBKEY_FILE

# user provided proxy
ARG USER_HTTP_PROXY
ARG USER_HTTPS_PROXY

# path to installation directory
ARG INSTALL_DIR_HOST_1
ARG INSTALL_DIR_CONTAINER_1

# -------------------------------------------
ENV USER_HTTP_PROXY=${USER_HTTP_PROXY}
ENV USER_HTTPS_PROXY=${USER_HTTPS_PROXY}
ENV INSTALL_DIR_CONTAINER_1=${INSTALL_DIR_CONTAINER_1}

# copy the installation scripts to the image
ADD ${INSTALL_DIR_HOST_1} ${INSTALL_DIR_CONTAINER_1}

# for any script in /init-me, including subdirs, except for packages folder
# convert CRLF to LF
RUN find $INSTALL_DIR_CONTAINER_1 -type f -not -path "$INSTALL_DIR_CONTAINER_1/packages/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_1 -type f -name "*.sh" -exec chmod +x {} \;

RUN env

# set up container environment
RUN $INSTALL_DIR_CONTAINER_1/internals/setup-env.sh

# set up apt
RUN apt update
RUN apt-get install --reinstall -y ca-certificates

# setup ssh and install essentials
RUN $INSTALL_DIR_CONTAINER_1/internals/setup-ssh.sh &&\
    $INSTALL_DIR_CONTAINER_1/internals/install-essentials.sh &&\
    $INSTALL_DIR_CONTAINER_1/custom/custom-install-apps.sh &&\
    $INSTALL_DIR_CONTAINER_1/internals/cleanup.sh

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
RUN $INSTALL_DIR_CONTAINER_1/internals/create-dirs.sh

# path env for easy access
ENV X_APPS="${X_PATH_SOFT_BASE}/${X_PREFIX_APPS}"
ENV X_DATA="${X_PATH_SOFT_BASE}/${X_PREFIX_DATA}"
ENV X_WORKSPACE="${X_PATH_SOFT_BASE}/${X_PREFIX_WORKSPACE}"

# # create soft directory
# RUN mkdir -p $X_PATH_SOFT_BASE &&\
#     chmod 777 $X_PATH_SOFT_BASE

# # create in-image storage paths
# RUN echo "creating hard storage directories"
# RUN mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_APPS &&\
#     chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_APPS &&\
#     mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_DATA &&\
#     chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_DATA &&\
#     mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_WORKSPACE &&\
#     chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_WORKSPACE &&\
#     mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE &&\
#     chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE

# # creating soft directories
# RUN echo "creating soft storage directories"
# RUN mkdir -p $X_PATH_SOFT_BASE/$X_PREFIX_APPS &&\
#     chmod 777 $X_PATH_SOFT_BASE/$X_PREFIX_APPS &&\
#     mkdir -p $X_PATH_SOFT_BASE/$X_PREFIX_DATA &&\
#     chmod 777 $X_PATH_SOFT_BASE/$X_PREFIX_DATA &&\
#     mkdir -p $X_PATH_SOFT_BASE/$X_PREFIX_WORKSPACE &&\
#     chmod 777 $X_PATH_SOFT_BASE/$X_PREFIX_WORKSPACE

# setup entrypoint
RUN cp $INSTALL_DIR_CONTAINER_1/internals/entrypoint.sh /entrypoint.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]