# navigation
alias ..="cd .."
alias cd..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"


# better ls
alias l='ls -G'
alias la='ls -aG'
alias ll='ls -lG'
alias lla='ls -alG'
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
alias diff=/Applications/Xcode.app/Contents/Developer/usr/bin/opendiff
alias gw='./gradlew'
alias o='open'
alias oo='open .'
alias s='soulver'
alias t='trash'
alias v='nvim'
alias vi='nvim'



# almost functions
alias battery='pmset -g batt'
alias tds="find . -name '*.DS_Store' -type f -ls -delete" # Recursively delete `.DS_Store` files
# Empty the Trash on all mounted volumes and the main HDD. then clear the useless sleepimage
alias emptytrash=" \
    sudo rm -rfv /Volumes/*/.Trashes; \
    rm -rfv ~/.Trash/*; \
    sudo rm -v /private/var/vm/sleepimage; \
    rm -rv \"$HOME/Library/Application Support/stremio/Cache\";  \
    rm -rv \"$HOME/Library/Application Support/stremio/stremio-cache\" \
"
#alias battery='pmset -g batt # | grep -Eo "\d+%" | cut -d% -f1'
