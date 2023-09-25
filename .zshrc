# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# interactive shell configuration
# zmodload zsh/zprof

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
    $ANDROID_HOME/platform-tools
    $ANDROID_HOME/tools
    $ANDROID_HOME/emulator
)
export PATH

    # /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home/bin
    # $HOME/.local/bin
    # $HOME/.fig/bin
    # $HOME/.pyenv/shims


# Prompt related configurations
# eval "$(starship init zsh)"
# autoload -U colors && colors
# local NEWLINE=$'\n'
# local HASH='#'
# PS1="${NEWLINE}%{$fg[white]%}%n@%m %{$fg[magenta]%}%~ %{$reset_color%}${NEWLINE}%{$fg[yellow]%}${HASH}%{$reset_color%} "


# Get the brew prefix
# /opt/homebrew/opt/
# /usr/local/share/
brew_prefix=$(brew --prefix)


# history settings
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY # adds history
setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history



. $HOME/.functions.zsh
. $HOME/.aliases.zsh
. $HOME/.secrets.zsh
source $HOME/.plugins.zsh/magic-enter.plugin.zsh
source $HOME/.plugins.zsh/gitfast/gitfast.plugin.zsh
# source $HOME/.plugins.zsh/almostontop/almostontop.plugin.zsh


# required for homebrew on M1s
if [[ $(uname -p) == 'arm' ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi



# zoxide
eval "$(zoxide init --cmd j zsh)"


# .rb development
. $(brew --prefix)/opt/asdf/libexec/asdf.sh

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

## my aliases
compdef g=git
source $(brew --prefix)/share/zsh/site-functions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # has to be at the very end
## copilot shortcut
# eval "$(github-copilot-cli alias -- "$0")"

# zprof

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Check if the brew prefix is `/opt/homebrew/opt`
if [[ "${brew_prefix}" == "/opt/homebrew" ]]; then
  source "${brew_prefix}/opt/powerlevel10k/powerlevel10k.zsh-theme"
else
  source "${brew_prefix}/powerlevel10k/powerlevel10k.zsh-theme"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
