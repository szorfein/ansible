#!/usr/bin/env sh

set -o errexit -o nounset

AUTH="sudo"
NEWUSER="veil"
HARDEN=false
SERVER=false
CLIENT=false
INSTALL=false

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


installing() {
  "$AUTH" "$INSTALL" $@
  if [ "$?" -eq 0 ] ; then
    msg_ok "Dependencies installed."
  else
    die "Error install"
  fi
}

dep_for_void() {
  INSTALL="xbps-install"
  if "$SERVER" ; then installing "openssh" ; fi
  if "$CLIENT" ; then installing "ansible openssh" ; fi
}

configuration() {
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
  if ! grep -q ssh-user /etc/group ; then
    "$AUTH" groupadd ssh-user
    if [ "$?" -eq 0 ] ; then
      msg_ok "Group ssh-user created."
    else
      die "Can't create the group ssh-user."
    fi
  fi
}

add_to_group() {
  "$AUTH" usermod -a -G ssh-user "$NEWUSER"
  if [ "$?" -eq 0 ] ; then
    msg_ok "User $NEWUSER added, add a strong password"
    "$AUTH" passwd "$NEWUSER"
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
  [ -f /home/"$1"/.ssh/ansible_rsa.key ] \
    || "$AUTH" -u "$1" /usr/bin/ssh-keygen -t rsa -b 4096 -o -a 100 -f /home/"$1"/.ssh/ansible_rsa.key

  [ -f /home/"$1"/.ssh/ansible_ed25519.key ] \
    || "$AUTH" -u "$1" /usr/bin/ssh-keygen -t ed25519 -o -a 100 -f /home/"$1"/.ssh/ansible_ed25519.key
}

service_for_void() {
  if ! [ -L /var/service/sshd ] ; then
    "$AUTH" ln -s /etc/sv/sshd /var/service/sshd
    if [ "$?" -eq 0 ] ; then
      msg_ok "Service started."
    else
      die "Err start service"
    fi
  else
    "$AUTH" sv restart sshd
    msg_ok "Service restarted."
  fi
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

  exit 0
}

show_options() {
  echo "$0 - Install dependencies for start with Ansible."
  echo "---------------------"
  echo "Options:"
  echo " -s|--server, install server side."
  echo " -c|--client, install client side."
  echo " --hardening, use it on the server after a successfully connection."
  exit 0
}

options() {
  case "$1" in
    --hardening) HARDEN=true; shift ;;
    -s|--server) SERVER=true; shift ;;
    -c|--client) CLIENT=true; shift ;;
    -h | --help) show_options ;;
    *) die "Invalid argument: $1" ;;
  esac
}

new_user() {
  if ! grep -q "$NEWUSER" /etc/passwd ; then
    "$AUTH" useradd -m "$NEWUSER"
    if [ "$?" -eq 0 ] ; then
      msg_ok "User $NEWUSER created."
    else
      die "Err service"
    fi
  fi
}

new_user_sudo() {
  "$AUTH" cp ./deps/sudo /etc/sudoers.d/"$NEWUSER"
  "$AUTH" chmod 0400 /etc/sudoers.d/"$NEWUSER"
}

void_server() {
  title "Creating a new user $NEWUSER..."
  new_user
  title "Creating a new group ssh-user..."
  new_group
  title "Adding $NEWUSER to group ssh-user..."
  add_to_group
  title "Adding sudo permission..."
  new_user_sudo
  title "Creating keys for the server..."
  create_server_keys
  title "Creating keys for $NEWUSER..."
  create_client_keys "$NEWUSER"
  title "Service..."
  service_for_void
  msg_ok "Server configured, gl."
}

void_client() {
  create_client_keys "$USER"
  service_for_void
  quote "Copy your keys with e.g:"
  quote "ssh-copy-id -i ~/.ssh/ansible_ed25519.key.pub $NEWUSER@localhost"
  quote "Connect with -> ssh -i ~/.ssh/ansible_ed25519.key $NEWUSER@localhost"
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
    configuration
    if "$SERVER" ; then void_server ; fi
    if "$CLIENT" ; then void_client ; fi
    msg_ok "Ended, gl."
  else
    die "Your system is not yet supported :("
  fi
  exit 0
}

main "$@"

