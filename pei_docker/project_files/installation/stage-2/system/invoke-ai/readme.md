install invoke ai and you need to start it manually

to start it, set the following env variables:
- AI_DATA_DIR: invoke-ai data directory
- AI_INSTALL_DIR: invoke-ai installation directory, where .venv is located
- AI_USERS: comma separated user names
- AI_PORTS: comma separated ports for each user
- AI_DEVICES: comma separated device for each user, such as cuda:id or cpu