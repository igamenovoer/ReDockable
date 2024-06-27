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
FROM ${BASE_IMAGE} AS default

# directories
# things are stored in hard paths, but linked by soft paths

# hard path is like this:
# X_PATH_HARD_BASE/X_PREFIX_IMAGE_STORAGE/X_PREFIX_APPS
# X_PATH_HARD_BASE/X_PREFIX_VOLUME_STORAGE/X_PREFIX_APPS

# soft path is like this:
# X_PATH_SOFT_BASE/X_PREFIX_APPS

ENV X_PATH_HARD_BASE="/hard"
ENV X_PATH_SOFT_BASE="/soft"

ENV X_PREFIX_APPS="apps"
ENV X_PREFIX_DATA="data"
ENV X_PREFIX_WORKSPACE="workspace"

# subdirectories under this path is external mounted volumes
ENV X_PREFIX_VOLUME_STORAGE="volume"

# subdirectories under this path is internal to the image
ENV X_PREFIX_IMAGE_STORAGE="image"

# install apps on first run
ENTRYPOINT [ "/installation/scripts/entrypoint-runtime.sh" ]

# create soft directory
RUN mkdir -p $X_PATH_SOFT_BASE
RUN chmod 777 $X_PATH_SOFT_BASE

# create in-image storage paths
RUN echo "creating in-image storage paths"
RUN mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_APPS
RUN chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_APPS

RUN mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_DATA
RUN chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_DATA

RUN mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_WORKSPACE
RUN chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_WORKSPACE

# storage choice, can be
# volume_first, image_first, volume_only, image_only
# volume_first: use volume if exists, otherwise use image
# image_first: use image if exists, otherwise use volume
# volume_only: use volume only
# image_only: use image only

ENV X_STORAGE_CHOICE="volume_first"

# -------------------------------------------

# install apps to automatically created docker volume, you can create your own in docker-compose
FROM default AS with-built-in-volume

# create all sub dirs with anonymous volume
RUN echo "creating anonymous volume for apps, data, and workspace"
RUN mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_APPS
RUN chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_APPS

RUN mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_DATA
RUN chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_DATA

RUN mkdir -p $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_WORKSPACE
RUN chmod 777 $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_WORKSPACE

VOLUME $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_APPS
VOLUME $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_DATA
VOLUME $X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE/$X_PREFIX_WORKSPACE

# install apps to the image
FROM default AS store-in-image
ENV X_STORAGE_CHOICE="image_only"
RUN /installation/scripts/create-links.sh

# install apps only to volume
# FROM default AS store-in-volume
# ENV X_STORAGE_CHOICE="volume_only"