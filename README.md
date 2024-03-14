# docker-template
Build docker image through proxy and install additional apps.

With this template, during build, you can:
- Specify proxy for apt, shell and others
- Change apt source
- Install a list of apps
- Setup commonly used tools like ssh

To do so, just create a docker compose file like the template, and set environment variables declared in main.Dockerfile.

## Example

To build image and start container
```Shell
# build it, use --progress=plain and see all output
docker compose build nv-cu118 --no-cache --progress=plain

# start it
docker compose up nv-cu118
```

Then, you can ssh into it from host
```Shell
# container:22 is mapped to host:62222, in docker-compose file
# default password is 123456
ssh me@127.0.0.1 -p 62222

# if ssh key file is added to the container, you can use it
ssh -i path_to_private_key me@127.0.0.1 -p 62222
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
| SSH_USER_NAME        | if ssh is installed, specify ssh user name                     | me                               |
| SSH_USER_PASSWORD    | if ssh is installed, specify ssh password                      | 123456                              |
| SSH_PUBKEY_FILE    | add existing pubkey to the container, for SSH_USER_NAME         | /initscripts/sshkey/mykey.rsa.pub   |
| APT_SOURCE_FILE      | apt repo file that will replace /etc/apt/sources.list          | /initscripts/sources-tsinghua.list  |
| APT_HTTP_PROXY       | http proxy to be used by apt                                   | http://host.docker.internal:7890    |
| APT_RETAIN_HTTP_PROXY | keep http proxy for apt in the image, so that future containers use this proxy | false |
| SHELL_HTTP_PROXY     | http proxy to be used by shell commands                        | http://host.docker.internal:7890    |
| OPTIONAL_HTTP_PROXY  | http proxy that will be used by other scripts when needed      | http://host.docker.internal:7890    |
