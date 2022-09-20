# ansible

## Install
`install-minimal.sh` will check dependencies for Ansible and start services.

    $ ./install-minimal.sh
    $ ansible localhost -i hosts-start --ask-pass -m ping

If the last command return `pong`, the next add passwordless for Ansible.

    $ ansible-playbook -i hosts-start -e user_name=ansible playbook/secure-shell.yml

## Configuration

#### Ssh_config
After the `install.sh`

    $ vim ~/.ssh/config
    Host <hostname>
      IdentityFile ~/.ssh/ansible_ed25519.key

#### Inventory

    $ cp hosts_example hosts

## Start

    $ ansible-playbook -i hosts site.yml
