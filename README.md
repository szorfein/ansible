# ansible

## Install
`install.sh` will check dependencies for Ansible and start services.

On a server:

    $ ./install.sh --server --password

For you:

    $ ./install.sh --client

Test the connection:

    $ ansible localhost -i hosts-start --ask-pass -m ping

If the last command return `pong`, the next add password-less for Ansible.

    $ ansible-playbook -i hosts-start -e user_name=ansible -e password="$(pass ansible/password)" -e authorized_key=~/.ssh/ansible.pub -Kk playbooks/ansible-account.yml

If you use `pass`, you can generate secrets like this:

    $ pass generate --no-symbols ansible/password 80

### Configure ssh_config
After the `install.sh`

    $ vim ~/.ssh/config
    Host <hostname>
      IdentityFile ~/.ssh/ansible.pub

All Ansible operations after it require `-b, --become` and `--user ansible`.

#### Inventory

    $ cp hosts_example hosts

## Start

    $ ansible-playbook -i hosts site.yml
