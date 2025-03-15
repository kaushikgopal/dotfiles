# Used for executing user's commands at start, will be sourced when starting as a login shell.
# intentionally checking in this file (and ensuring it's empty)

# load order
# .zshenv > .zprofile > .zshrc
# .zprofile loaded (if login)


# set initial shell level
export INIT_SHELL_LEVEL=$SHLVL
# encoding
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Java/Android development
# export JAVA_HOME=$(/usr/libexec/java_home -v"17")
export JAVA_HOME=$HOME/Applications/Android\ Studio.app/Contents/jbr/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk

export GOKU_EDN_CONFIG_FILE=~/.karabiner.edn
export STARSHIP_CONFIG=~/.starship.toml
export BAT_CONFIG_PATH=~/.bat.conf

# ----------------------------------------------------------------------------------------------------------------------
# Path

# -U stands for unique and tells the shell that it should not add anything to $path if it's there already.
#   it keeps only the left-most occurrence, so if you added something at the end it will disappear and
#   if you added something at the beginning, the old one will disappear
typeset -U path
path=(
    ~/bin
    /opt/homebrew/bin
    /opt/homebrew/sbin
    /usr/local/bin
    /usr/bin
    /bin
    /usr/local/sbin
    /usr/sbin
    /sbin
    ~/.local/bin                  # pipx

    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/cmdline-tools/latest/bin"
    "$ANDROID_HOME/tools"
    "$ANDROID_HOME/tools/bin"
    "$ANDROID_HOME/emulator"

    $path
)
    # /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home/bin
    # $HOME/.local/bin
    # $HOME/.fig/bin
    # $HOME/.pyenv/shims
    # $GOPATH/bin
    # $GOROOT/bin

# export GOPATH="${HOME}/.go"
# export GOROOT="$(brew --prefix golang)/libexec"

# Added by Jetbrains Toolbox App
# export PATH="$PATH:/Users/kg/Library/Application Support/JetBrains/Toolbox/scripts"

