#!/bin/sh

# see https://doc.magnum.graphics/magnum/building.html#building-packages-deb
# see https://doc.magnum.graphics/corrade/building-corrade.html#building-corrade-packages-deb


# check if locale is set, if not, set it
if [ -z "$LANG" ]; then

    # do we have locale-gen?
    if [ -x /usr/sbin/locale-gen ]; then
        # if not, install it
        apt-get update
        apt-get install -y locales
    fi

    locale-gen en_US.UTF-8
fi

# install opengl essentials
apt install libgl-dev libopenal-dev libglfw3-dev libsdl2-dev

# install debhelper for building debian packages
apt install debhelper

# push current directory
pushd .

cd $PEI_STAGE_DIR_2/tmp

# create a temporary directory and download corrade
echo "Downloading Corrade ..."
git clone https://github.com/mosra/corrade && cd corrade

echo "Building Corrade ..."
ln -s package/debian .
dpkg-buildpackage --no-sign

echo "Installing Corrade ..."
dpkg -i ../corrade*.deb

# back to the temporary directory
cd ..

# create a temporary directory and download magnum
echo "Downloading Magnum ..."
git clone https://github.com/mosra/magnum && cd magnum

echo "Building Magnum ..."
ln -s package/debian .
dpkg-buildpackage --no-sign

echo "Installing Magnum ..."
dpkg -i ../magnum*.deb

echo "Done"

popd