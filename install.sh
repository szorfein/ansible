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
  if ! "$CLIENT" ; then return ; fi

  msg_info "Checking ssh key"
  [ -f "$HOME"/.ssh/ansible.pub ] \
    || ssh-keygen -t ed25519 -o -a 100 -f "$HOME"/.ssh/ansible

  msg_ok
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
      -p | --password) PASSWD=true ; shift ;;
      -h | --help) show_options ;;
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

install_deps() {
  msg_info "Checking dependencies"
  printf "\n"
  if "$SERVER" ; then "$AUTH" $INSTALL $1 ; fi
  if "$CLIENT" ; then "$AUTH" $INSTALL $2 ; fi
}

server_setup() {
  if ! "$SERVER" ; then return ; fi

  configure_sudo
  if "$PASSWD" ; then passwd "$USER" ; fi
  show_access
}

main() {
  if_no_args "$@"
  options "$@"

  if [ -f /etc/os-release ] ; then
    if grep -q void /etc/os-release ; then
      "$AUTH" xbps-install -S
      INSTALL="xbps-install"

      install_deps "$AUTH openssh python3" \
                   "ansible sshpass"

      if "$SERVER" ; then service_for_void ; fi

    elif grep -iq "^name=\"arch linux\"" /etc/os-release ; then
      "$AUTH" pacman -Sy # update datababse
      INSTALL="pacman -S --needed"

      install_deps "$AUTH openssh" \
                   "ansible sshpass"

      if "$SERVER"; then systemd_service ; fi

    elif grep -iq "^name=\"ubuntu\"" /etc/os-release ; then
      "$AUTH" apt-get update
      INSTALL="apt-get install"

      install_deps "$AUTH openssh-server" \
                   "software-properties-common"

      if "$SERVER" ; then systemd_service ; fi

      if "$CLIENT" ; then
        "$AUTH" apt-add-repository ppa:ansible/ansible
        "$AUTH" $INSTALL ansible
      fi

    elif grep -iq "^name=\"debian gnu\/linux\"" /etc/os-release ; then
      "$AUTH" apt-get update
      INSTALL="apt-get install"

      install_deps "$AUTH openssh-server" \
                   "sshpass ansible"

      if "$SERVER" ; then systemd_service ; fi
    else
      die "Os-release, Your system is not yet supported :("
    fi
  else
    die "Your system is not yet supported :("
  fi

  server_setup
  create_client_keys

  exit
}

main "$@"
