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

# create a dir called redockable in root, to store logs
RUN mkdir -p /redockable
ENV REDOCKABLE_DIR="/redockable"

# copy the installation scripts to the image
ADD ${INSTALL_DIR_HOST_1} ${INSTALL_DIR_CONTAINER_1}

# for any script in INSTALL_DIR_CONTAINER_1, including subdirs, except for packages folder
# convert CRLF to LF
RUN find $INSTALL_DIR_CONTAINER_1 -type f -not -path "$INSTALL_DIR_CONTAINER_1/tmp/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_1 -type f -name "*.sh" -exec chmod +x {} \;

RUN env

# set up container environment
RUN $INSTALL_DIR_CONTAINER_1/internals/setup-env.sh

# set up apt
RUN apt update
RUN apt-get install --reinstall -y ca-certificates

# setup ssh and install essentials
RUN $INSTALL_DIR_CONTAINER_1/internals/install-essentials.sh &&\
    $INSTALL_DIR_CONTAINER_1/internals/setup-ssh.sh &&\
    $INSTALL_DIR_CONTAINER_1/internals/custom-on-build.sh &&\
    $INSTALL_DIR_CONTAINER_1/internals/cleanup.sh

# setup entrypoint
RUN cp $INSTALL_DIR_CONTAINER_1/internals/entrypoint.sh /entrypoint.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]