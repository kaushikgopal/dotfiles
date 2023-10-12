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
# dotfiles is a public repo (no auth required)
curl -LJO https://raw.githubusercontent.com/kaushikgopal/dotfiles/master/.setup.sh
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
