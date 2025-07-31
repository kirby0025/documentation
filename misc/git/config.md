### Git config path specific

``` ~/.gitconfig
[includeIf "gitdir:~/git/"]
    path = ~/git/.gitconfig-work
[includeIf "gitdir:~/perso/"]
    path = ~/perso/.gitconfig-perso
[includeIf "gitdir:~/github/"]
    path = ~/github/.gitconfig-github
[core]
	editor = vim
[user]
	signingkey = /home/seb/.ssh/id_ed25519.pub
[gpg]
	format = ssh
```
``` ~/.gitconfig-github
[user]
    email = ex@example.com
    mail = ex@example.com
    name = Test
    username = Test
```
