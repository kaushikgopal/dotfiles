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

    abbr --add -- ppath "echo '$PATH' | tr ':' '\n'" # print path

    # abbr --add -- g     "git" # using a git function which is better
    abbr --add -- ga 'git a' # add     with number support
    abbr --add -- g. 'git add .'
    abbr --add -- gdc "git dc" # diff --cached  with number support
    abbr --add -- gss "git status -s"
    abbr --add -- gcm 'git commit -m'
    abbr --add -- gano 'git commit --amend --no-edit'
    abbr --add -- gd 'git d' # diff with number support
    abbr --add -- gdi 'git diff' # diff regular
    abbr --add -- gdc 'git dc' # diff --cached  with number support
    abbr --add -- gdic 'git diff --cached' # diff --cached  regular

end


#source ~/.config/fish/functions/post-exec.fish
