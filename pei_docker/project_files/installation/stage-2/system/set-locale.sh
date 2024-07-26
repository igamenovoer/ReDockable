#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

apt-get install -y locales
locale-gen en_US.UTF-8