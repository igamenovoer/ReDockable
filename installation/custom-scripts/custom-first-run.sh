#!/bin/bash

# commands that should run on the first time the container is started
# usually, this is used to install additional software or to configure the system

# add your own first-run commands here

echo "Running first-run custom commands..."
echo "You can add your own first-run commands to custom-first-run.sh"

# install conda
echo "Installing Miniconda"
bash /installation/conda/install-miniconda.sh