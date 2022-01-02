# ansible

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
