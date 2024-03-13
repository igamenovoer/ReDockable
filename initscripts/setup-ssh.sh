#!/bin/sh

# if WITH_SSH is false or not set, exit
if [ "$WITH_SSH" != "true" ]; then
  exit 0
fi

# install ssh first
# apt update
apt-get install openssh-server -y

# setup
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
printf "\nPermitRootLogin yes\n" >> /etc/ssh/sshd_config

# if SSH_USER_NAME is set, use it, otherwise use myssh
if [ -n "$SSH_USER_NAME" ]; then
  adduser --gecos "" --disabled-password $SSH_USER_NAME
  usermod -aG sudo $SSH_USER_NAME
else
  adduser --gecos "" --disabled-password myssh
  usermod -aG sudo myssh
fi

# if SSH_PASSWORD is set, use it, otherwise use 123456
if [ -n "$SSH_PASSWORD" ]; then
  echo "myssh:$SSH_PASSWORD" | chpasswd
else
  echo "myssh:123456" | chpasswd
fi

echo "ssh user: $SSH_USER_NAME"
echo "ssh password: $SSH_PASSWORD"
