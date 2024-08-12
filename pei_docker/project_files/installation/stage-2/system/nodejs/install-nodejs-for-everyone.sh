#!/bin/bash

# get current dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# for all users, install nodejs
echo "installing nodejs for all users ..."
for user in $(ls /home); do
  su - $user -c "bash $DIR/install-nvm.sh"
  su - $user -c "bash $DIR/install-nodejs.sh"
done