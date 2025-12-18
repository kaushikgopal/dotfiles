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
    abbr --add --global gg   lazygit
    abbr --add --global g    git # using a git function which is better
    abbr --add --global g.   git add .
    abbr --add --global gs   "git status -s"
    abbr --add --global gcm  git cm
    abbr --add --global greb 'git rebase --interactive HEAD~'

    # llm commands
    #abbr --add --global lm  llm
    #abbr --add --global lmm llm -m
    #abbr --add --global lmc llm cmd

    abbr --add --global co  codex
    abbr --add --global cl  claude
    abbr --add --global ge  gemini
    abbr --add --global cu  cursor
    abbr --add --global cug cursor . -g
    abbr --add --global z   zed

    abbr --add --global ts tailscale

    abbr --add --global tm     tmux new -s

    alias vimo='vimn'
    alias vimt='vimn -t'
end

# ----------------------------------------------------------------------------------------------------------------------
# Path   # https://fishshell.com/docs/current/cmds/fish_add_path.html
# set -Ux -> set once and forget
# set -gx -> same as export

set -gx XDG_CONFIG_HOME $HOME/.config

set -gx ANDROID_HOME $HOME/Library/Android/sdk
set -gx JAVA_HOME $HOME/Applications/Android\ Studio.app/Contents/jbr/Contents/Home
# set -gx JAVA_HOME (/usr/libexec/java_home -v "17")
# set -gx GOKU_EDN_CONFIG_FILE $HOME/.config/karabiner/karabiner.edn
set -gx BAT_CONFIG_PATH $HOME/.config/.bat.conf
set -gx RIPGREP_CONFIG_PATH $HOME/.config/.ripgreprc
set -Ux PYENV_ROOT $HOME/.pyenv

fish_add_path /opt/homebrew/bin # so homebrew is available
fish_add_path ~/bin
# fish_add_path --append  # so we maintain the order as declared
fish_add_path --append /opt/homebrew/sbin
fish_add_path --append /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin
fish_add_path --append ~/.local/bin # pipx

fish_add_path --append "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/cmdline-tools/latest/bin" "$ANDROID_HOME/tools" "$ANDROID_HOME/tools/bin" "$ANDROID_HOME/emulator"
test -d $PYENV_ROOT/bin; and fish_add_path $PYENV_ROOT/bin

# ----------------------------------------------------------------------------------------------------------------------
# Cached tool inits (for faster shell startup)

# These tools normally run `tool init | source` on every shell start.
# We cache the output to ~/.cache/*.fish for speed.
#
# Regenerate all caches manually:
#   regen-shell-caches
#
# Or regenerate individually after updating a tool:
#   fzf --fish > ~/.cache/fzf.fish
#   zoxide init --cmd j fish > ~/.cache/zoxide.fish
#   pyenv init - fish > ~/.cache/pyenv.fish

# Auto-regenerate caches if tool binary is newer than cache file
function __regen_cache_if_stale --argument-names tool_bin cache_file gen_cmd
    if not test -f $cache_file
        eval $gen_cmd
    else if test (which $tool_bin) -nt $cache_file
        eval $gen_cmd
    end
end

# Regenerate all shell caches (run after brew upgrade)
function regen-shell-caches
    echo "Regenerating shell caches..."
    mkdir -p ~/.cache
    fzf --fish > ~/.cache/fzf.fish && echo "  ✓ fzf"
    zoxide init --cmd j fish > ~/.cache/zoxide.fish && echo "  ✓ zoxide"
    pyenv init - fish > ~/.cache/pyenv.fish 2>/dev/null && echo "  ✓ pyenv"
    echo "Done. Restart your shell."
end

# Check for stale caches on first interactive shell of the day
if status is-interactive
    set -l today (date +%Y-%m-%d)
    if test "$__shell_cache_check_date" != "$today"
        set -g __shell_cache_check_date $today
        __regen_cache_if_stale fzf ~/.cache/fzf.fish "fzf --fish > ~/.cache/fzf.fish"
        __regen_cache_if_stale zoxide ~/.cache/zoxide.fish "zoxide init --cmd j fish > ~/.cache/zoxide.fish"
        __regen_cache_if_stale pyenv ~/.cache/pyenv.fish "pyenv init - fish > ~/.cache/pyenv.fish 2>/dev/null"
    end
end

# -----------------------------------
# FZF

# enable FZF for fish while disabling alt + c
FZF_ALT_C_COMMAND= source ~/.cache/fzf.fish

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
source ~/.cache/zoxide.fish

# ---------------------------------------------------------
# special instructions on bind
# function on_fish_bind_mode --on-variable fish_bind_mode
# end

# ---------------------------------------------------------
# Starship
# starship init fish | source

# -----------------------------------
# pyenv for python development setup
test -f ~/.cache/pyenv.fish && source ~/.cache/pyenv.fish

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
