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
./.brew.sh
./.npm.sh
```

## machine-specific Homebrew packages

Keep packages that should exist on every Mac in `.brewfile`.

For machine-local experiments, create `~/.brewfile.local`. `.brewfile` loads it
when it exists, so the regular `.brew.sh` run installs those packages and
protects them from cleanup.

```sh
./.brew.sh
```

## adding to dotfiles

From the `.gitignore` file, you'll notice i ignore *everything*. This is intentional. In keeping with the above goals, i _only_ add the things i feel necessary for my specific environment.

To add to this dotfiles repo:

```sh
git add -f .xxxx
```
