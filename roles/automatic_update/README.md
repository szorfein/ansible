automatic_updates
----------------

Configure your system to automatically download and install updates.

+ Arch: Install pacman-contrib and do the job with a cron task.
+ Debian: Use and configure [UnattendedUpgrades](https://wiki.debian.org/UnattendedUpgrades).

Role Variables
--------------

- `mount_boot`: [bool] default false

If you need to mount the /boot partition before updates, set to true, the entrie of /boot should be in the fstab.

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: automatic_updates, mount_boot: true }

