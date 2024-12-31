# Unlike .bashrc and .profile
# this file is always read
# even in non-interactive or login shells.


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

    abbr --add --global ppath 'echo "\n$PATH\n\n" | tr ":" "\n"' # print path

    # abbr --add --global g     "git" # using a git function which is better
    abbr --add --global ga 'git a' # add     with number support
    abbr --add --global g. 'git add .'
    abbr --add --global gdc "git dc" # diff --cached  with number support
    abbr --add --global gss "git status -s"
    abbr --add --global gcm 'git commit -m'
    abbr --add --global gano 'git commit --amend --no-edit'
    abbr --add --global gd 'git d' # diff with number support
    abbr --add --global gdi 'git diff' # diff regular
    abbr --add --global gdc 'git dc' # diff --cached  with number support
    abbr --add --global gdic 'git diff --cached' # diff --cached  regular

    abbr --add --global co code

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
