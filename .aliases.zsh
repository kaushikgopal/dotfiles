# better ls
# alias l='ls -G'        # -G = color
alias lah='ls -lahG'    # -a = all, -h = human readable, -l = long format
alias ld='tree -d -CFL 1'
alias tr='tree --dirsfirst -CFL 3'

# use coreutils `ls` if possible…
hash gls >/dev/null 2>&1 || alias gls="ls"
# always use color, even when piping (to awk,grep,etc)
if gls --color > /dev/null 2>&1; then colorflag="--color"; else colorflag="-G"; fi;
export CLICOLOR_FORCE=1



# verbose these semi-destructive commands
alias mv='mv -v'
alias rm='rm -i -v'
alias cp='cp -v'



# useful defaults for these specific commands
alias hi='history -i'

# sharkdp/fd - simple and faster laternative to find
alias fd='fd -u'
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
    # fd -t d '^build$'   # search for directories named build
    # fd -t d build       # substring build (so anywhere in the name)
    #
    # fd -e .gitignore -x trash   # trash each file independently
    # fd '^\.DS_Store$' -X rm -i  # rm all at once -X implies you execute in the same instance
    #
    #

alias rg='rg -uuS'
    # -uu = --no-ignore --hidden
    # -S = --smart-case
    # -I = --no-filename
    # --no-line-number
    # --color=never  # when you want to script
    # -u    = '--no-ignore'.
    # -uu   = '--no-ignore --hidden'.
    # -uuu  = '--no-ignore --hidden --binary'.

  # sample commands
    # rg fast README.md               # search for literal "fast" in file README.md
    # rg "com\.android\.application"  # search "pattern"
    # rg "com\.android\.application" --type gradle  -g '!experimental/*'

    # rg 'fn run' -g '*.rs'           # search all rust files for "fun run"
    #            --type rust
    #             -trust
    #            --type-not rust
    # rg fast README.md -r FAST       # replace fast -> FAST

alias b='bat'
alias c='code'
alias cat='bat'
alias f='fleet'
alias i='idea'
alias ie='idea -e'  # -e light edit mode --wait terminal waits for IDE to exit
alias o='open'
alias oo='open .'
alias s='soulver'
alias t='trash'


alias ber='bundle exec rails'
alias gw='./gradlew'


alias g='git'
alias g-='git checkout -'
alias ga.='git add .'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -D'
alias gcm='git commit -m'
alias gd='git d'    # diff with number support
alias gdc='git dc'  # diff --cached with number support
alias gm='git checkout master'
alias gl='git l'
alias gll='git ll'
alias grc='git rebase --continue'
alias grv='git remote -v'
alias gss='git status --short'


#alias diff=/Applications/Xcode.app/Contents/Developer/usr/bin/opendiff


# scripts from specific directories that I like to run directly
alias oncall='kotlin ~/_src/caper/caper-repo/caper/buildSrc/scripts/oncall.main.kts'
alias tags='kotlin ~/_src/kotlin-scripts/5.pluck-tags-from-blog-posts.main.kts ~/_src/kau.sh/content/blog'
alias ktfmt='java -jar /usr/local/bin/ktfmt-0.43-jar-with-dependencies.jar'


# these were almost .functions.zsh

alias battery='pmset -g batt'
#alias battery='pmset -g batt # | grep -Eo "\d+%" | cut -d% -f1'


# Recursively trash `.DS_Store` files
alias tds="find . -name '*.DS_Store' -type f -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD. then clear the useless sleepimage
alias emptytrash=" \
    sudo rm -rfv /Volumes/*/.Trashes; \
    rm -rfv ~/.Trash/*; \
    sudo rm -v /private/var/vm/sleepimage; \
    rm -rv \"$HOME/Library/Application Support/stremio/Cache\";  \
    rm -rv \"$HOME/Library/Application Support/stremio/stremio-cache\" \
"
