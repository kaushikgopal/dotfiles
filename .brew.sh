#!/usr/bin/env bash

set -euo pipefail

YELLOW='\033[1;33m'     # switching section
GRAY='\033[1;30m'       # info
PURPLE='\033[1;35m'     # making change
NC='\033[0m' # No Color

# Match the interactive fish/zsh env so Homebrew uses the same user config path.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

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

if [[ "$BREW_INSTALL_ONLY" != "1" ]]; then
    echo -e "${PURPLE}---- upgrading casks and formulae${NC}"
    brew upgrade --greedy

    echo -e "${PURPLE}\n\n\n\n---- updating formulae${NC}"
    echo -e "${GRAY}\nupdate the local downloaded git repo with latest code${NC}"
    brew update

    echo -e "${PURPLE}---- upgrading packages${NC}"
    echo -e "${GRAY}\ndoes the actual upgrade of packages to update formulate from above step${NC}"
    brew upgrade
fi

# Repair Homebrew python@3.14 pyexpat linking when BREW_REPAIR_PYTHON=1.
# macOS /usr/lib/libexpat.1.dylib is missing _XML_SetAllocTrackerActivationThreshold,
# which breaks pip and anything that imports xml.parsers.expat. Run with:
#   BREW_REPAIR_PYTHON=1 ~/.brew.sh
if [[ "${BREW_REPAIR_PYTHON:-0}" == "1" ]] && brew list python@3.14 &>/dev/null; then
    PYPATH=$(find /opt/homebrew/Cellar/python@3.14 -path '*/lib-dynload/pyexpat.cpython-314-darwin.so' -print -quit 2>/dev/null)
    if [ -f "$PYPATH" ]; then
        if otool -L "$PYPATH" | grep -q '/usr/lib/libexpat.1.dylib'; then
            echo -e "${PURPLE}---- repairing python@3.14 pyexpat linkage${NC}"
            install_name_tool -change /usr/lib/libexpat.1.dylib /opt/homebrew/opt/expat/lib/libexpat.1.dylib "$PYPATH"
            codesign --force --sign - "$PYPATH"
        fi
    fi
fi
