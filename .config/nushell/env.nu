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


#/opt/homebrew/bin/zoxide init --cmd j nushell | save -f ~/.config/nushell/zoxide.nu

$env.RIPGREP_CONFIG_PATH = ($nu.home-path | path join '.config' '.ripgreprc')
$env.ANDROID_HOME =  ($nu.home-path | path join 'Library' 'Android' 'sdk')
$env.JAVA_HOME = ($nu.home-path | path join 'Applications' 'Android Studio.app' 'Contents' 'jbr' 'Contents' 'Home')
## export JAVA_HOME=(/usr/libexec/java_home -v"17")
$env.GOKU_EDN_CONFIG_FILE = ($nu.home-path | path join '.config' 'karabiner' 'karabiner.edn')
$env.BAT_CONFIG_PATH = ($nu.home-path | path join '.config' '.bat.conf')

source-env ($nu.home-path | path join '.config' 'nushell' 'secrets.nu')
