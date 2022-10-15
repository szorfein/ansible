# ansible

A collection of Ansible roles to manage my computers with several profles:

+ [hardened] build ~= 80 hardening index from [lynis](https://cisofy.com/lynis/). A work in progress...
+ [privacy] anonymize the computer.

Maybe futur profile:
+ [dots] Coupled with chezmoi.
+ [vpn]

## Setup

Look [docs/setup](https://github.com/szorfein/ansible/blob/develop/docs/setup.md) if need help to setup the thing.

## Inventory

    $ cp hosts_example hosts

## Start

    $ ansible-playbook -i hosts site.yml

### Reporting Issues

If you're experiencing a problem that you feel is a bug or have ideas for improving, i encourage you to open an issue and share your feedback.
