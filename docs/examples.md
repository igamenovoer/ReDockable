# Examples

[](){#basic-ssh}
## Basic Ubuntu image with SSH support

This is the most basic example of creating an image with SSH support. The image is based on `ubuntu:24.04` and has three users: `me`, `you`, and `root`. The passwords for the users are `123456`, `654321`, and `root` respectively. The SSH server is running on port `22` and mapped to host port `2222`. 

To accelerate apt installation in China, the `apt` source is set to `tuna`. For other options, see the full [config file](index.md) for documentation. If this option is omitted, the default source will be used.

```yaml
# user_config.yml under project directory

stage_1:
  image:
    base: ubuntu:24.04
    output: pei-image:stage-1
  ssh:
    enable: true
    port: 22
    host_port: 2222
    users:
      me:
        password: '123456'
      you:
        password: '654321'
      root:
        password: root
  apt:
    repo_source: tuna
```

With this `user_config.yml` in side your project dir, do the followings to build and run the image:

```bash
# assuming the project dir is /path/to/project

python -m pei_docker.pei configure --project-dir=/path/to/project

cd /path/to/project
docker compose build stage-1 --progress=plain --no-cache
docker compose up stage-1
```

### With docker run
If you prefer to use `docker run` to run the image, you can copy-paste the `docker-compose.yml` file into [Decomposerize](https://www.decomposerize.com/) to get the `docker run` command. The command will look like this:

```bash
docker run -i -t --add-host host.docker.internal:host-gateway -p 2222:22 pei-image:stage-1 /bin/bash
```

## GPU image with external storage

This example is based on [the basic ssh image](#basic-ssh), which demonstrates how to use GPU in the container. The image is based on `nvidia/cuda:11.8.0-runtime-ubuntu22.04` that makes use of the GPU. As such, the `device` section is added to the `stage_1` and `stage_2` sections, which are set to `gpu`.

```yaml
stage_1:
  image:
    base: nvidia/cuda:11.8.0-runtime-ubuntu22.04
    output: pei-image:stage-1
  ssh:
    enable: true
    port: 22
    host_port: 2222
    users:
      me:
        password: '123456'
      root:
        password: root
  apt:
    repo_source: tuna
  device:
    type: gpu
stage_2:
  image:
    output: pei-image:stage-2
  device:
    type: gpu
  storage:
    app:
      type: host
      host_path: d:/code/PeiDocker/build/storage/app
    data:
      type: host
      host_path: d:/code/PeiDocker/build/storage/data
    workspace:
      type: host
      host_path: d:/code/PeiDocker/build/storage/workspace
```

### External storage with host directory

The `stage-2` image has three external storage directories: `app`, `data`, and `workspace` (note that the directory names are **NOT CUSTOMIZABLE**, they are **predefined), where specified host directories are mounted. In the container, you can access these directories through `/soft/app`, `/soft/data`, and `/soft/workspace`, which are linked to  `/app`, `/data`, and `/workspace` under the `/hard/volume`. In this example, the host directories are `d:/code/PeiDocker/build/storage/app`, `d:/code/PeiDocker/build/storage/data`, and `d:/code/PeiDocker/build/storage/workspace` (Windows path).

### With docker-compose

To build and run the image, do the followings:

```bash
# assuming the project dir is /path/to/project

# build stage-1
docker compose -f /path/to/project/docker-compose.yml build stage-1 --progress=plain --no-cache

# build stage-2
docker compose -f /path/to/project/docker-compose.yml build stage-2 --progress=plain --no-cache

# start stage-2
docker compose -f /path/to/project/docker-compose.yml up stage-2
```

After that, you can ssh into the container with the following command:

```bash
ssh -p 2222 me@127.0.0.1
```


### With docker run

If you are using `docker run` to run the image, you can copy-paste the `docker-compose.yml` file into [Decomposerize](https://www.decomposerize.com/) to get the `docker run` command. The command will look like this, note that you need to add `--gpus all` manually:

```bash
# you only need to run stage-2
docker run --gpus all -i -t --add-host host.docker.internal:host-gateway -p 2222:22 -v d:/code/PeiDocker/build/storage/app:/hard/volume/app -v d:/code/PeiDocker/build/storage/data:/hard/volume/data -v d:/code/PeiDocker/build/storage/workspace:/hard/volume/workspace pei-image:stage-2 /bin/bash
```

[](){#external-storage}
## Using docker volume as external storage

Using [docker volumes](https://docs.docker.com/storage/volumes/) is preferred if you run the image locally, because it is more efficient, and will not get lost when the container is removed. Docker volumes can be created automatically, or [manually](https://docs.docker.com/reference/cli/docker/volume/create/) with a given name that can be used to mount the volume to the container. 

This example is based on [the basic ssh image](#basic-ssh), which demonstrates how to use existing docker volumes as external storage. The `stage-2` image has three external storage directories: `app`, `data`, and `workspace` (note that the directory names are **NOT CUSTOMIZABLE**, they are **predefined**), where **docker volumes** are mounted. 


```yaml
# user_config.yml
stage_1:
  image:
    base: ubuntu:24.04
    output: pei-image:stage-1
  ssh:
    enable: true
    port: 22
    host_port: 2222
    users:
      me:
        password: '123456'
  apt:
    repo_source: tuna
stage_2:
  image:
    output: pei-image:stage-2
  storage:
    app:
      type: auto-volume
    data:
      type: manual-volume
      volume_name: my_data
    workspace:
      type: manual-volume
      volume_name: my_workspace
```

`app` is an **auto-volume**, which means it will be created automatically. `data` and `workspace` are **manual-volumes**, which means they are created manually with the names `my_data` and `my_workspace` first, and then mounted to the container. To create these volumes, use the following commands

```bash
docker volume create my_data
docker volume create my_workspace
``` 

You can check the volumes with `docker volume ls`.

If you are using the [docker desktop](https://www.docker.com/products/docker-desktop) on Windows, you will see this:

![docker desktop volumes](images/docker-desktop-volumes.png)

In the container, you can access these directories through `/soft/app`, `/soft/data`, and `/soft/workspace`, which are linked to  `/app`, `/data`, and `/workspace` under the `/hard/volume`.


### With docker run

If you are using `docker run` to run the image, you can copy-paste the `docker-compose.yml` file into [Decomposerize](https://www.decomposerize.com/) to get the `docker run` command. Note that you will have to create all volumes manully. The command will look like this:

```bash
# using docker run, you will have to create all volumes manually
docker volume create app
docker volume create my_data
docker volume create my_workspace
docker run -i -t --add-host host.docker.internal:host-gateway -p 2222:22 -v app:/hard/volume/app -v data:/hard/volume/data -v workspace:/hard/volume/workspace pei-image:stage-2 /bin/bash

# you don't need to run stage-1
# docker run -i -t --add-host host.docker.internal:host-gateway -p 2222:22 pei-image:stage-1 /bin/bash
```

[](){#miniconda-in-image}
## Install miniconda in image

**IMPORTANT NOTE**: The following example is for demonstration purposes only. It is **not recommended** to install miniconda (or any other apps) in the image, because it will make the image size larger, and later modifications (such as `conda install xxx`) will get lost when container is removed. It is recommended to install miniconda in the volume storage `/hard/volume/app`, and copy them to the image storage `/hard/image/app` when you decide to bake them into image. However, **external storage only exists in stage-2**.

To install miniconda during build, you can make use of custom scripts. PeiDocker allows you to add your scripts in the `project_dir/installation/stage-<1,2>/custom`, and then specify them in the `user_config.yml` file.

```yaml
# user_config.yml
stage_1:
  image:
    base: nvidia/cuda:12.3.2-runtime-ubuntu22.04
    output: pei-image:stage-1
  ssh:
    enable: true
    port: 22
    host_port: 2222
    users:
      me:
        password: '123456'
      root:
        password: root
  apt:
    repo_source: tuna
  device:
    type: gpu
stage_2:
  image:
    output: pei-image:stage-2
  device:
    type: gpu
  storage:
    app:
      type: image
    data:
      type: image
    workspace:
      type: image
  custom:
    on_build:
    - stage-2/custom/install-my-conda.sh
```

In the above example, the script `install-my-conda.sh` is placed in the `project_dir/installation/stage-2/custom` directory. The script will be executed during the build of the `stage-2` image. Below is the content of the script. It first checks if the miniconda installation file exists in the `/tmp` directory, and if not, downloads it from the tuna mirror. Then it installs miniconda to `/hard/image/app/miniconda3`, and initializes conda for all users. The conda and pip mirrors are set to the tuna mirror. Important points to note:

- The script is placed in the `project_dir/installation/stage-2/custom` directory.
- The package files are placed in the `project_dir/installation/stage-2/tmp` directory.
- You can access the installation directory of the `stage-2` image using the `INSTALL_DIR_CONTAINER_2` environment variable, likewise for `stage-1`. Note it will try to use external storage `\hard\volume\app` first, but because you have not mounted any external storage, it will use the image storage `\hard\image\app`.
- During build, you are root, so you shall execute commands for other users using `su - $user -c`.
- Remember to set DEBIAN_FRONTEND=noninteractive to prevent interactive prompts.

```bash
#!/bin/bash

# prevent interactive prompts
export DEBIAN_FRONTEND=noninteractive

# INSTALL_DIR_CONTAINER_2 points to where the installation/stage-2 is inside container
STAGE_2_DIR_IN_CONTAINER=$INSTALL_DIR_CONTAINER_2
echo "STAGE_2_DIR_IN_CONTAINER: $STAGE_2_DIR_IN_CONTAINER"

# the installation directory of miniconda3
# first check for volume storage at /hard/volume/app, if not found, use /hard/image/app
if [ -d "/hard/volume/app" ]; then
  # volume storage takes precedence, note that it only exists in stage-2
  CONDA_INSTALL_DIR="/hard/volume/app/miniconda3"
else
  # otherwise, use the image storage
  CONDA_INSTALL_DIR="/hard/image/app/miniconda3"
fi

# already installed? skip
if [ -d $CONDA_INSTALL_DIR ]; then
    echo "miniconda3 is already installed in $CONDA_INSTALL_DIR, skipping ..."
    exit 0
fi

# download the miniconda3 installation file yourself, and put it in the tmp directory
# it will be copied to the container during the build process
CONDA_PACKAGE_NAME="Miniconda3-latest-Linux-x86_64.sh"

# are you in arm64 platform? If so, use the arm64 version of miniconda3
if [ "$(uname -m)" = "aarch64" ]; then
    CONDA_PACKAGE_NAME="Miniconda3-latest-Linux-aarch64.sh"
fi

# download from
CONDA_DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/$CONDA_PACKAGE_NAME"

# download to
CONDA_DOWNLOAD_DST="$STAGE_2_DIR_IN_CONTAINER/tmp/$CONDA_PACKAGE_NAME"

# if the file does not exist, wget it from tuna
if [ ! -f $CONDA_DOWNLOAD_DST ]; then
    echo "downloading miniconda3 installation file ..."
    wget -O $CONDA_DOWNLOAD_DST $CONDA_DOWNLOAD_URL
fi

# install miniconda3 unattended
echo "installing miniconda3 to $CONDA_INSTALL_DIR ..."
bash $CONDA_DOWNLOAD_DST -b -p $CONDA_INSTALL_DIR

# make conda installation read/write for all users
echo "setting permissions for $CONDA_INSTALL_DIR ..."
chmod -R 777 $CONDA_INSTALL_DIR

echo "initializing conda for all users, including root ..."

# conda and pip mirror, for faster python package installation
# save the following content to a variable
read -r -d '' CONDA_TUNA << EOM
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  deepmodeling: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/
EOM

# tuna pip mirror
read -r -d '' PIP_TUNA << EOM
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple/

[install]
trusted-host=pypi.tuna.tsinghua.edu.cn
EOM

# aliyun pypi mirror, use it if tuna is slow
read -r -d '' PIP_ALIYUN << EOM
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOM

# add all user names to USER_LIST
USER_LIST="root"
for user in $(ls /home); do
    USER_LIST="$USER_LIST $user"
done

# for each user in USERS, initialize conda.
# remember to execute commands in the user context using su - $user -c
# otherwise the file will be owned by root
for user in $USER_LIST; do
    echo "initializing conda for $user ..."
    su - $user -c "$CONDA_INSTALL_DIR/bin/conda init"

    # if user is root, set home_dir to /root, otherwise /home/$user
    if [ "$user" = "root" ]; then
        home_dir="/root"
    else
        home_dir="/home/$user"
    fi

    # to use tuna mirror, replace the .condarc file with the pre-configured CONDA_TUNA
    echo "setting conda mirror for $user ..."    
    su - $user -c "echo \"$CONDA_TUNA\" > $home_dir/.condarc"

    # to use pip mirror, create a .pip directory and write the PIP_TUNA to pip.conf
    echo "setting pip mirror for $user ..."
    su - $user -c "mkdir -p $home_dir/.pip"
    su - $user -c "echo \"$PIP_TUNA\" > $home_dir/.pip/pip.conf"
done

# create a app-config directory in conda installation directory to save .condarc and .pip directory
# because when conda is installed in external storage, these files will be lost after container restart
# we can recover them from app-config if needed
echo "creating app-config directory in $CONDA_INSTALL_DIR ..."
mkdir -p $CONDA_INSTALL_DIR/app-config

# copy .condarc and .pip directory to app-config
echo "copying .condarc and .pip directory to app-config ..."
cp /root/.condarc $CONDA_INSTALL_DIR/app-config
cp -r /root/.pip $CONDA_INSTALL_DIR/app-config

# make it accessible to all users
echo "setting permissions for $CONDA_INSTALL_DIR/app-config ..."
chmod -R 777 $CONDA_INSTALL_DIR/app-config
```

## Install miniconda to external storage

To install miniconda to external storage, you can mount external storage ([How to use external storage?][external-storage]) to the `/hard/volume/app`, so that the miniconda installation will be saved there. The following example demonstrates how to install miniconda to the external storage.

First, create a docker volume named `my_app`:

```bash
docker volume create my_app
```

Then, modify the `user_config.yml` file as follows:

```yaml
stage_1:
  image:
    base: nvidia/cuda:12.3.2-runtime-ubuntu22.04
    output: pei-image:stage-1
  ssh:
    enable: true
    port: 22
    host_port: 2222
    users:
      me:
        password: '123456'
      root:
        password: root
  apt:
    repo_source: tuna
  device:
    type: gpu
stage_2:
  image:
    output: pei-image:stage-2
  device:
    type: gpu
  storage:
    app:
      type: manual-volume
      volume_name: my_app
    data:
      type: auto-volume
    workspace:
      type: auto-volume
  custom:
    on_first_run:
    - stage-2/custom/install-my-conda.sh
```

The example is based on [Install miniconda in image][miniconda-in-image], with the following changes:
- `app` is a **manual-volume**, which means it is created manually with the name `my_app`, and then mounted to the container. To create it, use `docker volume create my_app`.
- `data` and `workspace` are **auto-volumes**, which means they are created automatically.
- The `install-my-conda.sh` script is executed on the first run of the container, to install miniconda3 and setup conda for all users.

**IMPORTANT**: Here comes the critical part for using `on_first_run` commands. After the commands are run, they modify the **container**, not the **image**. If you want to save the changes to the image, you need to commit the container to the image. If you forgot to do that, changes are not saved, and the first-run commands will be run again when the container is recreated. 

To correct this, commit the container to the image after the first run:

```bash
docker commit <container_id> pei-image:stage-2
```

## Moving external storage to image

After you have installed apps to the external storage, you can move it to the image storage. This is useful when you want to bake the installed apps into the image. To do this, just copy the files from the external storage to the image storage. Inside the container, do the followings:

```bash
# inside container
# just copy /hard/volume/app to /hard/image/app, likewise for other directories
cp -r /hard/volume/app /hard/image/app

# for data and workspace, if you want to bake them into the image
# cp -r /hard/volume/data /hard/image/data
# cp -r /hard/volume/workspace /hard/image/workspace
```

And then, commit your container to image:
  
```bash
docker commit <container_id> pei-image:stage-2
```