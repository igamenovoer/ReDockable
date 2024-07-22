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

## Basic image with GPU support
## Using host directory as external storage

This example is based on [the basic ssh image](#basic-ssh), which demonstrates how to use host directories as external storage. The image is based on `pei-image:stage-1` and has three external storage directories: `app`, `data`, and `workspace` (note that the directory names are **NOT CUSTOMIZABLE**, they are **predefined**), where specified host directories are mounted. In the container, you can access these directories through `/soft/app`, `/soft/data`, and `/soft/workspace`, which are linked to  `/app`, `/data`, and `/workspace` under the `/hard/volume`.

```yaml
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
      type: host
      host_path: d:/code/PeiDocker/build/storage/app
    data:
      type: host
      host_path: d:/code/PeiDocker/build/storage/data
    workspace:
      type: host
      host_path: d:/code/PeiDocker/build/storage/workspace
```

## Using existing docker volume as external storage

### With docker compose

Using [docker volumes](https://docs.docker.com/storage/volumes/) is preferred if you run the image locally, because it is more efficient, and will not get lost when the container is removed. Docker volumes can be created automatically, or [manually](https://docs.docker.com/reference/cli/docker/volume/create/) with a given name that can be used to mount the volume to the container.

This example is based on [the basic ssh image](#basic-ssh), which demonstrates how to use existing docker volumes as external storage. The image is based on `pei-image:stage-1` and has three external storage directories: `app`, `data`, and `workspace` (note that the directory names are **NOT CUSTOMIZABLE**, they are **predefined**), where **docker volumes** are mounted. 

```yaml
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

You can check the volumes with `docker volume ls`, the output should contains:

```
DRIVER              VOLUME NAME
local               my_data
local               my_workspace
```

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

## Moving external storage to image
## Miniconda with pytorch installed
## ROS2 development

