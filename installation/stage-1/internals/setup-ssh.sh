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

# create a user group named users
groupadd ssh_users

adduser --gecos "" --disabled-password $SSH_USER_NAME
usermod -aG sudo $SSH_USER_NAME
usermod -aG ssh_users $SSH_USER_NAME
echo "$SSH_USER_NAME:$SSH_USER_PASSWORD" | chpasswd

# generate ssh key for user
mkdir -p /home/$SSH_USER_NAME/.ssh
ssh-keygen -t rsa -C "$SSH_USER_NAME" -f /home/$SSH_USER_NAME/.ssh/id_rsa -N ""
chown -R $SSH_USER_NAME:$SSH_USER_NAME /home/$SSH_USER_NAME/.ssh

# add public key to authorized_keys
cat /home/$SSH_USER_NAME/.ssh/id_rsa.pub >> /home/$SSH_USER_NAME/.ssh/authorized_keys

# if pubkey is given in SSH_PUBKEY_FILE, also add it to authorized_keys
if [ -n "$SSH_PUBKEY_FILE" ]; then
  echo "Adding public key from $SSH_PUBKEY_FILE to authorized_keys"
  cat $SSH_PUBKEY_FILE >> /home/$SSH_USER_NAME/.ssh/authorized_keys
fi

# generate ssh key for host
ssh-keygen -A

echo "ssh user: $SSH_USER_NAME"
echo "ssh password: $SSH_USER_PASSWORD"

# print its private key
echo "generated ssh private key:"
cat /home/$SSH_USER_NAME/.ssh/id_rsa

# print its public key
echo "generated ssh public key:"
cat /home/$SSH_USER_NAME/.ssh/id_rsa.pub
