# Used for setting user's environment variables. This file will always be sourced.

# load order
# .zshenv > .zprofile > .zshrc


# you may be tempted to set the path here. Avoid it!
#   Prior to loading this file /etc/zprofile is read, which in a default macOS installation executes:
#       eval `/usr/libexec/path_helper -s`
#   This will screw with the ordering of any customizations to your path

TZ="America/Los_Angeles"
TERM='xterm-256color'
EDITOR='nvim'
VISUAL='nvim'


export FZF_DEFAULT_COMMAND='fd --type file --no-ignore-vcs --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"

GITHUB_USERNAME="kaushikgopal"

HOMEBREW_CACHE="/Library/Caches/Homebrew"
HOMEBREW_CASK_OPTS="--appdir=/Applications --fontdir=/Library/Fonts"
HOMEBREW_NO_AUTO_UPDATE=1
HOMEBREW_NO_INSTALL_UPGRADE=1

# Ruby development
GEM_HOME="$HOME/.gem"

# XDG_CONFIG_HOME="$HOME/.config"
# XDG_DATA_HOME="$HOME/.data"
# XDG_CACHE_HOME="$HOME/.cache"

HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history


####################
# Tips
####################

# export vs regular assignment
# https://stackoverflow.com/a/70585583/159825
# export → makes the variable an "environment" variable
#        - i.e. processes started by this shell will also inherit these variables
#        - otherwise it's only available to this process
