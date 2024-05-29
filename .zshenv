# Used for setting user's environment variables. This file will always be sourced.

# you may be tempted to set the path here. Avoid it!
#   Prior to loading this file /etc/zprofile is read, which in a default macOS installation executes:
#       eval `/usr/libexec/path_helper -s`
#   This will screw with the ordering of any customizations to your path

TZ="America/Los_Angeles"
VISUAL="idea"
EDITOR=$VISUAL

GEM_HOME="$HOME/.gem"
GITHUB_USERNAME="kaushikgopal"
HOMEBREW_CACHE="/Library/Caches/Homebrew"
HOMEBREW_CASK_OPTS="--appdir=/Applications --fontdir=/Library/Fonts"
HOMEBREW_NO_AUTO_UPDATE=1
HOMEBREW_NO_INSTALL_UPGRADE=1

# export JAVA_HOME=$(/usr/libexec/java_home -v"17")
export JAVA_HOME=$HOME/Applications/Android\ Studio.app/Contents/jbr/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk

export FZF_DEFAULT_COMMAND='fd --type file --no-ignore-vcs --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"

export GOKU_EDN_CONFIG_FILE=~/.karabiner.edn
export STARSHIP_CONFIG=~/.starship.toml
export BAT_CONFIG_PATH=~/.bat.conf

# XDG_CONFIG_HOME="$HOME/.config"
# XDG_DATA_HOME="$HOME/.data"
# XDG_CACHE_HOME="$HOME/.cache"


####################
# Tips
####################

# export vs regular assignment
# https://stackoverflow.com/a/70585583/159825
# export → makes the variable an "environment" variable
#        - i.e. processes started by this shell will also inherit these variables
#        - otherwise it's only available to this process
