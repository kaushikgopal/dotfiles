# this file is read when starting new interactive shell
# zmodload zsh/zprof          # start profiling


# load order
# .zshenv > .zprofile > .zshrc
# .zshrc (if interactive)


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


# Zsh theme + autocompletion
compdef g=git
source $(brew --prefix)/share/zsh/site-functions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # has to be at the very end

# -------------------
# Monokai Pro for ZSH
source ~/.z-monokai

# override zsh-syntax-highlighting defaults
ZSH_HIGHLIGHT_STYLES[path]=
ZSH_HIGHLIGHT_STYLES[path_pathseparator]=fg=black,bold
ZSH_HIGHLIGHT_STYLES[path_prefix]=

# ----------------------------------------------------------------------------------------------------------------------
# 3rd party utils

# FZF
# Set up fzf key bindings and fuzzy completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# use fzf extended regex matchers
export FZF_DEFAULT_OPS="--extended"

# # Added by OrbStack: command-line tools and integration
# source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# zoxide
eval "$(zoxide init --cmd j zsh)"

# --- .rb development
# Load rbenv automatically by appending
# also adds to path
if which rbenv &> /dev/null; then eval "$(rbenv init - zsh)"; fi;

# # Must be at the end of file for SDKMAN to work.
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"



# ----------------------------------------------------------------------------------------------------------------------
# Powerlevel10k prompt for Zsh
source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# zprof          # stop profiling


### BEGIN--Caper Configurations. (Updated: Tue Mar  4 18:30:32 PST 2025.)
# This Line Added Automatically by Caper Setup Script
# The sourced file contains all of the caper utilities and shell settings
# To remove this functionality, leave the block, and enter "NO-TOUCH" in the BEGIN line, and comment the line below:
source /Users/kg/.caper_configurations
### END--Caper Configurations.
