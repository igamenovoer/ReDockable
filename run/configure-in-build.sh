#!/bin/bash

# Configure the build directory with the default configuration file user_config.yml
python -m pei_docker.pei configure -p ./build

# Configure the build directory with the configuration file examples/minimal-ubuntu-ssh.yml
# python -m pei_docker.pei configure -p ./build -c examples/minimal-ubuntu-ssh.yml