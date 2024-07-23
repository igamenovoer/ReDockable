#!/bin/bash

# check if directory /soft/app/miniconda3 exists
# if yes, activate it
if [ -d "/soft/app/miniconda3" ]; then
    echo "miniconda3 found in /soft/app/miniconda3, activating ..."

    # if app-config exists in miniconda3, use it
    # .condarc and .pip are in app-config, link it to the home directory
    if [ -d "/soft/app/miniconda3/app-config" ]; then
    
        # condarc exists?
        if [ -f "/soft/app/miniconda3/app-config/.condarc" ]; then
            echo "linking .condarc ..."
            ln -s /soft/app/miniconda3/app-config/.condarc ~/.condarc
        fi
        
        # .pip exists?
        if [ -d "/soft/app/miniconda3/app-config/.pip" ]; then
            echo "linking .pip ..."
            ln -s /soft/app/miniconda3/app-config/.pip ~/.pip
        fi
        
    fi

    # activate conda
    source /soft/app/miniconda3/etc/profile.d/conda.sh

    # activate the base environment
    conda activate base
else
    echo "Trying to activate, but no miniconda3 found in /soft/app/miniconda3"
fi