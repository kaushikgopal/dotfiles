#!/usr/bin/env bash

YELLOW='\033[1;33m'     # switching section
GRAY='\033[1;30m'       # info
PURPLE='\033[1;35m'     # making change
NC='\033[0m' # No Color

function delete_if_exists {
    if [ -f "$1" ]; then
        echo -e "$1 exists."
        sudo rm -rf "$1" 2> /dev/null
    # else
        echo -e "$1 does not exist."
    fi
}

echo -e "\n\n\n${YELLOW}---- Running cleanup now...${NC}"

echo -e "${PURPLE}---- Rebuilding launch services${NC}"
# Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
# /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user; and killall Finder
 /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# echo -e "${PURPLE}---- Safari caches${NC}"
# delete_if_exists ~/Library/Caches/com.apple.Safari

echo -e "${PURPLE}---- gradle${NC}"
find ~/.gradle -type f -atime +30 -delete
find ~/.gradle -type d -mindepth 1 -empty -delete

echo -e "${PURPLE}---- kscript jars${NC}"
delete_if_exists $HOME/.kscript

# echo -e "${PURPLE}---- .android${NC}"
# delete_if_exists $HOME/.android/cache
# delete_if_exists $HOME/.android/build-cache

# echo -e "${PURPLE}---- CocoaPods${NC}"
# see flushpods.fish
# delete_if_exists $HOME/Library/Caches/CocoaPods

# echo -e "${PURPLE}---- Spotlight refresh${NC}"
# sudo mdutil -a -i off
# sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
# sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
# sudo mdutil -a -i on

# echo -e "${PURPLE}---- DNS flush${NC}"
# see flushdns.fish
# dscacheutil -flushcache;sudo killall -HUP mDNSResponder;

echo -e "${PURPLE}---- homebrew cleanup${NC}"
# brew outdated
# Remove stale lock files and outdated downloads for all formulae and casks
# remove old versions of installed formulae
# brew cleanup

# make system mactch brewfile
brew bundle --force cleanup --file=".brewfile"

# get rid of unused dependencies (used only at time of installation)
brew autoremove
brew doctor

# manual process
# https://thoughtbot.com/blog/brew-leaves
# brew leaves

unset delete_if_exists;