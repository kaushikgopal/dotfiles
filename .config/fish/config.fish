# Unlike .bashrc and .profile
# this file is always read
# even in non-interactive or login shells.

# fish_vi_key_bindings # start vi mode
# fish_default_key_binding # go back to default bindings


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



    abbr --add --global o open
    abbr --add --global oo 'open .'
    abbr --add --global t trash



    abbr --add --global g git # using a git function which is better
    abbr --add --global ga 'git a' # add with number support
    abbr --add --global gad 'git add' # add basic
    abbr --add --global gaf 'git add --force'
    abbr --add --global g. 'git add .'
    abbr --add --global gb 'git branch'
    abbr --add --global gbd 'git branch -D'
    abbr --add --global gch 'git ch' # checkout - with number support
    abbr --add --global gco 'git checkout' # checkout - regular
    abbr --add --global gcom 'git checkout master'
    abbr --add --global gcob 'git checkout -B'
    abbr --add --global gco- 'git checkout -'
    abbr --add --global gchp 'git cherry-pick'
    abbr --add --global gcm 'git commit -m'
    abbr --add --global gano 'git commit --amend --no-edit'
    abbr --add --global gd 'git d' # diff with number support
    abbr --add --global gsh "git show HEAD~"
    abbr --add --global gss "git status -s"
    abbr --add --global gdi 'git diff' # diff regular
    abbr --add --global gdc "git dc" # diff --cached with number support
    abbr --add --global gdic 'git diff --cached' # diff --cached regular
    abbr --add --global gll 'git log --graph --decorate --date=short --pretty=format:"%C(magenta)%h%Creset %C(italic black)%ad%C(reset)%C(auto) %s %C(blue)%an%C(auto) %D%C(reset)"'
    abbr --add --global gl 'git log --graph --decorate --date=short --topo-order -30 --pretty=format:"%C(magenta)%h%Creset %C(italic black)%ad%C(reset)%C(auto) %s %C(blue)%an%C(auto) %D%C(reset)"'
    abbr --add --global gmm 'git merge master'
    abbr --add --global gmp 'git checkout master; git pull'
    abbr --add --global gma 'git checkout main'
    abbr --add --global gp 'git pull'
    abbr --add --global gpu 'git push'
    abbr --add --global grb 'git rebase --interactive HEAD~'
    abbr --add --global gwip 'git add .; git commit -a -m "--wip-- [ci skip]" --no-verify' # quick commit (get in the reflog)
    abbr --add --global gwipr 'git reset --soft HEAD~; git reset' # undo last commit (works well with gwip)


    abbr --add --global co code
    abbr --add --global con 'code --new-window'
    abbr --add --global cor 'code --reuse-window'
    abbr --add --global cu cursor

    abbr --add --global bid './bin/dev'
    abbr --add --global bir './bin/rails'
    abbr --add --global gr gradle
    abbr --add --global gw './gradlew'


    # sharkdp/fd - simple and faster laternative to find
    abbr --add --global fd 'fd -u'
    # command fd (to override above)
    # --unrestricted  = include hidden + ignored                # -HI
    # -g              = provide glob pattern allowing to search with patterns
    # -p              = by default it will only match the file/directory name
    #                   this indicates matching full path (so across directories)
    # -e              = extension type
    # -t              = file or directory   # -t d is typical

    # sample commands
    # fd -e pdf
    # fd -e pdf -E taxes          # E is short for --exclude <pattern>
    #
    # fd -td '^build$'   # search for directories named build
    # fd -td build       # substring build (so anywhere in the name)
    #
    # fd -te -td     # --type empty --type directory
    #
    #
    # fd -e .gitignore -x trash   # trash each file independently
    # fd '^\.DS_Store$' -X rm -i  # rm all at once -X implies you execute in the same instance
    #
    #

    abbr --add --global rg 'rg -uuS'
    # -u    = '--no-ignore'                     # also search .ignore
    # -uu   = '--no-ignore --hidden'.           # also search hidden dirs/files
    # -uuu  = '--no-ignore --hidden --binary'.
    # -S = --smart-case
    # -I = --no-filename
    # --no-line-number
    # --color=never  # when you want to script

    # sample commands
    # rg fast README.md               # search for literal "fast" in file README.md
    # rg "com\.android\.application"  # search "pattern"
    # rg "com\.android\.application" --type gradle  -g '!experimental/*'

    # rg 'fn run' -g '*.rs'           # search all rust files for "fun run"
    #            --type rust
    #             -trust
    #            --type-not rust
    #
    # rg fast README.md -r FAST       # replace fast -> FAST
    #
    #  lah .git/hooks | rg -v '\.sample'   # invert the match with -v


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

# ---------------------------------------------------------
# Zoxide

zoxide init --cmd j fish | source


source ~/.secrets.fish
