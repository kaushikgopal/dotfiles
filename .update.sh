#!/usr/bin/env bash

# for regular updates on existing mac
# `bash ~/.config/setup.sh NOOS`

YELLOW='\033[1;33m'     # switching section
GRAY='\033[1;30m'       # info
PURPLE='\033[1;35m'     # making change
NC='\033[0m' # No Color


echo -e "\n\n\n${YELLOW}---- Homebrew updates${NC}"

echo -e "${PURPLE}---- clean up to match brewfile ${NC}"
brew bundle --force cleanup --file=".brewfile"

echo -e "${PURPLE}---- installing from brewfile${NC}"
brew bundle install -v --file=".brewfile"

echo -e "${PURPLE}---- cask upgrade (via cu) ${NC}"
brew cu --all --cleanup --yes

echo -e "${PURPLE}\n\n\n\n---- updating formulae${NC}"
# update the local downloaded git repo with latest code
brew update

echo -e "${PURPLE}---- upgrading packages${NC}"
# does the actual upgrade of packages to update formulate from above step
brew upgrade
