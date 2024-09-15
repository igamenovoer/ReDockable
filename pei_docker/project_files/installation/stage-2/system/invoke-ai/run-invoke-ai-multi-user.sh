#!/bin/bash

# get directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# allow access to all environment variables in /etc/environment
export $(cat /etc/environment | grep -v ^# | xargs)

# start invoke ai services for multiple users
# parameters are given as environment variables
# AI_INSTALL_DIR is the directory where invoke ai's .venv is installed, $AI_INSTALL_DIR/.venv must exist, otherwise check for INVOKEAI_ROOT
# AI_USERS is a list of users, separated by comma
# AI_PORTS is a list of ports, separated by comma, each port corresponds to a user
# AI_DEVICES is a list of devices, separated by comma, each device corresponds to a user
# devices can be cuda, cuda:<device_id>, cpu, mps

venv_dir=""

# check if AI_INSTALL_DIR is set, use it as the directory where invoke ai's .venv is installed
# otherwise, check if INVOKEAI_ROOT is set, use it as the directory where invoke ai's .venv is installed
# otherwise, raise error

if [ -z "$AI_INSTALL_DIR" ]; then
    echo "AI_INSTALL_DIR is not set, trying to use INVOKEAI_ROOT"
    if [ -z "$INVOKEAI_ROOT" ]; then
        echo "INVOKEAI_ROOT is not set, exit"
        exit 1
    else
        echo "INVOKEAI_ROOT is set, using it as the directory where invoke ai's .venv is installed"
        venv_dir=$INVOKEAI_ROOT/.venv
    fi
else
    echo "AI_INSTALL_DIR is set, using it as the directory where invoke ai's .venv is installed"
    venv_dir=$AI_INSTALL_DIR/.venv
fi

# check if AI_INSTALL_DIR is set
# if [ -z "$AI_INSTALL_DIR" ]; then
#     echo "AI_INSTALL_DIR is not set"
#     exit 1
# fi
# venv_dir=$AI_INSTALL_DIR/.venv

# check if AI_USERS is set
if [ -z "$AI_USERS" ]; then
    echo "AI_USERS is not set"
    exit 1
fi

# check if AI_PORTS is set
if [ -z "$AI_PORTS" ]; then
    echo "AI_PORTS is not set"
    exit 1
fi

# check if AI_DEVICES is set
if [ -z "$AI_DEVICES" ]; then
    echo "AI_DEVICES is not set"
    exit 1
fi

# split AI_USERS, AI_PORTS, AI_DEVICES
IFS=',' read -r -a users <<< "$AI_USERS"
IFS=',' read -r -a ports <<< "$AI_PORTS"
IFS=',' read -r -a devices <<< "$AI_DEVICES"

# check if the number of users, ports, devices are the same
if [ ${#users[@]} -ne ${#ports[@]} ] || [ ${#users[@]} -ne ${#devices[@]} ]; then
    echo "Number of users, ports, devices must be the same"
    exit 1
fi

# these env variables should be inherited by the tmux session
env_inherit="HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy"

# start invoke ai services for each user
for i in "${!users[@]}"; do
    user=${users[$i]}
    port=${ports[$i]}
    device=${devices[$i]}

    # create a new tmux session for each user
    tmux_session_name="invokeai-$user"

    # if tmux session already exists, kill it
    tmux kill-session -t $tmux_session_name

    # create a new tmux session, inherit the environment variables
    tmux new-session -d -s $tmux_session_name
    # tmux new-session -d -s $tmux_session_name

    # if device is cuda, assume device 0
    if [ $device == "cuda" ]; then
        device_id=0

    # if device is cuda:xxx, get the device id, default to 0
    elif [[ $device == cuda:* ]]; then
        device_id=${device:5}
        device=cuda
    
    else
        # if device is not cpu or mps, raise error
        if [ $device != "cpu" ] && [ $device != "mps" ]; then
            echo "Device $device is not supported"
            exit 1
        fi
    fi

    # set env variables for this user, in a the tmux_session_name
    tmux send-keys -t $tmux_session_name "source $DIR/setup-invoke-ai-envs.sh $user $port" Enter    

    # if device is cuda, set CUDA_VISIBLE_DEVICES inside tmux
    if [ $device == "cuda" ]; then
        tmux send-keys -t $tmux_session_name "export CUDA_VISIBLE_DEVICES=$device_id" Enter
    fi

    # for each env variable in env_inherit, check if it is set, if so, set it in the tmux session
    for env_var in $env_inherit; do
        if [ ! -z "${!env_var}" ]; then
            tmux send-keys -t $tmux_session_name "export $env_var=${!env_var}" Enter
        fi
    done

    # start invoke ai in tmux
    tmux send-keys -t $tmux_session_name "source $venv_dir/bin/activate" Enter
    tmux send-keys -t $tmux_session_name "$venv_dir/bin/invokeai-web" Enter

    echo "Started InvokeAI for user $user on port $port with device $device"
    echo "tmux session name: $tmux_session_name"
    echo "to attach to the session, use 'tmux attach -t $tmux_session_name'"

    # echo "Starting InvokeAI for user $user on port $port with device $device"
    # source $venv_dir/bin/activate
    # tmux new-session -d -s invokeai-$user "$venv_dir/bin/invokeai-web"
done