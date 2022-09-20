#!/usr/bin/env sh

set -o errexit -o nounset

dep() {
  if ! hash "$2" 2>/dev/null ; then
    echo "Installing $1."
    sudo pacman -S "$1"
  fi
}

install_deps() {
  dep openssh ssh
  dep ansible ansible
  dep sshpass sshpass
}

start_ssh() {
  if ! pgrep -x sshd ; then
    echo "Starting sshd."
    sudo systemctl start sshd
  fi
}

main() {
  install_deps
  start_ssh
  echo "Ansible is ready for localhost..."
}

main "$@"
