# env.nu
#
# Installed by:
# version = "0.105.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.


# ----------------------------------------
# zoxide quick jumper
# ----------------------------------------
# regenerate when needed
#/opt/homebrew/bin/zoxide init --cmd j nushell | save -f ~/.config/nushell/zoxide.nu

# ----------------------------------------
# carapace - x-platform shell autocomplete
# ----------------------------------------
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir ~/.cache/carapace
/opt/homebrew/bin/carapace _carapace nushell | save --force ~/.cache/carapace/init.nu