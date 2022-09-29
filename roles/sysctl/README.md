Role Name
=========

Enforce security by using sysctl.

Requirements
------------

None.

Role Variables
--------------

You can disable some rules, all is enable by default (defaults/main.yml):

```yml
enforce_kernel_rules: false
enforce_network_rules: false
enforce_userspace_rules: false
```

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: szorfein.sysctl, enforce_kernel_rules: false }

License
-------

MIT
