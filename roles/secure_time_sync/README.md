secure_time_sync
=========

This role add the last version of the script [secure_time_sync](https://github.com/szorfein/secure-time-sync), disable all services related to the insecure NTP and activate time sync over Tor by using onion address.

[Time Sync](https://madaidans-insecurities.github.io/guides/linux-hardening.html#time-synchronisation)

Requirements
------------

None.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

    - hosts: laptops
      roles:
         - szorfein.secure_time_sync

License
-------

MIT

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
