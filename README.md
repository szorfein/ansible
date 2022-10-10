# ansible

A collection of roles for manage my systems, make differents profile:

+ [hardened] build ~= 80 hardening index from [lynis](https://cisofy.com/lynis/). A work in progress...
+ [privacy] anonymize the computer.

Maybe futur profile:
+ [dots] Coupled with chezmoi.
+ [vpn]

## Setup

Look [docs/setup](https://github.com/szorfein/ansible/tree/main/docs/setup.md) if need help to setup the thing.

## Inventory

    $ cp hosts_example hosts

## Start

    $ ansible-playbook -i hosts site.yml
