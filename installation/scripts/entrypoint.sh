#!/bin/sh

# run the on-first-run.sh script
sh /installation/scripts/on-first-run.sh

# check if ssh is installed, if yes, start the service
if [ -f /etc/ssh/sshd_config ]; then
    echo "Starting ssh service..."
    service ssh start
fi

echo "Starting the shell..."
export SHELL=/bin/bash
/bin/bash