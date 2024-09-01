#!/bin/bash

# set env variables for InvokeAI
# input argument is <username> <port>
# username is the user for this invokeai instance
# port is the port for this invokeai instance

# check if user and port are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <username> <port>"
else

    # get user and port
    username=$1
    port=$2

    cache_ram_gb=12.0
    cache_gpu_ram_gb=10.0

    # set env variables
    base_dir=/soft/data/invokeai-data

    # variables independent of user
    export INVOKEAI_HOST="0.0.0.0"
    export INVOKEAI_PATCHMATCH="false"
    export INVOKEAI_MODELS_DIR="$base_dir/common/models"

    # do we have INVOKEAI_CONVERT_CACHE_DIR set?
    if [ -z "$INVOKEAI_CONVERT_CACHE_DIR" ]; then
        # if not, set it
        export INVOKEAI_CONVERT_CACHE_DIR="$base_dir/common/convert_cache"
    fi

    export INVOKEAI_DOWNLOAD_CACHE_DIR="$base_dir/common/download_cache"
    export INVOKEAI_CUSTOM_NODES_DIR="$base_dir/common/custom_nodes"

    # do we have INVOKEAI_RAM set?
    if [ -z "$INVOKEAI_RAM" ]; then
        # if not, set it
        export INVOKEAI_RAM="$cache_ram_gb"
    fi

    # do we have INVOKEAI_VRAM set?
    if [ -z "$INVOKEAI_VRAM" ]; then
        # if not, set it
        export INVOKEAI_VRAM="$cache_gpu_ram_gb"
    fi

    export INVOKEAI_LAZY_OFFLOAD="true"

    # set user specific variables
    export INVOKEAI_PORT="$port"
    export INVOKEAI_ROOT="$base_dir/users/$username"
    export INVOKEAI_DB_DIR="$base_dir/users/$username/db"
    export INVOKEAI_OUTPUTS_DIR="$base_dir/users/$username/outputs"
    export INVOKEAI_STYLE_PRESETS_DIR="$base_dir/users/$username/style_presets"

    # show it 
    echo "InvokeAI environment variables:"
    env | grep INVOKEAI_

fi