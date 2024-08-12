#!/bin/bash

# install nvm and nodejs
export DEBIAN_FRONTEND=noninteractive

stage_dir=$PEI_STAGE_DIR_2
tmp_dir=$stage_dir/tmp

# do we have tmp/nvm directory? if not, git clone nvm
if [ ! -d "$tmp_dir/nvm" ]; then
    echo "cloning nvm to ~/.nvm ..."
    git clone https://github.com/nvm-sh/nvm.git .nvm
else
    # copy tmp/nvm to ~/.nvm
    echo "copying $tmp_dir/nvm to $HOME/.nvm ..."
    cp -r $tmp_dir/nvm $HOME/.nvm
fi

read -r -d '' NVM_SCRIPT << 'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF

# add NVM_SCRIPT to ~/.bashrc
echo "" >> ~/.bashrc
echo "$NVM_SCRIPT" >> ~/.bashrc
echo "" >> ~/.bashrc