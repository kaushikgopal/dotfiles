# better ls
# alias l='ls -G'        # -G = color
alias lah='ls -lahG' # -a = all, -h = human readable, -l = long format
alias ld='tree -d -CFL 1'
alias tre='tree --dirsfirst -CFL 1'

# use coreutils `ls` if possible…
hash gls >/dev/null 2>&1 || alias gls="ls"
# always use color, even when piping (to awk,grep,etc)
if gls --color >/dev/null 2>&1; then colorflag="--color"; else colorflag="-G"; fi
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

alias rg='rg -uuS'
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

alias b='bat'
alias c='code'
alias cn='code -n'  # -n = --new-window
alias cr='code -r'  # -r = --reuse-window
alias cu='cursor'
alias i='idea'
alias ie='idea -e'             # -e light edit mode
alias iew='idea -e --wait'     # --wait terminal waits for IDE to exit
alias it='idea --temp-project' # --temp-project  # create a temporary project
alias o='open'
alias oo='open .'
alias t='trash'

alias g='git'

alias ga='git a'
alias g.='git add .'
alias gcm='git commit -m'

alias gd='git d'   # diff with number support
alias gdc='git dc' # diff --cached with number support

alias gl='git l'
alias gll='git ll'

alias gch='git ch' # special checkout git alias
alias g-='git checkout -'
alias gm='git checkout master'
alias gmp='git checkout master; git pull'
alias gma='git checkout main'

alias gp='git pull'

alias grc='git rebase --continue'
alias grv='git remote -v'
alias gss='git status --short'

# local development
alias bid='./bin/dev'
alias bir='./bin/rails'
alias gr='gradle'
alias gw='./gradlew'

# these were almost .functions.zsh
alias battery='pmset -g batt'
#alias battery='pmset -g batt # | grep -Eo "\d+%" | cut -d% -f1'
alias trashds="find . -name '*.DS_Store' -type f -ls -delete" # Recursively trash `.DS_Store` files
# Empty the Trash on all mounted volumes and the main HDD. then clear the useless sleepimage
alias trashempty=" \
    sudo rm -rfv /Volumes/*/.Trashes; \
    rm -rfv ~/.Trash/*; \
    sudo rm -v /private/var/vm/sleepimage; \
    rm -rv \"$HOME/Library/Application Support/stremio/Cache\";  \
    rm -rv \"$HOME/Library/Application Support/stremio/stremio-cache\" \
"

#alias diff=/Applications/Xcode.app/Contents/Developer/usr/bin/opendiff
# scripts from specific directories that I like to run directly
#alias oncall='kotlin ~/_src/caper/caper-repo/caper/buildSrc/scripts/oncall.main.kts'
#alias tags='kotlin ~/_src/kotlin-scripts/5.pluck-tags-from-blog-posts.main.kts ~/_src/kau.sh/content/blog'
#alias ktfmt='java -jar /usr/local/bin/ktfmt-0.43-jar-with-dependencies.jar'
