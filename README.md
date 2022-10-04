# env
Estabaa con el git-tree, e iba a probar el stdin.sh y poner las funciones de bash y me fui a poner el bash para el PATH.. y antes con las man pages y los helps por eso me faltaban commandos de git y los traje
## [Install](./install)
Installs to /etc/profile to source `env.sh` which is only source in interactive shells and when sudo is installed.

````shell
git clone https://github.com/j5pu/env.git && ./env/install && . /etc/profile
````


## [Update](./bin/alias-pull)
To get the latest aliases.
````shell
alias-pull
````

## alias commands
Commands to manage [change directory aliases](./dirs) and [sudo aliases](./sudo).

[library aliases](./lib) are added manually but can be removed with `alias-del`.


# [Update aliases/pull](./bin/alias-pull)
To get the latest aliases.
````shell
alias-pull
````

## [alias-add](./bin/alias-add)
Adds and push:
* [change directory aliases](./dirs) if first arg is a directory, is added per hostname where the command is executed.
* [sudo aliases](./sudo) if first arg is not a directory, 
can only be added to one library, either: common, Darwin, debian, Linux, etc (Default: common)

### Examples: alias-add [sudo aliases](./sudo)
````shell
alias-add ls # adds to all OSs (Default)
alias-add ls Darwin  # adds to Darwin only
alias-add ls Linux  # adds to Darwin only
alias-add apt debian  # adds to debian
`````

## [alias-clean](./bin/alias-clean)
Clean [change directory aliases](./dirs) which do not exist and push.

## [alias-del](./bin/alias-del)
Remove alias and push.
* [change directory aliases](./dirs) removes alias for hostname where command is run.
* [sudo aliases](./sudo) removes alias from any OS in case exists in more than one.

### Examples: alias-rm [sudo aliases](./sudo)
````shell
sudo-rm ls
`````
