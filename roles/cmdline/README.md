cmdline
=======

Increase security of the kernel command line options by checking {{ ansible.cmdline }} and configure Grub (for now) with lacked options.

- [kicksecure](https://github.com/Kicksecure/security-misc)
- [maidaidans](https://madaidans-insecurities.github.io/guides/linux-hardening.html#boot-kernel)
- [kspp](https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project/Recommended_Settings#kernel_command_line_options)

Requirements
------------

None.

Role Variables
--------------

If need to mount a `/boot` partition before (default false):

```yml
mount_boot: true
```

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: harden.cmdline, mount_boot: true }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
