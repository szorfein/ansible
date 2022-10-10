# ansible

## Install
`install.sh` will check dependencies for Ansible and start services.

On a server, it install python3 if need, openssh and start the daemon:

    $ ./install.sh --server --password

For you, it install ansible, sshpass:

    $ ./install.sh --client

Test the connection:

    $ ansible localhost -i hosts-start --ask-pass -m ping

Look [docs/setup](https://github.com/szorfein/ansible/tree/main/docs/setup.md) if need help to setup the thing.

#### Inventory

    $ cp hosts_example hosts

## Start

    $ ansible-playbook -i hosts site.yml
