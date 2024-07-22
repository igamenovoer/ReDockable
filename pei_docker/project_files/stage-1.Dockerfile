# syntax=docker/dockerfile:1

# the base image
ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE} AS base

# installation parts on/off
ARG WITH_ESSENTIAL_APPS=false
ARG WITH_CUSTOM_APPS=false
ARG WITH_SSH=false
ARG ROOT_PASSWORD

# if you want to use proxy for apt, set this to host proxy
# like http://host.docker.internal:7890
ARG APT_USE_PROXY

# keep the http proxy for apt after installation?
ARG APT_KEEP_PROXY

# number of retries for apt
ARG APT_NUM_RETRY=10

# use other apt source?
ARG APT_SOURCE_FILE

# keep the apt source file after installation?
ARG KEEP_APT_SOURCE_FILE=false

# ssh user and password
# can be a list of users and passwords, separated by comma
ARG SSH_USER_NAME
ARG SSH_USER_PASSWORD

# path to the public key file for the ssh user
# if specified, will be added to the authorized_keys
# if multiple users, separate the keys by comma
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

# create a dir called pei-docker in root, to store logs
RUN mkdir -p /pei-docker
ENV PEI_DOCKER_DIR="/pei-docker"

# copy installation/internals and installation/system to the image, do apt installs first
ADD ${INSTALL_DIR_HOST_1}/internals ${INSTALL_DIR_CONTAINER_1}/internals
ADD ${INSTALL_DIR_HOST_1}/system ${INSTALL_DIR_CONTAINER_1}/system

# for any script in INSTALL_DIR_CONTAINER_1, including subdirs, except for packages folder
# convert CRLF to LF
RUN find $INSTALL_DIR_CONTAINER_1 -type f -not -path "$INSTALL_DIR_CONTAINER_1/tmp/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_1 -type f -name "*.sh" -exec chmod +x {} \;

# set up container environment
RUN $INSTALL_DIR_CONTAINER_1/internals/setup-env.sh

# prepare apt
RUN apt update
RUN apt-get install --reinstall -y ca-certificates

# show env
RUN env

# install things
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $INSTALL_DIR_CONTAINER_1/internals/install-essentials.sh &&\
    $INSTALL_DIR_CONTAINER_1/internals/setup-ssh.sh

RUN $INSTALL_DIR_CONTAINER_1/internals/setup-cuda.sh

# copy the everything to the image
# ADD ${INSTALL_DIR_HOST_1}/custom ${INSTALL_DIR_CONTAINER_1}/custom
# ADD ${INSTALL_DIR_HOST_1}/generated ${INSTALL_DIR_CONTAINER_1}/generated
# ADD ${INSTALL_DIR_HOST_1}/tmp ${INSTALL_DIR_CONTAINER_1}/tmp
ADD ${INSTALL_DIR_HOST_1} ${INSTALL_DIR_CONTAINER_1}

# convert CRLF to LF
RUN find $INSTALL_DIR_CONTAINER_1 -type f -not -path "$INSTALL_DIR_CONTAINER_1/tmp/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_1 -type f -name "*.sh" -exec chmod +x {} \;

# install custom apps and clean up
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $INSTALL_DIR_CONTAINER_1/internals/custom-on-build.sh &&\
    $INSTALL_DIR_CONTAINER_1/internals/cleanup.sh

# setup entrypoint
RUN cp $INSTALL_DIR_CONTAINER_1/internals/entrypoint.sh /entrypoint.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]