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

ENV INSTALL_DIR_CONTAINER_2=${INSTALL_DIR_CONTAINER_2}

# copy the installation scripts to the image
ADD ${INSTALL_DIR_HOST_2} ${INSTALL_DIR_CONTAINER_2}

# convert CRLF to LF
RUN find $INSTALL_DIR_CONTAINER_2 -type f -not -path "$INSTALL_DIR_CONTAINER_2/packages/*" -exec sed -i 's/\r$//' {} \;

# add chmod+x to all scripts, including all subdirs
RUN find $INSTALL_DIR_CONTAINER_2 -type f -name "*.sh" -exec chmod +x {} \;

# show env
RUN env

# install essentials and custom apps
RUN $INSTALL_DIR_CONTAINER_2/internals/install-essentials.sh &&\
    $INSTALL_DIR_CONTAINER_2/custom/custom-install-apps.sh &&\
    $INSTALL_DIR_CONTAINER_2/internals/cleanup.sh

# override the entrypoint
RUN cp $INSTALL_DIR_CONTAINER_2/internals/entrypoint.sh /entrypoint.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# install apps to the image
# FROM default AS store-in-image
# ENV X_STORAGE_CHOICE="image_first"
# RUN /installation/scripts/create-links.sh