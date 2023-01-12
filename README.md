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

## adding to dotfiles

From the `.gitignore` file, you'll notice i ignore *everything*. This is intentional. In keeping with the above goals, i _only_ add the things i feel necessary for my specific environment.

To add to this dotfiles repo:

```sh
git add -f .xxxx
```