#!/bin/bash

# install latest lts nodejs with nvm
export DEBIAN_FRONTEND=noninteractive

bash -c " . $HOME/.nvm/nvm.sh ; nvm install --lts ; "

echo "Installing pnpm ..."
wget -qO- https://get.pnpm.io/install.sh | sh -

# set npm registry to taobao
echo "Setting npm registry to taobao ..."
bash -c " . $HOME/.nvm/nvm.sh ; npm config set registry https://registry.npmmirror.com/ ; "

echo "Done installing nodejs and pnpm."