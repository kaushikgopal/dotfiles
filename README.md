# dotfiles

* Kaushik's minimal dotfiles.
* Goals:
  * keep it simple
  * keep it minimal
  * make it easily transferrable between machines
  * keep it resilient to frequent OS f*ckery


# Instructions

## one-time setup

On a new Mac, clone the repos first:

```sh
mkdir -p ~/dev/per
cd ~/dev/per

git clone https://github.com/kaushikgopal/dotfiles.git
git clone <aikado-repo-url> aikado

cd dotfiles
./.setup.sh
```

`.setup.sh` expects to run from inside this repo. It symlinks the tracked
dotfiles into `$HOME`, installs the shared Brewfile/npm dependencies in
bootstrap mode, sets up fish, and wires the agent config from `~/dev/per/aikado`.

If `aikado` lives somewhere else:

```sh
AIKADO_DIR=/path/to/aikado ./.setup.sh
```

## updates

Use `.update.sh` for regular Homebrew/npm maintenance after the machine is set up:

```sh
~/.update.sh
```

This runs the full maintenance path: Homebrew cleanup, Brewfile install, npm
global CLI install, cask upgrades, `brew update`, and `brew upgrade`.

If you only changed npm global packages and do not want to run Homebrew
maintenance:

```sh
~/.npm.sh
```

That installs or updates the CLIs listed in `.npm-global-packages` and
`~/.npm-global-packages.local`. `.brew.sh` and `.npm.sh` are lower-level helpers;
the usual entry points are `.setup.sh` and `.update.sh`.

## machine-specific Homebrew packages

Keep packages that should exist on every Mac in `.brewfile`.

For machine-local packages or experiments, manually create `~/.brewfile.local`
on that machine. It is intentionally untracked.

`.brewfile` loads `~/.brewfile.local` when it exists, so `.update.sh` installs
those packages and protects them from cleanup.

```sh
vim ~/.brewfile.local
~/.update.sh
```

`./.setup.sh` also installs local Brewfile entries when `~/.brewfile.local`
exists, but it skips cleanup/update/upgrade during bootstrap.

## machine-specific npm packages

Keep npm global CLIs that should exist on every Mac in `.npm-global-packages`.

For machine-local npm CLIs or experiments, manually create
`~/.npm-global-packages.local` on that machine. It is intentionally untracked.

The npm helper installs packages from both files when the local file exists.
`.update.sh` runs that helper.

```sh
vim ~/.npm-global-packages.local
~/.update.sh
```

## adding to dotfiles

From the `.gitignore` file, you'll notice i ignore *everything*. This is intentional. In keeping with the above goals, i _only_ add the things i feel necessary for my specific environment.

To add to this dotfiles repo:

```sh
git add -f .xxxx
```
