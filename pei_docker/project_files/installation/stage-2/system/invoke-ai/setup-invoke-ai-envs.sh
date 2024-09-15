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

    # if AI_DATA_DIR is set, use it
    if [ -z "$AI_DATA_DIR" ]; then
        base_dir=/soft/data/invokeai-data
    else
        base_dir=$AI_DATA_DIR
    fi

    # base_dir exists? if not, mkdir it
    echo "InvokeAI data directory: $base_dir"
    if [ ! -d "$base_dir" ]; then
        echo "$base_dir not found, creating it"
        mkdir -p $base_dir
    fi

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
    export INVOKEAI_LEGACY_CONF_DIR="$base_dir/common/legacy_conf"
    export INVOKEAI_CUSTOM_NODES_DIR="$base_dir/common/custom_nodes"

    # do we have INVOKEAI_HF_HOME set?
    if [ -z "$INVOKEAI_HF_HOME" ]; then
        # if not, set it
        export INVOKEAI_HF_HOME="$base_dir/common/hf_home"
    else
        export INVOKEAI_HF_HOME="$base_dir/common/hf_home"
    fi
    export HF_HOME="$INVOKEAI_HF_HOME"

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
    export INVOKEAI_PROFILES_DIR="$base_dir/users/$username/profiles"

    # show it 
    echo "InvokeAI environment variables:"
    env | grep INVOKEAI_

fi