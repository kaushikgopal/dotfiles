# Unlike .bashrc and .profile
# this file is always read
# even in non-interactive or login shells.

# remove the greeting
set -g fish_greeting

fish_vi_key_bindings # start vi mode

# fish_default_key_binding # go back to default bindings
set -g fish_prompt_pwd_dir_length 80  # don't shorten pwd

# ----------------------------------------------------------------------------------------------------------------------
# Alias + abbreviations

if status is-interactive
    # Commands to run in interactive sessions can go here
    # If you put them inside the section, they will only be available in interactive shells
    # which means you can use them when typing commands manually, but not when running scripts
    # or other programs that use fish.

    ################################
    # Abbreviations
    # abbr          # lists all the abbreviations configured
    # abbr --list   # just show the abbreviations
    ################################

    # https://fishshell.com/docs/3.2/cmds/abbr.html#internals

    abbr --add --global ppath 'echo "$PATH\n\n" | tr ":" "\n"' # print path


    abbr --add --global lsd 'tree -d -CFL 1'
    abbr --add --global tre 'tree --dirsfirst -CFL 1'

    abbr --add --global o open
    abbr --add --global oo 'open .'
    abbr --add --global t trash

    abbr --add --global b   bat
    abbr --add --global cat bat

    abbr --add --global bid './bin/dev'
    abbr --add --global bir './bin/rails'
    abbr --add --global gr gradle
    abbr --add --global gw './gradlew'

    # abbr --add --global fd 'rg --files'  # use rg instead of fd (one less dep)
    abbr --add --global rgu 'rg -u'
    abbr --add --global rguu 'rg -uu'
    abbr --add --global rguuu 'rg -uuu'

    # git commands
    abbr --add --global g    git # using a git function which is better
    abbr --add --global g.   git add .
    abbr --add --global gs   "git status -s"
    abbr --add --global gcm  git cm
    abbr --add --global greb 'git rebase --interactive HEAD~'

    # llm commands
    #abbr --add --global lm  llm
    #abbr --add --global lmm llm -m
    #abbr --add --global lmc llm cmd

    abbr --add --global co  codex --yolo
    abbr --add --global cl  claude  --dangerously-skip-permissions
    abbr --add --global cu  cursor
    abbr --add --global cug cursor . -g
    abbr --add --global z   zed

    abbr --add --global ts tailscale

    alias vimo='vimn'
    alias vimt='vimn -t'
end

# ----------------------------------------------------------------------------------------------------------------------
# Path   # https://fishshell.com/docs/current/cmds/fish_add_path.html

fish_add_path /opt/homebrew/bin # so homebrew is available
fish_add_path ~/bin
# fish_add_path --append  # so we maintain the order as declared
fish_add_path --append (brew --prefix)/sbin
fish_add_path --append /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
fish_add_path --append ~/.local/bin # pipx

export ANDROID_HOME=$HOME/Library/Android/sdk
fish_add_path --append "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/cmdline-tools/latest/bin" "$ANDROID_HOME/tools" "$ANDROID_HOME/tools/bin" "$ANDROID_HOME/emulator"

export JAVA_HOME=$HOME/Applications/Android\ Studio.app/Contents/jbr/Contents/Home
# export JAVA_HOME=(/usr/libexec/java_home -v"17")
# export GOKU_EDN_CONFIG_FILE=$HOME/.config/karabiner/karabiner.edn
export BAT_CONFIG_PATH=$HOME/.config/.bat.conf

export RIPGREP_CONFIG_PATH=$HOME/.config/.ripgreprc

set -Ux PYENV_ROOT $HOME/.pyenv
test -d $PYENV_ROOT/bin; and fish_add_path $PYENV_ROOT/bin

# -----------------------------------
# FZF

# enable FZF for fish while disabling alt + c
fzf --fish | FZF_ALT_C_COMMAND= source

# set -gx FZF_DEFAULT_COMMAND 'rg --files'
# default command is different from ctrl + t
set -gx FZF_CTRL_T_COMMAND 'rg --files'

# Ctrl+T preview with syntax highlighting
set -gx FZF_CTRL_T_OPTS " \
  --height 60% \
  --layout=reverse \
  --border \
  --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
  --preview-window=right:60%:wrap"

# CTRL-Y to copy the command into clipboard when previewing command history
set -gx FZF_CTRL_R_OPTS " \
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' \
  --color header:italic \
  --header 'Press CTRL-Y to copy command into clipboard'"

# -----------------------------------
# Zoxide
zoxide init --cmd j fish | source

# ---------------------------------------------------------
# special instructions on bind
# function on_fish_bind_mode --on-variable fish_bind_mode
# end

# ---------------------------------------------------------
# Starship
# starship init fish | source

# -----------------------------------
# pyenv for python development setup
if not command -q pyenv
    # Keep startup quiet when pyenv is absent; otherwise the guard would still emit noise on machines without Python tooling.
    true
else
    # Ensure shims and shell functions are active so `pyenv shell` stops erroring when fish sessions start.
    pyenv init - fish | source
end

# Custom key bindings
# this allows me to use my karabiner delete word keybindings in fish
function fish_user_key_bindings
    # Provide word-wise navigation and editing in both insert (vi) and default modes
    for mode in insert default
        bind -M $mode \eb  backward-word          # Alt-b → move word left
        bind -M $mode \ef  forward-word           # Alt-f → move word right
        # Alt+Backspace can be sent as ESC DEL (\e\x7f) or ESC Backspace (\e\b)
        bind -M $mode \e\x7f backward-kill-word   # Alt-Backspace → delete previous word
        bind -M $mode \e\b  backward-kill-word    # Alt-Backspace (alternate)
        bind -M $mode \cu  backward-kill-line     # Ctrl-u → cut from line start
    end
end

source ~/.secrets.fish
