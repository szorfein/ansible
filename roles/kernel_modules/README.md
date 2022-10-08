kernel_modules
=========

Reducing range of the attack surface by disabling kernel modules on Linux.

Requirements
------------

None.

Role Variables
--------------

If you want to change the file destination:

```yml
blacklist_path: /etc/modprobe.d/30_security-misc.conf
```

If you need/want to keep bluetooth on your system (default true):

```yml
remove_bluetooth: false
```

Dependencies
------------

    ansible-galaxy collection install community.general

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: harden.kernel_modules, remove_bluetooth: true }

License
-------

MIT

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
