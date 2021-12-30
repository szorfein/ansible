#!/usr/bin/env sh

set -o errexit -o nounset

AUTH="sudo"
HARDEN=false

red="\033[1;31m"
green="\033[1;32m"
white="\033[0;38m"
end="\033[0m"

title() { 
  echo "${green}=======================${end}"
  echo ">> $1"
  echo "${green}-----------------------${end}"
}

msg_ok() { echo "${green}[${white}+${green}]${white} $1${end}"; }

die() { echo "${red}[${white}-${red}]${white} $1 ${end}"; exit 1; }

dep_for_void() {
  sudo xbps-install ansible openssh
  if [ "$?" -eq 0 ] ; then
    msg_ok "Dependencies installed."
  else
    die "Error install"
  fi
}

config_for_void() {
  [ -f /etc/ssh/ssh_config_backup ] \
    || "$AUTH" mv /etc/ssh/ssh_config /etc/ssh/ssh_config_backup

  [ -f /etc/ssh/sshd_config_backup ] \
    || "$AUTH" mv /etc/ssh/sshd_config /etc/ssh/sshd_config_backup

  "$AUTH" cp ./deps/ssh_config /etc/ssh/ssh_config
  "$AUTH" cp ./deps/sshd_config /etc/ssh/sshd_config

  "$AUTH" chown root:root /etc/ssh/ssh*config
  "$AUTH" chmod 644 /etc/ssh/ssh_config
  "$AUTH" chmod 600 /etc/ssh/sshd_config

  msg_ok "Config created."
}

new_group() {
  if ! grep -q ssh_user /etc/group ; then
    "$AUTH" groupadd ssh_user
    if [ "$?" -eq 0 ] ; then
      msg_ok "Group ssh_user created."
    else
      die "Can't create the group ssh_user."
    fi
  fi
}

add_to_group() {
  "$AUTH" usermod -a -G ssh_user "$USER"
  if [ "$?" -eq 0 ] ; then
    msg_ok "User $USER added."
  else
    die "Error Add_to_group"
  fi
}

create_server_keys() {
  if ! "$AUTH" ls /etc/ssh/ssh_host_rsa_key ; then
    "$AUTH" /usr/bin/ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" < /dev/null
    if [ "$?" -eq 0 ] ; then
      msg_ok "RSA 4096 key created."
    else
      die "No RSA key created..."
    fi
  fi

  if ! "$AUTH" ls /etc/ssh/ssh_host_ed25519_key ; then
    "$AUTH" /usr/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" < /dev/null
    if [ "$?" -eq 0 ] ; then
      msg_ok "ED25519 key created."
    else
      die "No ED25519 key created..."
    fi
  fi
}

create_client_keys() {
  [ -f "$HOME"/.ssh/ansible_rsa.key ] \
    || /usr/bin/ssh-keygen -t rsa -b 4096 -o -a 100 -f "$HOME"/.ssh/ansible_rsa.key

  [ -f "$HOME"/.ssh/ansible_ed25519.key ] \
    || /usr/bin/ssh-keygen -t ed25519 -o -a 100 -f "$HOME"/.ssh/ansible_ed25519.key
}

service_for_void() {
  [ -s /var/service/sshd ] || {
    "$AUTH" ln -s /etc/sv/sshd /var/service/sshd
    if [ "$?" -eq 0 ] ; then
      msg_ok "Service started."
    else
      die "Err service"
    fi
  }
}

quote() { echo " ${red}>${white} $1${end}"; }

hardening_void() {
  "$AUTH" cp ./deps/ssh_config_hardened /etc/ssh/ssh_config
  "$AUTH" cp ./deps/sshd_config_hardened /etc/ssh/sshd_config

  "$AUTH" chown root:root /etc/ssh/ssh*config
  "$AUTH" chmod 644 /etc/ssh/ssh_config
  "$AUTH" chmod 600 /etc/ssh/sshd_config

  "$AUTH" sv restart sshd

  msg_ok "Service sshd hardened."
  quote "If it doesn't work, you need to logout and back."

  exit 0
}

options() {
  case "$1" in
    --hardening) HARDEN=true; shift ;;
    -h | --help) echo "Use '$0 --hardening' after a successfull connection."; exit 0; ;;
    *) die "Invalid argument: $1" ;;
  esac
}

main() {
  if [ "$#" -gt 0 ] ; then
    options "$@"
  fi

  if [ -f /etc/os-release ] && grep -q void /etc/os-release ; then
    if "$HARDEN" ; then hardening_void ; fi
    title "Installing..."
    dep_for_void
    title "Configuring..."
    config_for_void
    title "Creating a new group ssh_user..."
    new_group
    title "Adding the current user $USER to ssh_user..."
    add_to_group
    title "Creating keys..."
    create_server_keys
    create_client_keys
    title "Service..."
    service_for_void
    quote "Copy your keys with e.g:"
    quote "ssh-copy-id localhost"
    quote "Connect with -> ssh -i ~/.ssh/ansible_ed25519.key localhost"
    msg_ok "Ended, gl."
  else
    die "Your system is not yet supported :("
  fi
  exit 0
}

main "$@"

