#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# for every user, add $DIR/_setup-cuda.sh to their .bashrc, so that it is executed on every run
# execute in user context with su
for user in $(ls /home); do
    echo "Adding $DIR/_setup-cuda.sh to /home/$user/.bashrc ..."
    su - $user -c "echo 'source $DIR/_setup-cuda.sh' >> /home/$user/.bashrc"
done

# also do it for root
echo "Adding $DIR/_setup-cuda.sh to /root/.bashrc ..."
echo "source $DIR/_setup-cuda.sh" >> /root/.bashrc
