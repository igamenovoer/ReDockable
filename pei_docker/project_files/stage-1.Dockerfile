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
ARG PEI_HTTP_PROXY_1
ARG PEI_HTTPS_PROXY_1
ARG ENABLE_GLOBAL_PROXY=false
ARG REMOVE_GLOBAL_PROXY_AFTER_BUILD=false

# path to installation directory
ARG PEI_STAGE_HOST_DIR_1
ARG PEI_STAGE_DIR_1

# -------------------------------------------
ENV PEI_HTTP_PROXY_1=${PEI_HTTP_PROXY_1}
ENV PEI_HTTPS_PROXY_1=${PEI_HTTPS_PROXY_1}
ENV PEI_STAGE_DIR_1=${PEI_STAGE_DIR_1}

# create a dir called pei-docker in root, to store logs
RUN mkdir -p /pei-init
ENV PEI_DOCKER_DIR="/pei-init"

# copy installation/internals and installation/system to the image, do apt installs first
ADD ${PEI_STAGE_HOST_DIR_1}/internals ${PEI_STAGE_DIR_1}/internals
ADD ${PEI_STAGE_HOST_DIR_1}/system ${PEI_STAGE_DIR_1}/system

# convert $PEI_STAGE_DIR_1/internals/setup-env.sh from CRLF to LF
# do not use dos2unix, as it is not available in the base image
# and then run the script
RUN sed -i 's/\r$//' $PEI_STAGE_DIR_1/internals/setup-env.sh && \
    chmod +x $PEI_STAGE_DIR_1/internals/setup-env.sh && \
    $PEI_STAGE_DIR_1/internals/setup-env.sh

# prepare apt
RUN apt update
RUN apt-get install --reinstall -y ca-certificates dos2unix

# for any .sh in PEI_STAGE_DIR_1, including subdirs
# convert CRLF to LF using dos2unix, replace the original
RUN find $PEI_STAGE_DIR_1 -type f -name "*.sh" -exec dos2unix {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $PEI_STAGE_DIR_1 -type f -name "*.sh" -exec chmod +x {} \;

# show env
RUN env

# install things
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $PEI_STAGE_DIR_1/internals/install-essentials.sh &&\
    $PEI_STAGE_DIR_1/internals/setup-ssh.sh

RUN $PEI_STAGE_DIR_1/internals/setup-profile-d.sh

# copy the everything to the image
# ADD ${PEI_STAGE_HOST_DIR_1}/custom ${PEI_STAGE_DIR_1}/custom
# ADD ${PEI_STAGE_HOST_DIR_1}/generated ${PEI_STAGE_DIR_1}/generated
# ADD ${PEI_STAGE_HOST_DIR_1}/tmp ${PEI_STAGE_DIR_1}/tmp
ADD ${PEI_STAGE_HOST_DIR_1} ${PEI_STAGE_DIR_1}

# convert CRLF to LF 
RUN find $PEI_STAGE_DIR_1 -type f -name "*.sh" -exec dos2unix {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $PEI_STAGE_DIR_1 -type f -name "*.sh" -exec chmod +x {} \;

# install custom apps and clean up
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $PEI_STAGE_DIR_1/internals/custom-on-build.sh

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $PEI_STAGE_DIR_1/internals/setup-users.sh &&\
    $PEI_STAGE_DIR_1/internals/cleanup.sh

# setup entrypoint
RUN cp $PEI_STAGE_DIR_1/internals/entrypoint.sh /entrypoint.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]