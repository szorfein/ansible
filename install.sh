#!/usr/bin/env sh

set -o errexit -o nounset

AUTH="sudo"
SERVER=false
CLIENT=false
INSTALL=false
PASSWD=false

red="\033[1;31m"
green="\033[1;32m"
blue="\033[1;34m"
white="\033[0;38m"
end="\033[0m"

title() { 
  echo "${green}=======================${end}"
  echo ">> $1"
  echo "${green}-----------------------${end}"
}

msg_ok() { printf "\t${green}[${white} ok ${green}]${white}${end}"\\n; }

die() { echo "${red}[${white}-${red}]${white} $1 ${end}"; exit 1; }

create_client_keys() {
  [ -f "$HOME"/.ssh/ansible.pub ] \
    || ssh-keygen -t ed25519 -o -a 100 -f "$HOME"/.ssh/ansible
}

service_for_void() {
  if ! [ -L /var/service/sshd ] ; then
    "$AUTH" ln -s /etc/sv/sshd /var/service/sshd
    if [ "$?" -eq 0 ] ; then
      msg_ok
    else
      die "Err start service"
    fi
  else
    "$AUTH" sv restart sshd
    msg_ok
  fi
}

ok() { printf "\t[Ok]\n"; }

systemd_service() {
  msg_info "Checking service sshd"
  if ! pgrep -x sshd >/dev/null ; then
    echo "Starting sshd."
    "$AUTH" systemctl start sshd
  fi
  msg_ok
}

quote() { echo " ${red}>${white} $1${end}"; }

show_options() {
  printf "\\n$0 [Options]\\n"
  echo "---------------------"
  echo "Options:"
  echo "  -s|--server, Install server side, start ssh."
  echo "  -c|--client, Install on your side (Ansible, ssh, etc)."
  echo "  -p|--password, Create password, if need for SSH access."
  exit 0
}

options() {
  while [ "$#" -gt 0 ] ; do
    case "$1" in
      -s | --server) SERVER=true ; shift ;;
      -c | --client) CLIENT=true ; shift ;;
      -h | --help) show_options ;;
      -p | --password) PASSWD=true ; shift ;;
      *) die "Invalid argument: $1" ;;
    esac
  done
}

configure_sudo() {
  echo "Configuring sudo for $USER..."
  echo "$USER ALL=(ALL) ALL" > /tmp/"$USER"
  "$AUTH" chown root:root /tmp/"$USER"
  "$AUTH" mv /tmp/"$USER" /etc/sudoers.d/
  "$AUTH" chmod 600 /etc/sudoers.d/"$USER"
}

void_server() {
  configure_sudo
  title "Service..."
  service_for_void
  msg_ok
}

void_client() {
  create_client_keys
  quote "Copy your keys with e.g:"
  quote "ssh-copy-id -i ~/.ssh/ansible.pub $USER@localhost"
  quote "Connect with -> ssh -i ~/.ssh/ansible.key $USER@localhost"
}

dep() {
  if ! hash "$2" 2>/dev/null ; then
    echo "Installing $1."
    "$AUTH" "$INSTALL" "$1"
  fi
}

if_no_args() {
  if [ "$#" -eq 0 ] ; then
    printf "\\n%s\\n\\n" "$0: Argument required"
    printf "%s\\n" "Try '$0 --help' for more information."
    exit 1
  fi
}

show_access() {
  msg_info "Access user $USER on"
  printf "\n"
  echo "$(ip -4 -o a | cut -d ' ' -f 2,7 | cut -d '/' -f 1)"
}

msg_info() { printf "${blue}>>${white} $1...${end}" ; }

main() {
  if_no_args "$@"
  options "$@"

  if [ -f /etc/os-release ] ; then
    if grep -q void /etc/os-release ; then
      INSTALL="xbps-install -S"

      title "Installing..."
      dep "$AUTH" "$AUTH"
      dep openssh ssh
      if "$CLIENT" ; then
        dep ansible ansible
        dep sshpass sshpass
      fi

      title "Configuring..."
      if "$SERVER" ; then
        void_server
        show_access
      fi

      if "$CLIENT" ; then void_client ; fi
      msg_ok

    elif grep -iq "^name=\"arch linux\"" /etc/os-release ; then
      "$AUTH" pacman -Sy # update datababse
      INSTALL="pacman -S --needed"

      msg_info "Checking dependencies"
      printf "\n"
      "$AUTH" $INSTALL openssh "$AUTH"

      if "$SERVER"; then
        systemd_service
        configure_sudo
        show_access
        if "$PASSWD" ; then passwd "$USER" ; fi
      fi

      if "$CLIENT" ; then
        "$AUTH" "$INSTALL" ansible sshpass
        create_client_keys
      fi
    
    elif grep -iq "^name=\"ubuntu\"" /etc/os-release ; then
      "$AUTH" apt-get update
      INSTALL="apt-get install"

      "$AUTH" $INSTALL "$AUTH"

      if "$SERVER" ; then
        "$AUTH" $INSTALL openssh-server
        systemd_service
        configure_sudo
        show_access
        if "$PASSWD" ; then passwd "$USER" ; fi
      fi

      if "$CLIENT" ; then
        "$AUTH" $INSTALL software-properties-common
        "$AUTH" apt-add-repository ppa:ansible/ansible
        "$AUTH" $INSTALL ansible
        create_client_keys
      fi
    else
      die "Os-release, Your system is not yet supported :("
    fi
  else
    die "Your system is not yet supported :("
  fi

  exit 0
}

main "$@"
