# Examples

## Basic Ubuntu image with SSH support

This is the most basic example of creating an image with SSH support. The image is based on `ubuntu:latest` and has three users: `me`, `you`, and `root`. The passwords for the users are `123456`, `654321`, and `root` respectively. The SSH server is running on port `22` and mapped to host port `2222`. 

To accelerate apt installation in China, the `apt` source is set to `aliyun`. For other options, see the full [config file](index.md) for documentation. If this option is omitted, the default source will be used.

```yaml
# user_config.yml under project directory

stage_1:
  image:
    base: ubuntu:latest
    output: pei-image:stage-1
  ssh:
    enable: true
    port: 22
    host_port: 2222
    users:
      me:
        password: '123456'
        pubkey_file: null
      you:
        password: '654321'
        pubkey_file: null
      root:
        password: root
        pubkey_file: null
  apt:
    # optional, use this to accelerate apt installation in China
    repo_source: aliyun 
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
## Using existing docker volume as external storage
## Moving external storage to image
## Miniconda with pytorch installed
## ROS2 development

