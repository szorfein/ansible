# ansible

Use different Ansible collections to manage my computers with several profles:

+ [hardened](https://github.com/szorfein/ansible-collection-hardening) build ~= 80 hardening index from [lynis](https://cisofy.com/lynis/). A work in progress...
+ [privacy](https://github.com/szorfein/ansible-collection-privacy) anonymize the computer.

Maybe futur collection:
+ [dots] Coupled with chezmoi.
+ [vpn]

## Setup

Look [docs/setup](https://github.com/szorfein/ansible/blob/develop/docs/setup.md) if need help to setup the thing.

## Dependencies

    ansile-galaxy collection install -r requirements.yml

## Inventory

    $ cp hosts_example hosts

## Start

    $ ansible-playbook -i hosts site.yml

### Reporting Issues

If you're experiencing a problem that you feel is a bug or have ideas for improving, i encourage you to open an issue and share your feedback.
