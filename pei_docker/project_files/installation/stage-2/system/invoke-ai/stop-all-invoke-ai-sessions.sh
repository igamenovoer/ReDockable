#!/bin/bash

# kill all invoke-ai tmux sessions using ctrl+c
# invoke-ai sessions are named invokeai-<username>
echo "Stopping all InvokeAI tmux sessions ..."
tmux list-sessions | grep -oP 'invokeai-\w+' | xargs -I {} tmux send-keys -t {} C-c

# wait for 5 seconds
echo "Waiting for 10 seconds for InvokeAI to stop ..."
sleep 10

# then kill the above tmux sessions
echo "Killing InvokeAI tmux sessions ..."
tmux list-sessions | grep -oP 'invokeai-\w+' | xargs -I {} tmux kill-session -t {}