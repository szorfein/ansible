kernel_modules
=========

Reducing range of attack surface by disabling kernel modules and old network protocol on Linux.

Requirements
------------

None.

Role Variables
--------------

If you want to change the file destination:

```yml
blacklist_path: /etc/modprobe.d/30_security-misc.conf
```

If you need/want to keep bluetooth on your system (default false):

```yml
remove_bluetooth: true
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
