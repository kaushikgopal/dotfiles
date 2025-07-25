# config.nu
#
# Installed by:
# version = "0.105.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

# ----------------------------------------
# env vars
# ----------------------------------------

$env.RIPGREP_CONFIG_PATH = ($nu.home-path | path join '.config' '.ripgreprc')
$env.ANDROID_HOME =  ($nu.home-path | path join 'Library' 'Android' 'sdk')
$env.JAVA_HOME = ($nu.home-path | path join 'Applications' 'Android Studio.app' 'Contents' 'jbr' 'Contents' 'Home')
## export JAVA_HOME=(/usr/libexec/java_home -v"17")
$env.GOKU_EDN_CONFIG_FILE = ($nu.home-path | path join '.config' 'karabiner' 'karabiner.edn')
$env.BAT_CONFIG_PATH = ($nu.home-path | path join '.config' '.bat.conf')

# ----------------------------------------
# $env.path
# ----------------------------------------
use std/util "path add"

# prepends
path add "/opt/homebrew/opt/sdkman-cli/libexec/candidates/gradle/current/bin"
path add "~/.local/bin"
path add "~/.pyenv/shims"
path add "/sbin"
path add "/usr/sbin"
path add "/bin"
path add "/usr/bin"
path add "/usr/local/bin"
path add "/opt/homebrew/sbin"
path add "/opt/homebrew/bin"
path add "~/bin"

path add ($env.ANDROID_HOME | path join "emulator")
path add ($env.ANDROID_HOME | path join "tools/bin")
path add ($env.ANDROID_HOME | path join "tools")
path add ($env.ANDROID_HOME | path join "cmdline-tools/latest/bin")
path add ($env.ANDROID_HOME | path join "platform-tools")

# appends
#$env.path ++= ["/usr/local/bin"]

# ----------------------------------------
# configuration
# ----------------------------------------

$env.config.show_banner = false # true or false to enable or disable the welcome banner at startup

$env.config.edit_mode = 'vi'
$env.config.cursor_shape = {
  vi_insert: underscore # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
  vi_normal: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
}

# ----------------------------------------
# keybindings
# keybidings listen # to detect
# ----------------------------------------

$env.config.keybindings ++= [
  {
    modifier: alt
    keycode: char_b
    mode: [vi_insert]
    event: { edit: MoveWordLeft }
  }
  {
    modifier: alt
    keycode: char_f
    mode: [vi_insert]
    event: { edit: MoveWordRight }
  }
  {
    modifier: alt
    keycode: backspace
    mode: [vi_insert]
    event: { edit: BackspaceWord }
  }
  {
    modifier: control
    keycode: char_u
    mode: [vi_insert]
    event: { edit: CutFromLineStart }
  }
]

# ----------------------------------------
# aliases
# ----------------------------------------
# # system commands (start with ^)
# # alias ls-builtin = ^ls
alias o = ^open
alias oo = ^open .
alias t = trash
alias b = bat
alias gw = ./gradlew
alias fdu = fd -u
alias rgu = rg -uuu  # see .ripgreprc

# git commands
alias g = git

alias gco = git checkout
alias gm = git checkout master
alias gma = git checkout main
alias g- = git checkout -

alias gp = git pull
alias gpu = git push
alias gb = git branch
alias gbd = git branch -D

alias gcf = git commit --fixup

alias gs = git status -s
alias gsu = git ls-files --other --directory --exclude-standard # list all untracked things

alias gss = git stash save
alias gsp = git stash pop

alias gdin = git diff --name-only master...HEAD # list files that have changed

alias gms = git merge --squash
alias gmm = git merge master

alias gl = git log --graph --decorate --date=short --topo-order -30 --pretty=format:"%C(magenta)%h%Creset %C(italic brightblack)%ad%C(reset)%C(auto) %s %C(blue)%an%C(auto) %D%C(reset)"
alias gll = git log --graph --decorate --date=short --pretty=format:"%C(magenta)%h%Creset %C(italic brightblack)%ad%C(reset)%C(auto) %s %C(blue)%an%C(auto) %D%C(reset)"

alias c = claude
alias cyolo = claude --dangerously-skip-permissions

alias cur = cursor -r
alias cun = cursor -n

alias ts = tailscale

# ----------------------------------------
# functions
# ----------------------------------------
# greet "Kaushik"
def greet [name] {
  "Hello, " + $name + "!"
}

def tre [nesting:int = 1] {
  ^tree --dirsfirst -CFL ($nesting)
}

def gd [refFiles:string = "."] {
  git d ($refFiles)
}

def gdc [refFiles:string = "."] {
  git dc ($refFiles)
}

def ga [refFiles:string = "."] {
  # importantly we're using shortform `a`
  # see https://kau.sh/blog/git-alias/
  git a ($refFiles)
}

def gano [] {
  git add .
  git commit --amend --no-edit
}

def gcm [msg?: string] {
  if ($msg | is-empty) {
    git commit -m (claude -p "Look at the staged git changes and create a summarizing git commit title. Only respond with the title and no affirmation.")
  } else {
    git commit -m $msg
  }
}

def gsh [cnum:int = 0] {
  git show HEAD~($cnum)
}

def gmp [branch:string = "master"] {
  git checkout ($branch)
  git pull
}


def vimn [dir:string = "/tmp"] {
  let dir = if $dir == "o" { "~/notes/obsd" } else { $dir }
  let timestamp = (date now | format date "%Y%m%d-%H%M%S")
  let filename = $timestamp + ".md"
  let filepath = ($dir | path expand | path join $filename)
  echo '---' > $filepath
  echo 'tags:' >> $filepath
  echo '  - cli' >> $filepath
  echo '---' >> $filepath
  echo '' >> $filepath

  vim $filepath
}
alias vimo = vimn "o"
alias vimt = vimn

def --env cdf [] {
  # Change to the current Finder directory
  let finder_dir = (^osascript -e 'tell application "Finder" to if (count of windows) > 0 then get POSIX path of (target of front window as alias)' | complete)

  if $finder_dir.exit_code == 0 {
    let dir = ($finder_dir.stdout | str trim)
    if ($dir | path exists) and ($dir | path type) == "dir" {
      cd $dir
    } else {
      print "Finder directory does not exist or is not a directory."
    }
  } else {
    print "No Finder window found."
  }
}

# ----------------------------------------
# secrets
# ----------------------------------------
# stuff i don't want in public dotfiles
# source-env ($nu.home-path | path join '.config' 'nushell' 'secrets.nu')
source ($nu.home-path | path join '.config' 'nushell' 'secrets.nu')

# ----------------------------------------
# prompt (powered by starship)
# ----------------------------------------

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")


# ----------------------------------------
# zoxide quick jumper
# ----------------------------------------
# regenerate when needed
#zoxide init --cmd j nushell | save -f ~/.config/nushell/zoxide.nu
source ~/.config/nushell/zoxide.nu

# ----------------------------------------
# carapace - x-platform shell autocomplete
# ----------------------------------------
source ~/.cache/carapace/init.nu
