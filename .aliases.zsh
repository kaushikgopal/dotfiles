# better ls
alias l='ls -G'
alias la='ls -alG'
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

alias fdu='fd -u' # --unrestricted =  # hidden + ignored -HI
# sample commands
#   fdu -e pdf
#   fdu '^\.DS_Store$' -X rm -i

alias rgus='rg --no-ignore --hidden --smart-case'   # -uu = --no-ignore --hidden ; -S = --smart-case
alias rgnc='rg --color=never'

alias b='bat'
alias c='code'
alias cat='bat'
alias f='fleet'
alias g='git'
alias g-='git checkout -'
alias gw='./gradlew'
alias i='idea'
alias ie='idea -e'  # -e light edit mode --wait terminal waits for IDE to exit
alias o='open'
alias oo='open .'
alias s='soulver'
alias t='trash'

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
