# dotfiles

* Kaushik's minimal dotfiles.
* Goals:
  * keep it simple
  * keep it minimal
  * make it easily transferrable between machines
  * keep it resilient to frequent OS f*ckery


# Instructions

## one-time setup

On a new Mac, you want to run this command:

```sh
# get the token from github
/bin/bash -c -e "$(curl -fsSL https://raw.githubusercontent.com/kaushikgopal/dotfiles/master/.setup.sh?token=xxx)"
chmod +x .setup.sh
./.setup.sh
```

## updates

```sh
./.update.sh
```