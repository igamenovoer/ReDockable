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

# permit root login
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# printf "\nPermitRootLogin yes\n" >> /etc/ssh/sshd_config

# permit password authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

adduser --gecos "" --disabled-password $SSH_USER_NAME
usermod -aG sudo $SSH_USER_NAME
echo "$SSH_USER_NAME:$SSH_USER_PASSWORD" | chpasswd

echo "ssh user: $SSH_USER_NAME"
echo "ssh password: $SSH_USER_PASSWORD"
