# Welcome to PeiDocker

Don't keep your docker images around, keep the build files! If you ever want to make reproducible docker images but have no patience to learn Dockerfiles and docker-compose, PeiDocker is for you.

[PeiDocker (配 docker)](https://github.com/igamenovoer/PeiDocker) helps you script and organize your docker image building process without learning too much about Dockerfiles and docker-compose, it streamlines the building process and allows you to customize the image building and running behaviours using shell scripts. With PeiDocker, you can:

- Build images with SSH support.
- Install packages from public repository using proxy.
- Easily choose to install apps into the image, your host directory, or docker volumes, you can also switch between them after the image is built.
- Run custom commands during image building, such as setting up environment variables, installing packages, etc.
- Run custom commands when the container starts.

## How to use

* Install dependencies:

```sh
pip install click omegaconf attrs cattrs
```

* Create a new project:

```sh
# cd to the root of the git repository
cd /path/to/PeiDocker

# Create a new project in ./build or any other directory
python -m pei_docker.pei create -p ./build
```

* Edit the configuration file `user_config.yml` in the project directory (e.g.,`./build`) according to your needs.
* Generate the `docker-compose.yml` file in the project directory:

```sh
python -m pei_docker.pei configure -p ./build
```

* Build the docker images. There are two images to be built, namely `stage-1` and `stage-2`. `stage-1` is intended to be a base image, installing system apps using `apt install`, `stage-2` is intended to be a final image based on `stage-1`, installing custom apps using downloaded packages like `.deb`. External storage is only available in `stage-2`.

```sh
cd ./build

# Using docker compose to build the images. 
# To see all the output, use --progress=plain
# To cleanly rebuild the images, use --no-cache

# Build the stage-1 image
# By default, the image is named pei-image:stage-1, you can change it in user_config.yml
docker-compose build stage-1 --progress=plain

# Build the stage-2 image
# By default, the image is named pei-image:stage-2
docker-compose build stage-2 --progress=plain
```

* Run the docker container:

```sh
# inside project directory, such as ./build

# Typically you will run the stage-2 container
# You can also up the stage-1 container as well.
docker compose up stage-2
```

* If you have setup SSH in `user_config.yml`, now you can SSH into the container:

```sh
# by default, it will create a user named `me` with password '123456'
# and map the port 2222 to the container's port 22

ssh me@127.0.0.1 -p 2222
```

* That's it, you are good to go.
* If you prefer to run the image using `docker run` instead of `docker compose`, you can convert the `docker-compose.yml` to commands using [Decomposerize](https://www.decomposerize.com/).
* If you have trouble connecting to docker.io when building the image, you can either set the global proxy for docker, or pull the base image manually and tag it with a local name. For detail, see [stack overflow](https://stackoverflow.com/questions/68520864/how-to-disable-loading-metadata-while-executing-docker-build).

```sh
# get the base image manually
docker pull ubuntu:24.04

# tag it with a local name, 
# in user_config.yml, use my-ubuntu:24.04 as the base image 
# to skip checking with docker.io
docker tag ubuntu:24.04 my-ubuntu:24.04
```

## Custom commands

* To run custom commands during build, edit the scripts in `<project_dir>/installation/stage-<1,2>/custom`. You can also run other scripts by adding them in `user_config.yml`.
* If you have *on-first-run* commands in `user_config.yml`, after the first run, you shall commit the container to a new image so that the changes are saved, or otherwise those commands will be executed again when the container is recreated.

## Stage-2 storage

The image built in stage-2 have the following directories for user:

- `/soft/app`: the directory to store the installed apps.
- `/soft/data`: the directory to store the data files.
- `/soft/workspace`: the directory to store the workspace files, like code.

These `/soft/xxx` are links to the corresponding directories in `/hard/image/xxx` (in-image storage) or `/hard/volume/xxx` (external storage), where content is actually stored, based on the following rules:

- If `/hard/volume/xxx` is found, then `/soft/xxx` is a link to `/hard/volume/xxx`.
- Otherwise, if `/hard/image/xxx` is found, then `/soft/xxx` is a link to `/hard/image/xxx`.

As such, you can switch between in-image storage and external storage by mounting into `/hard/volume/xxx`, and this behavious is already present in the generated `docker-compose.yml` file based on your `user_config.yml`. Note that only predefined directories (`app`, `data`, `workspace`) are linked, others will be ignored.

## Project directory layout

Inside your project directory, you will find the following files and directories:

    compose-template.yml    # the template for docker-compose.yml, do not modify this file
    stage-1.Dockerfile      # the Dockerfile for stage-1 image, do not modify this file
    stage-2.Dockerfile      # the Dockerfile for stage-2 image, do not modify this file
    user_config.yml         # the configuration file, edit this file to customize
    installation/           # this directory will be copied into the image under /pei-init
        stage-1/            # the scripts to run during stage-1 image building
            custom/         # the custom scripts to run during stage-1 image building, you need to explicitly list them in user_config.yml
            tmp/            # the temporary directory to store downloaded packages, like .deb, .whl, etc.
            system/         # the configuration files for system apps, like apt, pip, etc.
            ...
        stage-2/            # the scripts to run during stage-2 image building
            custom/         # the custom scripts to run during stage-2 image building, you need to explicitly list them in user_config.yml
            tmp/            # the temporary directory to store downloaded packages, like .deb, .whl, etc.
            system/         # the configuration files for system apps, like apt, pip, etc.
            ...

## User configuration file

Here are the options you can set in `user_config.yml`:

```yaml
# all paths are relative to /installation directory

stage_1:
  # input/output image settings
  image:
    base: ubuntu:24.04
    output: pei-image:stage-1

  # ssh settings
  ssh:
    enable: true
    port: 22  # port in container
    host_port: 2222  # port in host

    # ssh users, the key is user name, value is user info
    users:
      me:
        password: '123456'

        # public key file path, relative to the installation directory
        # e.g., 'stage-1/system/ssh/keys/mykey.rsa.pub'
        pubkey_file: null
      you:
        password: '654321'
        pubkey_file: null
      root: # you can configure root user here
        password: root
        pubkey_file: null

  # proxy settings
  # inside the container, the proxy will accessed as http://{address}:{port}
  # note that whether the proxy is used or not depends on the applications
  proxy:
    address: host.docker.internal # default value, this will map to the host machine
    port: 7890  # if address==host.docker.internal, this will be the proxy port on host machine
    enable_globally: false  # enable proxy for all shell commands during build and run?
    remove_after_build: false # remove global proxy after build?
    use_https: false # use https proxy?


  # apt settings
  apt:
    # replace the default apt source with a custom one, use empty string to disable this
    # repo_source: 'stage-1/system/apt/ubuntu-22.04-tsinghua-x64.list'
    # special values that refer to well known apt sources:
    # 'tuna' : 'http://mirrors.tuna.tsinghua.edu.cn/ubuntu/'
    # 'aliyun' : 'http://mirrors.aliyun.com/ubuntu/'
    # '163' : 'http://mirrors.163.com/ubuntu/'
    # 'ustc' : 'http://mirrors.ustc.edu.cn/ubuntu/'
    # 'cn' : 'http://cn.archive.ubuntu.com/ubuntu/
    repo_source: ''
    keep_repo_after_build: true # keep the apt source file after build?
    use_proxy: false  # use proxy for apt?
    keep_proxy_after_build: false # keep proxy settings after build?

  # additional environment variables
  # see https://docs.docker.com/compose/environment-variables/set-environment-variables/
  environment:
    - 'EXAMPLE_VAR_STAGE_1=example env var'

  # additional port mapping
  # see https://docs.docker.com/compose/networking/
  ports: []

  # device settings
  device:
    type: cpu # can be cpu or gpu

  # custom scripts
  custom:
    # scripts run during build
    on_build: 
      - 'stage-1/custom/install-dev-tools.sh' # just an example, you can safely remove this
      - 'stage-1/custom/my-build-1.sh'
      - 'stage-1/custom/my-build-2.sh'

    # scripts run on first run
    on_first_run:
      - 'stage-1/custom/my-on-first-run-1.sh'
      - 'stage-1/custom/my-on-first-run-2.sh'

    # scripts run on every run
    on_every_run:
      - 'stage-1/custom/my-on-every-run-1.sh'
      - 'stage-1/custom/my-on-every-run-2.sh'

    # scripts run on user login
    on_user_login:
      - 'stage-1/custom/my-on-user-login-1.sh'
      - 'stage-1/custom/my-on-user-login-2.sh'
    
stage_2:

  # input/output image settings
  image:
    base: null  # if not specified, use the output image of stage-1
    output: pei-image:stage-2

  # additional environment variables
  # see https://docs.docker.com/compose/environment-variables/set-environment-variables/
  environment:  # use list intead of dict
    - 'EXAMPLE_VAR_STAGE_2=example env var'

  # port mapping, will be appended to the stage-1 port mapping
  # see https://docs.docker.com/compose/networking/
  ports: []    

  # device settings, will override the stage-1 device settings
  device:
    type: cpu # can be cpu or gpu

  
  # proxy settings
  # inside the container, the proxy will accessed as http://{address}:{port}
  # note that whether the proxy is used or not depends on the applications
  proxy:
    address: null # this means to use the proxy settings of stage-1
    port: null
    enable_globally: null 
    remove_after_build: null 
    use_https: null

  # storage configurations
  storage:
    app:
      type: auto-volume # auto-volume, manual-volume, host, image
      host_path: null # host directory to be mounted, in effect when type=host
      volume_name: null # volume name, in effect when type=manual-volume
    data:
      type: auto-volume
      host_path: null
      volume_name: null
    workspace:
      type: auto-volume
      host_path: null
      volume_name: null

  # custom scripts in stage-2, run after stage-1 custom scripts
  custom:
    # scripts run during build
    on_build: 
      - 'stage-2/custom/install-gui-tools.sh' # just an example, you can safely remove this
      - 'stage-2/custom/my-build-1.sh'
      - 'stage-2/custom/my-build-2.sh'

    # scripts run on first start
    on_first_run:
      - 'stage-2/custom/my-on-first-run-1.sh'
      - 'stage-2/custom/my-on-first-run-2.sh'

    # scripts run on every start
    on_every_run:
      - 'stage-2/custom/my-on-every-run-1.sh'
      - 'stage-2/custom/my-on-every-run-2.sh'

    # scripts run on user login
    on_user_login:
      - 'stage-2/custom/my-on-user-login-1.sh'
      - 'stage-2/custom/my-on-user-login-2.sh'
```