#!/usr/bin/env bash

set -euo pipefail

# for regular updates on existing mac
# `bash ~/.config/setup.sh NOOS`

YELLOW='\033[1;33m'     # switching section
GRAY='\033[1;30m'       # info
PURPLE='\033[1;35m'     # making change
NC='\033[0m' # No Color

BREWFILE="$HOME/.brewfile"
LOCAL_BREWFILE="$HOME/.brewfile.local"
BREW_INSTALL_ONLY="${BREW_INSTALL_ONLY:-0}"

echo -e "\n\n\n${YELLOW}---- Homebrew updates${NC}"

if [ -f "$LOCAL_BREWFILE" ]; then
    echo -e "${GRAY}---- found local brewfile @ ~/.brewfile.local${NC}"
    echo -e "${GRAY}---- ~/.brewfile will load local dependencies during cleanup and install${NC}"
fi

if [[ "$BREW_INSTALL_ONLY" != "1" ]]; then
    echo -e "${PURPLE}---- clean up to match brewfile${NC}"
    brew bundle --force cleanup --file="$BREWFILE"
else
    echo -e "${GRAY}---- bootstrap mode: skipping cleanup, cask upgrade, brew update, and brew upgrade${NC}"
fi

echo -e "${PURPLE}---- installing from brewfile${NC}"
if [ -f "$LOCAL_BREWFILE" ]; then
    echo -e "${GRAY}---- installing dependencies from local brewfile${NC}"
fi
brew bundle install -v --file="$BREWFILE"

echo -e "${PURPLE}---- installing npm global CLIs${NC}"
if [ -x "$HOME/.npm.sh" ]; then
    "$HOME/.npm.sh"
else
    echo -e "${GRAY}---- ~/.npm.sh not found; skipping npm global CLIs${NC}"
fi

if [[ "$BREW_INSTALL_ONLY" != "1" ]]; then
    echo -e "${PURPLE}---- cask upgrade (via cu) ${NC}"
    brew cu --all --cleanup --yes

    echo -e "${PURPLE}\n\n\n\n---- updating formulae${NC}"
    echo -e "${GRAY}\nupdate the local downloaded git repo with latest code${NC}"
    brew update

    echo -e "${PURPLE}---- upgrading packages${NC}"
    echo -e "${GRAY}\ndoes the actual upgrade of packages to update formulate from above step${NC}"
    brew upgrade
fi
