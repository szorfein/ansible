secure_shell
=========

Enhance Security of SSH.

Helped with:
- Lynis
- Ssh-audit
- https://stribika.github.io/2015/01/04/secure-secure-shell.html

Requirements
------------

None.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

```yml
# Archlinux use 'sshd', Ubuntu and Debian use a service name 'ssh'
service_name: sshd

# On Debian 11, you can use:
sshd_config_file: /etc/ssh/sshd_config.d/ssh-audit_hardening.conf
ssh_config_file: /etc/ssh/ssh_config
```

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      become: true
      roles:
         - { role: szorfein.secure_shell, allowed_users: [ansible] }

License
-------

MIT
