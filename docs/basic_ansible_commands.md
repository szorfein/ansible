## Testing SSH with a password

    $ ansible all -i localhost, -u my_vyos_user -k -m ping

+ `-u my_vyos_user` tell the user for the SSH connection
+ `-k` will ask for a SSH password, require the package `sshpass`

## Use the Ping module

    $ ansible -i hosts -m ping

## Use the Shell module

    $ ansible -i hosts -m shell -a 'echo "Hello World !"'
    $ ansible -i hosts -m shell -a 'ls -l /tmp'

## Use the Setup module

Display all informations about all the systems:

    $ ansible -i hosts -m setup
    $ ansible -i hosts -m setup -a "filter='*_distribution_*'"

