# syntax=docker/dockerfile:1

# the base image
# FROM nvidia/cuda:11.8.0-base-ubuntu22.04
ARG BASE_IMAGE

# if you want to use proxy for apt, set this to host proxy
# like http://host.docker.internal:7890
ARG APT_HTTP_PROXY

# keep the http proxy for apt after installation?
ARG KEEP_APT_HTTP_PROXY=false

# if you want the container to use proxy for shell, set this to host proxy
ARG SHELL_HTTP_PROXY

# optional http proxy, used when accessing blocked sites whenever needed
ARG OPTIONAL_HTTP_PROXY

# -------------------------------------------
# create workspace for user
FROM ${BASE_IMAGE} AS base
ENTRYPOINT [ "/installation/scripts/entrypoint-runtime.sh" ]

# create /app folder
# give all users read/write access to the that
RUN mkdir -p /apps
RUN chmod 777 /apps

# install apps to a volume on first run
FROM base AS install-apps-to-volume
RUN echo "apps will be installed to a volume /apps on first run"
VOLUME [ "/apps" ]

# install apps to the image
FROM base AS install-apps-to-image
RUN echo "installing apps to image, in /apps"
RUN /installation/scripts/on-first-run.sh
