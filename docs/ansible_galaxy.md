## Init a role

    $ ansible-galaxy init test_role
    $ tree test_role/
    $ cat test_role/defaults/main.yml

## Search a role

    $ ansible-galaxy search django
    $ ansible-galaxy search --author ScorpionResponse

## Info

    $ ansible-galaxy info ScorpionResponse.django

## Install a role

    $ ansible-galaxy install SimpliField.users --roles-path roles/

## Remove a role

    $ ansible-galaxy remove SimpliField.users --roles-path roles/

## Create a requirements.yml
In this repos, we can include external roles like this:

    $ vim requirements.yml

```yml
- src: SimpliField.users
  name: supersecretrole
```

    $ ANSIBLE_ROLES_PATH="roles" ansible-galaxy install -r requirements.yml
