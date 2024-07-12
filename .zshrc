# zmodload zsh/zprof          # start profiling


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
#     # /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home/bin
#     # $HOME/.local/bin
#     # $HOME/.fig/bin
#     # $HOME/.pyenv/shims
# Added by Jetbrains Toolbox App
# export PATH="$PATH:/Users/kg/Library/Application Support/JetBrains/Toolbox/scripts"




# ----------------------------------------------------------------------------------------------------------------------
# Enable Powerlevel10k instant prompt.
#   Should stay close to the top of ~/.zshrc.

# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi



# ----------------------------------------------------------------------------------------------------------------------
# Zsh settings

HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history


. $HOME/.functions.zsh                  # load functions first
dot_if_exists "$HOME/.aliases.zsh"
dot_if_exists "$HOME/.secrets.zsh"      # company related configs

source_if_exists "$HOME/.plugins.zsh/magic-enter.plugin.zsh"
source_if_exists "$HOME/.plugins.zsh/gitfast/gitfast.plugin.zsh"
#source_if_exists  "$HOME/.plugins.zsh/almostontop/almostontop.plugin.zsh"



# ----------------------------------------------------------------------------------------------------------------------
# Zsh autocomplete settings

# make zsh tab completion fix capitalization errors for directories and files
# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'
# autcomplete customizations
autoload -Uz compinit
compinit


# my aliases
compdef g=git
source $(brew --prefix)/share/zsh/site-functions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # has to be at the very end




# ----------------------------------------------------------------------------------------------------------------------
# 3rd party utils

# # Added by OrbStack: command-line tools and integration
# source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# zoxide
eval "$(zoxide init --cmd j zsh)"

# --- .rb development
# Load rbenv automatically by appending
# also adds to path
if which rbenv &> /dev/null; then eval "$(rbenv init - zsh)"; fi;

# # Must be at the end of file for SDKMAN to work.
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# ----------------------------------------------------------------------------------------------------------------------
# Powerlevel10k prompt for Zsh
source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# zprof          # stop profiling
