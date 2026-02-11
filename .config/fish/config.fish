# Unlike .bashrc and .profile
# this file is always read
# even in non-interactive or login shells.

# remove the greeting
set -g fish_greeting

if status is-interactive
    fish_vi_key_bindings # start vi mode
end

# fish_default_key_binding # go back to default bindings
set -g fish_prompt_pwd_dir_length 0  # don't shorten pwd


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

    abbr -a -- ppath 'echo "$PATH\n\n" | tr ":" "\n"' # print path


    abbr -a -- lsd 'tree -d -CFL 1'
    abbr -a -- tre 'tree --dirsfirst -CFL 1'

    abbr -a -- o open
    abbr -a -- oo 'open .'
    abbr -a -- t trash

    abbr -a -- b   bat
    abbr -a -- cat bat

    abbr -a -- bid './bin/dev'
    abbr -a -- bir './bin/rails'
    abbr -a -- gr gradle
    abbr -a -- gw './gradlew'

    # abbr -a -- fd 'rg --files'  # use rg instead of fd (one less dep)
    abbr -a -- rgu 'rg -u'
    abbr -a -- rguu 'rg -uu'
    abbr -a -- rguuu 'rg -uuu'

    # git commands
    abbr -a -- gg   lazygit
    abbr -a -- g    git # using a git function which is better
    abbr -a -- g.   git add .
    abbr -a -- gs   "git status -s"
    abbr -a -- gcm  git cm
    abbr -a -- greb 'git rebase --interactive HEAD~'

    # llm commands
    #abbr -a -- lm  llm
    #abbr -a -- lmm llm -m
    #abbr -a -- lmc llm cmd

    abbr -a -- co      codex
    abbr -a -- coy     codex --yolo

    abbr -a -- cl      claude
    abbr -a -- cly     claude --dangerously-skip-permissions
    abbr -a -- clp     claude --plugin-dir ~/dev/off/claude-marketplace/caper/android

    abbr -a -- ge      gemini
    abbr -a -- gey     gemini --yolo

    abbr -a -- z   zed

    abbr -a -- tm  tmux
    abbr -a -- tn tmux new -s
    abbr -a -- ta tmux attach -t
    abbr -a -- tk tmux kill-server

    alias vimo='vimn'
    alias vimt='vimn -t'
end

# ----------------------------------------------------------------------------------------------------------------------
# Path   # https://fishshell.com/docs/current/cmds/fish_add_path.html
# set -Ux -> set once and forget
# set -gx -> same as export

set -gx XDG_BIN_HOME $HOME/.local/bin
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state

set -gx ANDROID_HOME $HOME/Library/Android/sdk
set -gx JAVA_HOME $HOME/Applications/Android\ Studio.app/Contents/jbr/Contents/Home
# set -gx JAVA_HOME (/usr/libexec/java_home -v "17")
# set -gx GOKU_EDN_CONFIG_FILE $XDG_CONFIG_HOME/karabiner/karabiner.edn
set -gx BAT_CONFIG_PATH $XDG_CONFIG_HOME/.bat.conf
set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/.ripgreprc
fish_add_path \
    /opt/homebrew/bin \
    $HOME/.cargo/bin \
    $XDG_BIN_HOME

fish_add_path --append \
    /opt/homebrew/sbin \
    /usr/local/bin \
    /usr/bin \
    /bin \
    /usr/local/sbin \
    /usr/sbin \
    /sbin \
    "$ANDROID_HOME/platform-tools" \
    "$ANDROID_HOME/cmdline-tools/latest/bin" \
    "$ANDROID_HOME/tools" \
    "$ANDROID_HOME/tools/bin" \
    "$ANDROID_HOME/emulator"


# ----------------------------------------------------------------------------------------------------------------------
# Cached tool inits (for faster shell startup)

# These tools normally run `tool init | source` on every shell start.
# We cache the output to $XDG_CACHE_HOME/*.fish for speed.
#
# Regenerate all caches manually:
#   regen-shell-caches
#
# Or regenerate individually after updating a tool:
#   fzf --fish > $XDG_CACHE_HOME/fzf.fish
#   zoxide init --cmd j fish > $XDG_CACHE_HOME/zoxide.fish

# Auto-regenerate caches if tool binary is newer than cache file
function __regen_cache_if_stale --argument-names tool_bin cache_file gen_cmd
    command -sq $tool_bin; or return 0
    set -l tool_path (command -s $tool_bin)

    if not test -f $cache_file
        eval $gen_cmd
    else if test $tool_path -nt $cache_file
        eval $gen_cmd
    end
end

# Regenerate all shell caches (run after brew upgrade)
function regen-shell-caches
    echo "Regenerating shell caches..."
    mkdir -p $XDG_CACHE_HOME
    fzf --fish > $XDG_CACHE_HOME/fzf.fish && echo "  ✓ fzf"
    zoxide init --cmd j fish > $XDG_CACHE_HOME/zoxide.fish && echo "  ✓ zoxide"
    echo "Done. Restart your shell."
end

# Check for stale caches on interactive shell start
if status is-interactive
    test -d $XDG_CACHE_HOME; or mkdir -p $XDG_CACHE_HOME
    __regen_cache_if_stale fzf $XDG_CACHE_HOME/fzf.fish "fzf --fish > $XDG_CACHE_HOME/fzf.fish"
    __regen_cache_if_stale zoxide $XDG_CACHE_HOME/zoxide.fish "zoxide init --cmd j fish > $XDG_CACHE_HOME/zoxide.fish"
end

# -----------------------------------
# FZF

if status is-interactive
    # enable FZF for fish while disabling alt + c
    test -f $XDG_CACHE_HOME/fzf.fish; and FZF_ALT_C_COMMAND= source $XDG_CACHE_HOME/fzf.fish

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
end

# -----------------------------------
# Zoxide
if status is-interactive
    test -f $XDG_CACHE_HOME/zoxide.fish; and source $XDG_CACHE_HOME/zoxide.fish
end

# ---------------------------------------------------------
# special instructions on bind
# function on_fish_bind_mode --on-variable fish_bind_mode
# end

# ---------------------------------------------------------
# Starship
# starship init fish | source

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

test -f ~/.secrets.fish; and source ~/.secrets.fish
