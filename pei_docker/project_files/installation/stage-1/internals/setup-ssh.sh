#!/bin/bash

# if WITH_SSH is false or not set, exit
if [ "$WITH_SSH" != "true" ]; then
  exit 0
fi

# if openssh server is not installed, skip it
if [ ! -f /etc/ssh/sshd_config ]; then
  echo "openssh-server is not installed, skipping ssh setup"
  exit 0
fi

# if SSH_USER_NAME is not set, exit
if [ -z "$SSH_USER_NAME" ]; then
  echo "SSH_USER_NAME is not set, exiting"
  exit 0
fi

# setup
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# permit root login
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# printf "\nPermitRootLogin yes\n" >> /etc/ssh/sshd_config

# permit password authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# allow x11 forwarding, trust x11 forwarding
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

# create a user group named users
groupadd ssh_users

# SSH_USER_NAME contains a list of users separated by comma
# SSH_USER_PASSWORD contains a list of passwords separated by comma
# SSH_PUBKEY_FILE contains a list of public keys separated by comma
# for each user, configure it
IFS=',' read -ra users <<< "$SSH_USER_NAME"
IFS=',' read -ra passwords <<< "$SSH_USER_PASSWORD"
IFS=',' read -ra pubkey_files <<< "$SSH_PUBKEY_FILE"
for i in "${!users[@]}"; do
  user=${users[$i]}
  password=${passwords[$i]}
  pubkey_file=${pubkey_files[$i]}
  if [ -z "$user" ]; then
    continue
  fi
  echo "Configuring user $user"
  adduser --gecos "" --disabled-password $user
  usermod -aG sudo $user
  usermod -aG ssh_users $user
  echo "$user:$password" | chpasswd

  # generate ssh key for user
  mkdir -p /home/$user/.ssh
  ssh-keygen -t rsa -C "$user" -f /home/$user/.ssh/id_rsa -N ""
  chown -R $user:$user /home/$user/.ssh
  
  # print the private key
  echo "generated ssh private key for $user:"
  cat /home/$user/.ssh/id_rsa

  # add public key to authorized_keys
  cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys
  if [ -n "$pubkey_file" ]; then
    echo "Adding public key from $pubkey_file to authorized_keys"
    cat $pubkey_file >> /home/$user/.ssh/authorized_keys
  fi
done

# generate ssh key for host
ssh-keygen -A
