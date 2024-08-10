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

ENV INSTALL_DIR_CONTAINER_2=${INSTALL_DIR_CONTAINER_2}

# -------------------------------------------
# install essentials

# copy installation/internals and installation/system to the image, do apt installs first
ADD ${INSTALL_DIR_HOST_2}/internals ${INSTALL_DIR_CONTAINER_2}/internals
ADD ${INSTALL_DIR_HOST_2}/system ${INSTALL_DIR_CONTAINER_2}/system

# install dos2unix, needed for converting CRLF to LF
RUN apt install -y dos2unix

# convert CRLF to LF for scripts in internals and system
# RUN find $INSTALL_DIR_CONTAINER_2 -type f -not -path "$INSTALL_DIR_CONTAINER_2/tmp/*" -exec sed -i 's/\r$//' {} \;
RUN find $INSTALL_DIR_CONTAINER_2 -type f -name "*.sh" -exec dos2unix {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_2 -type f -name "*.sh" -exec chmod +x {} \;

# setup and show env
RUN $INSTALL_DIR_CONTAINER_2/internals/setup-env.sh && env

# create soft and hard directories
RUN $INSTALL_DIR_CONTAINER_2/internals/create-dirs.sh

# install things
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $INSTALL_DIR_CONTAINER_2/internals/install-essentials.sh

# setup profile d
RUN $INSTALL_DIR_CONTAINER_2/internals/setup-profile-d.sh

# -------------------------------------------
# run custom scripts

# copy the installation scripts to the image
# ADD ${INSTALL_DIR_HOST_2}/custom ${INSTALL_DIR_CONTAINER_2}/custom
# ADD ${INSTALL_DIR_HOST_2}/generated ${INSTALL_DIR_CONTAINER_2}/generated
# ADD ${INSTALL_DIR_HOST_2}/tmp ${INSTALL_DIR_CONTAINER_2}/tmp
ADD ${INSTALL_DIR_HOST_2} ${INSTALL_DIR_CONTAINER_2}

# convert CRLF to LF
# RUN find $INSTALL_DIR_CONTAINER_2 -type f -not -path "$INSTALL_DIR_CONTAINER_2/tmp/*" -exec sed -i 's/\r$//' {} \;
RUN find $INSTALL_DIR_CONTAINER_2 -type f -name "*.sh" -exec dos2unix {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_2 -type f -name "*.sh" -exec chmod +x {} \;

# install custom apps
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $INSTALL_DIR_CONTAINER_2/internals/custom-on-build.sh

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    $INSTALL_DIR_CONTAINER_2/internals/setup-users.sh &&\
    $INSTALL_DIR_CONTAINER_2/internals/cleanup.sh

# override the entrypoint
RUN cp $INSTALL_DIR_CONTAINER_2/internals/entrypoint.sh /entrypoint.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# install apps to the image
# FROM default AS store-in-image
# ENV X_STORAGE_CHOICE="image-first"
# RUN /installation/scripts/create-links.sh