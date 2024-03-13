# syntax=docker/dockerfile:1

# the base image
# FROM nvidia/cuda:11.8.0-base-ubuntu22.04
ARG BASE_IMAGE=nvidia/cuda:12.3.2-base-ubuntu22.04
FROM ${BASE_IMAGE}

# installation parts on/off
ARG WITH_ESSENTIAL_APPS=false
ARG WITH_ADDITIONAL_APPS=false
ARG WITH_SSH=false

# if you want to use proxy for apt, set this to host proxy
# like http://host.docker.internal:7890
ARG APT_HTTP_PROXY

# keep the http proxy for apt after installation?
ARG APT_RETAIN_HTTP_PROXY=false

# use other apt source?
ARG APT_SOURCE_FILE

# if you want the container to use proxy for shell, set this to host proxy
ARG SHELL_HTTP_PROXY

# optional http proxy, used when accessing blocked sites whenever needed
ARG OPTIONAL_HTTP_PROXY

# ssh user and password
ARG SSH_USER_NAME
ARG SSH_USER_PASSWORD

# -------------------------------------------

# copy all scripts to /initscripts in the container
ADD initscripts /initscripts
RUN chmod +x /initscripts/*

RUN env

# set up container environment
RUN /initscripts/setup-env.sh

# set up apt
RUN apt update
RUN apt-get install --reinstall -y ca-certificates

# setup ssh
RUN /initscripts/setup-ssh.sh

# install essentials
RUN /initscripts/install-essentials.sh

# install additional apps
RUN /initscripts/install-additional-apps.sh

# clean up
RUN /initscripts/cleanup.sh

# setup entrypoint
ENTRYPOINT ["/initscripts/entrypoint.sh"]