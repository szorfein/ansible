secure_time_sync
=========

This role add the last version of the script [secure_time_sync](https://github.com/szorfein/secure-time-sync), disable all services related to the insecure NTP and activate time sync over Tor by using onion address.

[Time Sync](https://madaidans-insecurities.github.io/guides/linux-hardening.html#time-synchronisation)

Requirements
------------

None.

Role Variables
--------------

secure-time-sync use https by default, if `use_tor` is true, it use `.onion` address instead.

```yml
use_tor: true
```

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

    - hosts: laptops
      roles:
        - { role: szorfein.secure_time_sync, use_tor: true }

License
-------

MIT

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
