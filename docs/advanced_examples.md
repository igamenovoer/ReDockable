# Advanced Examples

## Hardware-accelerated OpenGL

### Windows

The following example demonstrates how to build a Docker image with hardware-accelerated OpenGL support on Windows. The critical part is to: 

* install necessary packages (e.g., `libglvnd-dev`) in the Dockerfile, see [setup-opengl-win32.sh](https://github.com/igamenovoer/PeiDocker/blob/627abb919fca23a24e7bc95da0af9c6ac9c88166/pei_docker/project_files/installation/stage-2/system/opengl/setup-opengl-win32.sh)

* mount the necessary directories for WSLg to work properly, see [WSLg GPU selection](https://github.com/microsoft/wslg/wiki/GPU-selection-in-WSLg).


```yaml
# all paths are relative to /installation directory
# for windows, you need to add these to the final docker-compose.yml file
# see https://github.com/microsoft/wslg/wiki/GPU-selection-in-WSLg

# volumes:
#     - /tmp/.X11-unix:/tmp/.X11-unix
#     - /mnt/wslg:/mnt/wslg
#     - /usr/lib/wsl:/usr/lib/wsl
#     - /dev:/dev

stage_1:
  # input/output image settings
  image:
    base: nvidia/cuda:12.3.2-base-ubuntu22.04    
    output: pei-opengl:stage-1

  # ssh settings
  ssh:
    enable: true
    port: 22  # port in container
    host_port: 2222  # port in host

    # ssh users, the key is user name, value is user info
    users:
      me:
        password: '123456'

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
    repo_source: 'tuna'

  # device settings
  device:
    type: gpu # can be cpu or gpu
    
stage_2:

  # input/output image settings
  image:
    output: pei-opengl:stage-2

  # additional environment variables
  # see https://docs.docker.com/compose/environment-variables/set-environment-variables/
  environment:  # use list intead of dict
    NVIDIA_VISIBLE_DEVICES: all
    NVIDIA_DRIVER_CAPABILITIES: all

  # device settings, will override the stage-1 device settings
  device:
    type: gpu # can be cpu or gpu

  storage:
    app:
      type: auto-volume
    data:
      type: auto-volume
    workspace:
      type: auto-volume

  # custom scripts in stage-2, run after stage-1 custom scripts
  custom:
    # scripts run during build
    on_build: 
      - 'stage-2/system/opengl/setup-opengl-win32.sh' # install opengl
```

```yaml
# this is the docker-compose.yml file

version: '3'
services:
  stage-2:
    image: pei-opengl:stage-2
    stdin_open: true
    tty: true
    command: /bin/bash
    deploy:
      resources:
        reservations:
          devices:
          - driver: nvidia
            capabilities:
            - gpu
    extra_hosts:
    - host.docker.internal:host-gateway
    build:
      context: .
      dockerfile: stage-2.Dockerfile
      extra_hosts:
      - host.docker.internal:host-gateway
      args:
        BASE_IMAGE: pei-opengl:stage-1
        WITH_ESSENTIAL_APPS: true
        PEI_STAGE_HOST_DIR_2: ./installation/stage-2
        PEI_STAGE_DIR_2: /pei-from-host/stage-2
        PEI_PREFIX_APPS: app
        PEI_PREFIX_DATA: data
        PEI_PREFIX_WORKSPACE: workspace
        PEI_PREFIX_VOLUME: volume
        PEI_PREFIX_IMAGE: image
        PEI_PATH_HARD: /hard
        PEI_PATH_SOFT: /soft
        PEI_HTTP_PROXY_2: http://host.docker.internal:7890
        PEI_HTTPS_PROXY_2: http://host.docker.internal:7890
        ENABLE_GLOBAL_PROXY: false
        REMOVE_GLOBAL_PROXY_AFTER_BUILD: false
    ports:
    - '2222:22'
    environment:
      NVIDIA_VISIBLE_DEVICES: all
      NVIDIA_DRIVER_CAPABILITIES: all
    volumes:
    - app:/hard/volume/app
    - data:/hard/volume/data
    - workspace:/hard/volume/workspace
    - /tmp/.X11-unix:/tmp/.X11-unix # for wslg
    - /mnt/wslg:/mnt/wslg   # for wslg
    - /usr/lib/wsl:/usr/lib/wsl # for wslg
    - /dev:/dev # for wslg
  stage-1:
    image: pei-opengl:stage-1
    stdin_open: true
    tty: true
    command: /bin/bash
    deploy:
      resources:
        reservations:
          devices:
          - driver: nvidia
            capabilities:
            - gpu
    environment: {}
    extra_hosts:
    - host.docker.internal:host-gateway
    build:
      context: .
      dockerfile: stage-1.Dockerfile
      extra_hosts:
      - host.docker.internal:host-gateway
      args:
        BASE_IMAGE: nvidia/cuda:12.3.2-base-ubuntu22.04
        WITH_ESSENTIAL_APPS: true
        WITH_SSH: true
        SSH_USER_NAME: me
        SSH_USER_PASSWORD: '123456'
        SSH_PUBKEY_FILE: ''
        APT_SOURCE_FILE: tuna
        KEEP_APT_SOURCE_FILE: true
        APT_USE_PROXY: false
        APT_KEEP_PROXY: false
        PEI_HTTP_PROXY_1: http://host.docker.internal:7890
        PEI_HTTPS_PROXY_1: http://host.docker.internal:7890
        ENABLE_GLOBAL_PROXY: false
        REMOVE_GLOBAL_PROXY_AFTER_BUILD: false
        PEI_STAGE_HOST_DIR_1: ./installation/stage-1
        PEI_STAGE_DIR_1: /pei-from-host/stage-1
        ROOT_PASSWORD: ''
    ports:
    - '2222:22'
volumes:
  app: {}
  data: {}
  workspace: {}
```