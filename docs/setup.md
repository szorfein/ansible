## Dependencies server side

Install dependencies on the server, it install python3, openssh and start the daemon.

    ./install.sh --server

## Connection on your server

1. Install dependencies on your system (ansible, sshpass).

```
./install.sh --client
```

2. Connect using ssh on your system.

```
ssh -p 22 username@127.0.0.1
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
```

This command add the host fingerprint to `~/.ssh/known_hosts` if you validate.

```
[127.0.0.1]:22 ssh-ed25519 AAAAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

If this file contain any older reference to `[127.0.0.1]:22` (in this case), remove them and restart.

## Configure ssh

Edit or create your `~/.ssh/config`, if you want to use connection with a password (recommanded for now):

```
Host 127.0.0.1:22
  IdentitiesOnly no
```

For an authentication with a pubkey:

```
Host 127.0.0.1:22
  IdentitiesOnly yes
  IdentityFile ~/.ssh/ansible.pub
```

If you enable the pubkey authentication, you need to copy your public key on the server, so copy the key before enable this.

## Ping-Pong with Ansible

When `~/.ssh/known_hosts` has the correct fingerprint.  

    ansible localhost -i hosts-start -u username --ssh-common-args "-p 22" --ask-pass -m ping

Return

```
127.0.0.1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/bin/python3.10"
    },
    "changed": false,
    "ping": "pong"
}
```

## Create a super user on the server (named ansible) with a pubkey authentication.

1. Create a keypair with ssh:

```
./install.sh --client
```

Or manually

    ssh-keygen -t ed25519 -o -a 100 -f "$HOME"/.ssh/ansible

2. Execute the `playbook/ansible-account.yml`.

```
ansible-playbook -i hosts-start -u username --ssh-common-args "-p 22" \
  -e user_name=ansible -e password="$(pass ansible/password)" -e authorized_key=~/.ssh/ansible.pub \
  -Kk playbooks/ansible-account.yml
```

Replace `-e password="AnyComplexPasswordPossible"` if you don't use `pass` or create one:

    pass generate --no-symbols ansible/password 80

3. Reconfigure `~/.ssh/config`.  

We can now enable the pubkey authentication.

```
Host 127.0.0.1:22
  IdentitiesOnly yes
  IdentityFile ~/.ssh/ansible.pub
```

4. Configure Ansible.  

Edit or create a config file the the default location `~/.ansible.cfg`.

```cfg
[defaults]
remote_user=ansible
```

## Ansible Inventory

Edit or create a `./hosts` file.

```
# A QuickEmu machine
debian ansible_host=127.0.0.1 ansible_ssh_port=22220

# Another QuickEmu vm that uses another port
voidlinux ansible_host=127.0.0.1 ansible_ssh_port=22222

[hardened]
atrueserver.com
debian

[privacy]
127.0.0.1 ansible_ssh_port=22 ansible_remote_user=ninja
debian
voidlinux
```

## Finish

Execute the final playbook.

    ansible-playbook -i hosts site.yml
