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

# if you want the container to use proxy for shell, set this to host proxy
ARG SHELL_HTTP_PROXY

# optional http proxy, used when accessing blocked sites whenever needed
ARG OPTIONAL_HTTP_PROXY

# ssh user and password
ARG SSH_USER_NAME
ARG SSH_USER_PASSWORD

# path to the public key file for the ssh user
# if specified, will be added to the authorized_keys
ARG SSH_PUBKEY_FILE

# user provided proxy
ARG USER_HTTP_PROXY
ARG USER_HTTPS_PROXY

# -------------------------------------------

ENV USER_HTTP_PROXY=${USER_HTTP_PROXY}
ENV USER_HTTPS_PROXY=${USER_HTTPS_PROXY}

# create volume and copy everything there
# VOLUME [ "/installation" ]
ADD installation /installation

# for any script in /installation, including subdirs, except for /installation/packages
# convert CRLF to LF
RUN find /installation -type f -not -path "/installation/packages/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find /installation -type f -name "*.sh" -exec chmod +x {} \;

# # convert CRLF to LF
# RUN find /installation/scripts -type f -exec sed -i 's/\r$//' {} \;
# RUN chmod +x /installation/scripts/*

RUN env

# set up container environment
RUN /installation/scripts/setup-env.sh

# set up apt
RUN apt update
RUN apt-get install --reinstall -y ca-certificates

# setup ssh
RUN /installation/scripts/setup-ssh.sh

# install essentials
RUN /installation/scripts/install-essentials.sh

# install additional apps
RUN /installation/custom-scripts/custom-install-apps.sh

# clean up
RUN /installation/scripts/cleanup.sh

# setup entrypoint
ENTRYPOINT ["/installation/scripts/entrypoint-default.sh"]

# # install apps to the image
# FROM base AS install-apps-to-image
# RUN echo "installing apps to image, in /apps"
# RUN mkdir -p /apps
# RUN /installation/scripts/on-first-run.sh
# ENV CHECK_AND_DO_INIT=false

# # install apps to a volume on first run
# FROM base AS install-apps-to-volume
# RUN echo "apps will be installed to a volume /apps on first run"
# VOLUME [ "/apps" ]
# ENV CHECK_AND_DO_INIT=true