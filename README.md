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