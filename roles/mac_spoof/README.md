mac_spoof
=========

A role which configure network interfaces to use random MAC address with macchanger.

Requirements
------------

None.

Role Variables
--------------

The wifi_client to use when a wifi card is found, only `iwd` or `wpa_supplicant` for now, default none.

```yml
wifi_client: iwd or wpa_supplicant
```
Dependencies
------------

None.

Example Playbook
----------------

    - hosts: laptops
      roles:
         - { role: szorfein.mac_spoof, wifi_client: iwd }

License
-------

MIT
