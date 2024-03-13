#!/bin/sh

# check if ssh is installed, if yes, start the service
if [ -f /etc/ssh/sshd_config ]; then
    echo "Starting ssh service..."
    service ssh start
fi

echo "Starting the shell..."
/bin/sh