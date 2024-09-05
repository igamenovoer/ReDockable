# syntax=docker/dockerfile:1

# the base image
ARG BASE_IMAGE

# -------------------------------------------
# create workspace for user
FROM ${BASE_IMAGE} AS default

# paths
ARG PEI_STAGE_HOST_DIR_2
ARG PEI_STAGE_DIR_2
ARG WITH_ESSENTIAL_APPS=false
ARG WITH_CUSTOM_APPS=false

# prefixes and paths
ARG PEI_PREFIX_DATA=data
ARG PEI_PREFIX_APPS=app
ARG PEI_PREFIX_WORKSPACE=workspace
ARG PEI_PREFIX_VOLUME=volume
ARG PEI_PREFIX_IMAGE=image
ARG PEI_PATH_HARD=/hard
ARG PEI_PATH_SOFT=/soft

# derive from stage-1
ARG PEI_HTTP_PROXY_2
ARG PEI_HTTPS_PROXY_2
ARG ENABLE_GLOBAL_PROXY
ARG REMOVE_GLOBAL_PROXY_AFTER_BUILD

# bake environment variables into the image?
ARG PEI_BAKE_ENV_STAGE_1=false

# override stage-1 proxy settings
ENV PEI_HTTP_PROXY_2=${PEI_HTTP_PROXY_2}
ENV PEI_HTTPS_PROXY_2=${PEI_HTTPS_PROXY_2}

# envs
ENV PEI_PREFIX_DATA=${PEI_PREFIX_DATA}
ENV PEI_PREFIX_APPS=${PEI_PREFIX_APPS}
ENV PEI_PREFIX_WORKSPACE=${PEI_PREFIX_WORKSPACE}
ENV PEI_PREFIX_VOLUME=${PEI_PREFIX_VOLUME}
ENV PEI_PREFIX_IMAGE=${PEI_PREFIX_IMAGE}
ENV PEI_PATH_HARD=${PEI_PATH_HARD}
ENV PEI_PATH_SOFT=${PEI_PATH_SOFT}

# for user to directly access soft paths
ENV PEI_SOFT_APPS=${PEI_PATH_SOFT}/${PEI_PREFIX_APPS}
ENV PEI_SOFT_WORKSPACE=${PEI_PATH_SOFT}/${PEI_PREFIX_WORKSPACE}
ENV PEI_SOFT_DATA=${PEI_PATH_SOFT}/${PEI_PREFIX_DATA}

ENV PEI_STAGE_DIR_2=${PEI_STAGE_DIR_2}

# -------------------------------------------
# install essentials

# copy installation/internals and installation/system to the image, do apt installs first
ADD ${PEI_STAGE_HOST_DIR_2}/internals ${PEI_STAGE_DIR_2}/internals
ADD ${PEI_STAGE_HOST_DIR_2}/generated ${PEI_STAGE_DIR_2}/generated
ADD ${PEI_STAGE_HOST_DIR_2}/system ${PEI_STAGE_DIR_2}/system

# install dos2unix, needed for converting CRLF to LF
RUN apt install -y dos2unix

# convert CRLF to LF for scripts in internals and system
# RUN find $PEI_STAGE_DIR_2 -type f -not -path "$PEI_STAGE_DIR_2/tmp/*" -exec sed -i 's/\r$//' {} \;
RUN find $PEI_STAGE_DIR_2 -type f -name "*.sh" -exec dos2unix {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $PEI_STAGE_DIR_2 -type f -name "*.sh" -exec chmod +x {} \;

# setup and show env
RUN $PEI_STAGE_DIR_2/internals/setup-env.sh && env

# create soft and hard directories
RUN $PEI_STAGE_DIR_2/internals/create-dirs.sh

# install things
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $PEI_STAGE_DIR_2/internals/install-essentials.sh

# setup profile d
RUN $PEI_STAGE_DIR_2/internals/setup-profile-d.sh

# -------------------------------------------
# run custom scripts

# copy the installation scripts to the image
# ADD ${PEI_STAGE_HOST_DIR_2}/custom ${PEI_STAGE_DIR_2}/custom
# ADD ${PEI_STAGE_HOST_DIR_2}/generated ${PEI_STAGE_DIR_2}/generated
# ADD ${PEI_STAGE_HOST_DIR_2}/tmp ${PEI_STAGE_DIR_2}/tmp
ADD ${PEI_STAGE_HOST_DIR_2} ${PEI_STAGE_DIR_2}

# convert CRLF to LF
# RUN find $PEI_STAGE_DIR_2 -type f -not -path "$PEI_STAGE_DIR_2/tmp/*" -exec sed -i 's/\r$//' {} \;
RUN find $PEI_STAGE_DIR_2 -type f -name "*.sh" -exec dos2unix {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $PEI_STAGE_DIR_2 -type f -name "*.sh" -exec chmod +x {} \;

# install custom apps
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $PEI_STAGE_DIR_2/internals/custom-on-build.sh

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $PEI_STAGE_DIR_2/internals/setup-users.sh &&\
    $PEI_STAGE_DIR_2/internals/cleanup.sh

# override the entrypoint
RUN cp $PEI_STAGE_DIR_2/internals/entrypoint.sh /entrypoint.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# install apps to the image
# FROM default AS store-in-image
# ENV X_STORAGE_CHOICE="image-first"
# RUN /installation/scripts/create-links.sh