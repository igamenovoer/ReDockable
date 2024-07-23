#!/bin/bash

# do something for each user at the end of build
SCRIPTFILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
echo "Executing $SCRIPTFILE"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# add the custom-on-user-login.sh to .bashrc for each user
for user in $(ls /home); do
    # execute in user context using su
    su - $user -c "echo 'source $DIR/custom-on-user-login.sh' >> /home/$user/.bashrc"
done

# also do it for root
echo "source $DIR/custom-on-user-login.sh" >> /root/.bashrc

