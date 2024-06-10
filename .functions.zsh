
# Hooks
# chpwd() {
#   ls -lG
# }

# Functions

# List all files, long format, colorized, permissions in octal
# function ll(){
#  	ls -lG  "$@" | awk '
#     {
#       k=0;
#       for (i=0;i<=8;i++)
#         k+=((substr($1,i+2,1)~/[rwx]/) *2^(8-i));
#       if (k)
#         printf("%0o ",k);
#       printf(" %9s  %3s %2s %5s  %6s  %s %s %s\n", $3, $6, $7, $8, $5, $9,$10, $11);
#     }'
# }

# reduce size of a multiple files
# for f in *.jpeg
# do
#       convert -resize 60% "$f" "$f-reduced.jpeg"
# done

# ff jpeg -x convert -resize {} {.}-reduced.jpeg
# placeholder syntax https://github.com/sharkdp/fd#placeholder-syntax

function ..() {
    if (( $# == 0 )); then
        # echo "✓ cd up once"
        cd ..
    else
        if [[ $1 =~ ^[0-9]+$ ]]; then
            # echo "✓ argument received $1"
            for i in {1..$1}
            do
                cd ..
            done
        else
            echo "✗ I don't understand !!"
            return 1
        fi
    fi
}


# who is using the laptop's iSight camera?
camerausedby() {
	echo "Checking to see who is using the iSight camera… 📷"
	usedby=$(lsof | grep -w "AppleCamera\|USBVDC\|iSight" | awk '{printf $2"\n"}' | xargs ps)
	echo -e "Recent camera uses:\n$usedby"
}

# On Mac OS X, cd to the path of the front Finder window
# Found at <http://brettterpstra.com/2013/02/09/quick-tip-jumping-to-the-finder-location-in-terminal>
function cdf() {
    target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
    if [ "$target" != "" ]; then
        cd "$target"
        pwd
    else
        echo 'No Finder window found' >&2
    fi
}

# preview csv files. source: http://stackoverflow.com/questions/1875305/command-line-csv-viewer
function csvpreview(){
      sed 's/,,/, ,/g;s/,,/, ,/g' "$@" | column -s, -t | less -#2 -N -S
}

# Extract archives - use: extract <file>
# Based on http://dotfiles.org/~pseup/.bashrc
function extract() {
	if [ -f "$1" ] ; then
		local filename=$(basename "$1")
		local foldername="${filename%%.*}"
		local fullpath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1"`
		local didfolderexist=false
		if [ -d "$foldername" ]; then
			didfolderexist=true
			read -p "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
			echo
			if [[ $REPLY =~ ^[Nn]$ ]]; then
				return
			fi
		fi
		mkdir -p "$foldername" && cd "$foldername"
		case $1 in
			*.tar.bz2) tar xjf "$fullpath" ;;
			*.tar.gz) tar xzf "$fullpath" ;;
			*.tar.xz) tar Jxvf "$fullpath" ;;
			*.tar.Z) tar xzf "$fullpath" ;;
			*.tar) tar xf "$fullpath" ;;
			*.taz) tar xzf "$fullpath" ;;
			*.tb2) tar xjf "$fullpath" ;;
			*.tbz) tar xjf "$fullpath" ;;
			*.tbz2) tar xjf "$fullpath" ;;
			*.tgz) tar xzf "$fullpath" ;;
			*.txz) tar Jxvf "$fullpath" ;;
			*.zip) unzip "$fullpath" ;;
			*) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

function flushdns() {
    sudo killall -HUP mDNSResponder
    sudo killall mDNSResponderHelper
    sudo dscacheutil -flushcache
    say cleared
}

#function g() {
#    # echo "000 Argument 1 ($1) 2 ($2) 3 ($3)"
#
#    if (( $# == 0 )); then
#        # echo "XXX - no arguments supplied"
#        git status
#    else
#        case "$1" in
#            root)
#                # head to the root of this repo
#                [ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`
#                ;;
#            mr)
#               # handle "MR" (merge requests from git lab)
#               case "$2" in
#                    help)
#                    echo "we have two commands:"
#                    echo "   -- g mr origin <MR-NUMBER>"
#                    echo "   -- g mr pull <MR-NUMBER>"
#                    ;;
#                    origin)
#                    # g 1  2      3
#                    # g mr origin 2597
#                    # mr    = !sh -c 'git fetch $1 merge-requests/$2/head:mr-$1-$2 && git checkout mr-$1-$2' -
#                    git fetch "$2" merge-requests/"$3"/head:mr-"$2-$3" && git checkout mr-"$2-$3"
#                    ;;
#
#                    pull)
#                    # g mr pull
#                    # g pull origin merge-requests/10/head
#                    mrno="$(git symbolic-ref --short HEAD | awk -F'-' '{print $NF}')"
#                    git pull origin merge-requests/"$mrno"/head
#                    ;;
#
#                    *)
#                    echo "🚨 I don't understand !!"
#                    return 1
#                    ;;
#               esac
#               ;;
#            *)
#                # echo "ZZZ - git $argv"
#                git $argv
#                ;;
#        esac
#    fi
#}

# switch jdks (courtesy: https://twitter.com/JakeWharton/status/1463524757765251082?s=20&t=3Zhu54Kul_i3iai2DzCXJQ)
jdk() {
  version=$1
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
  java -version
}

function test() {
    # use $#

    # say if you are expecting exactly 2 parameters
    # -ne is bash's way of saying not equal
    if (( $# < 2 )); then
        echo "this script needs exactly 2 parameters"
        return 1
     fi

     return 0
}

function tot() {
    if ! type "almostontop" > /dev/null; then
        echo "installing almostontop first..."
        source $HOME/.plugins.zsh/almostontop/almostontop.plugin.zsh
    fi

    if (( $# == 0 )); then
        echo "almostontop toggled."
        almostontop_toggle
    else
        case "$1" in
            off)
                almostontop off
                ;;
            on)
                almostontop on
                ;;
        esac
    fi
}

# function ts() {
#     local YELLOW
#     YELLOW='\033[1;33m'     # switching section
#     local GRAY
#     GRAY='\033[1;30m'       # info
#     local PURPLE
#     PURPLE='\033[1;35m'     # making change
#     local NC
#     NC='\033[0m' # No Colo

#     local count
#     count=$(task +next count status:pending rc.verbose=nothing)
#     if (( $count > 0 )); then
#         echo -n -e "\n${PURPLE} ----------------------------------------\n"
#         echo -n -e " You planned to do these +next ($count)"
#         echo -n -e "\n ----------------------------------------\n${NC}"
#         task rc.verbose=nothing +next
#     fi

#     local month
#     month="+dec"
#     count=$(task rc.verbose=nothing $month count )
#     if (( $count > 0 )); then
#         echo -n -e "\n${PURPLE} ----------------------------------------\n"
#         echo -n -e " Goal: Monthly Tasks ($count) $month"
#         echo -n -e "\n ----------------------------------------\n${NC}"
#         task rc.verbose=nothing $month
#     fi

#     echo "\n"

#     count=$(task "(+OVERDUE or +DUE) status:pending" count rc.verbose=nothing)
#     if (( $count > 0 )); then
#         echo -n -e "\n${PURPLE}----------------------------------------\n"
#         echo -n -e " These are overdue or due ! ($count)"
#         echo -n -e "\n ----------------------------------------\n${NC}"
#         task rc.verbose=nothing "(+OVERDUE or +DUE) status:pending"
#     fi

#     if (( $# == 0 )); then
#        return 0;
#     fi

#     count=$(task priority:H count rc.verbose=nothing)
#     if (( $count > 0 )); then
#         echo -n -e "\n${PURPLE}----------------------------------------\n"
#         echo -n -e " You think these are high priority ($count)"
#         echo -n -e "\n ----------------------------------------\n${NC}"
#         task rc.verbose=nothing priority:H
#     fi

#     count=$(task priority:H start: count rc.verbose=nothing)
#     if (( $count > 0 )); then
#         echo -n -e "\n${PURPLE}----------------------------------------\n"
#         echo -n -e " You haven't started these high priority tasks ($count)"
#         echo -n -e "\n ----------------------------------------\n${NC}"
#         task rc.verbose=nothing priority:H start:
#     fi

#     count=$(task project: due: status:pending count rc.verbose=nothing)
#     if (( $count > 0 )); then
#         echo -n -e "\n${PURPLE}----------------------------------------\n"
#         echo -n -e " INBOX  ($count)"
#         echo -n -e "\n ----------------------------------------\n${NC}"
#         task rc.verbose=nothing project: due: status:pending
#     fi

#     echo -n -e "\n${PURPLE}----------------------------------------\n"
#     echo -n -e " List of projects "
#     echo -n -e "\n ----------------------------------------\n"
#     task projects
# }
