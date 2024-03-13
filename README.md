# docker-template
Build docker image through proxy and install additional apps.

With this template, during build, you can:
- Specify proxy for apt, shell and others
- Change apt source
- Install a list of apps
- Setup commonly used tools like ssh

To do so, just create a docker compose file like the template, and set environment variables declared in main.Dockerfile.

## Example

```Shell
docker compose build nv-cu118 --no-cache --progress=plain
```

## Arguments

NOTE: The folder **initscripts** will be copied to **/initscripts** in container, so to access those files, use **/initscripts/filename**.

Use these in docker-compose.yml, in build section:

```yaml
build:
    args:
        BASE_IMAGE: nvidia/cuda:12.3.2-base-ubuntu22.04
        WITH_SSH: true
        ...
```

| ARG                  | meaning                                                        | example                             |
|----------------------|----------------------------------------------------------------|-------------------------------------|
| BASE_IMAGE           | the base image used to build the image                         | nvidia/cuda:12.3.2-base-ubuntu22.04 |
| WITH_SSH             | install openssh-server                                         | true                                |
| WITH_ESSENTIAL_APPS  | install apps by running /initscripts/install-essentials.sh      | true                                |
| WITH_ADDITIONAL_APPS | install apps by running /initscripts/install-additional-apps.sh | true                                |
| SSH_USER_NAME        | if ssh is installed, specify ssh user name                     | myssh                               |
| SSH_USER_PASSWORD    | if ssh is installed, specify ssh password                      | 123456                              |
| APT_SOURCE_FILE      | apt repo file that will replace /etc/apt/sources.list          | /initscripts/sources-tsinghua.list  |
| APT_HTTP_PROXY       | http proxy to be used by apt                                   | http://host.docker.internal:7890    |
| SHELL_HTTP_PROXY     | http proxy to be used by shell commands                        | http://host.docker.internal:7890    |
| OPTIONAL_HTTP_PROXY  | http proxy that will be used by other scripts when needed      | http://host.docker.internal:7890    |
