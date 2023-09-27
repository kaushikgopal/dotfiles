# navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."


# better ls
alias ls='ls -G'
alias l='ls -lG'
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
alias ff='fd -HI'   # hidden + ignored
alias hi='history -i'
alias rr='rg --no-ignore --hidden -S'   # hidden + smartcase



alias b='bat'
alias c='code'
alias cat='bat'
alias f='fleet'
alias gw='./gradlew'
alias o='open'
alias oo='open .'
alias s='soulver'
alias t='trash'
alias v='nvim'
alias vi='nvim'

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