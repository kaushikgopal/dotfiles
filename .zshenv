TZ="America/Los_Angeles"
VISUAL="code"
EDITOR=$VISUAL


GEM_HOME="$HOME/.gem"
GITHUB_USERNAME="kaushikgopal"
HOMEBREW_CACHE="/Library/Caches/Homebrew"
HOMEBREW_CASK_OPTS="--appdir=/Applications --fontdir=/Library/Fonts"
HOMEBREW_NO_AUTO_UPDATE=1
HOMEBREW_NO_INSTALL_UPGRADE=1

ANDROID_HOME=$HOME/Library/Android/sdk
export JAVA_HOME=$(/usr/libexec/java_home -v"17")

export FZF_DEFAULT_COMMAND='fd --type file --no-ignore-vcs --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"

export GOKU_EDN_CONFIG_FILE=~/.karabiner.edn
export STARSHIP_CONFIG=~/.starship.toml
export BAT_CONFIG_PATH=~/.bat.conf

# XDG_CONFIG_HOME="$HOME/.config"
# XDG_DATA_HOME="$HOME/.data"
# XDG_CACHE_HOME="$HOME/.cache"
