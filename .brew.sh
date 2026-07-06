#!/usr/bin/env bash

set -euo pipefail

YELLOW='\033[1;33m'     # switching section
GRAY='\033[1;30m'       # info
PURPLE='\033[1;35m'     # making change
NC='\033[0m' # No Color

# Match the interactive fish/zsh env so brew reads the same trust store
# (~/.config/homebrew/trust.json) that `brew trust` writes to interactively.
# Without this, brew falls back to ~/.homebrew/trust.json and tap-trust fails.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

BREWFILE="$HOME/.brewfile"
LOCAL_BREWFILE="$HOME/.brewfile.local"
BREW_INSTALL_ONLY="${BREW_INSTALL_ONLY:-0}"

# Trust every non-official tap/formula/cask referenced in the Brewfile(s) so
# `brew bundle` doesn't refuse to load them from untrusted taps. Both the TAP
# and each formula/cask must be trusted: brew bundle --force cleanup can untap
# undeclared taps, and re-tapping requires tap trust (not just formula trust).
# Idempotent. Needed on fresh or SSH'd machines where interactive `brew trust`
# hasn't been run yet.
trust_brewfile_entries() {
    local files=()
    [ -f "$BREWFILE" ] && files+=("$BREWFILE")
    [ -f "$LOCAL_BREWFILE" ] && files+=("$LOCAL_BREWFILE")
    [ ${#files[@]} -eq 0 ] && return 0

    # Collect every non-official tap mentioned (explicit taps + the tap portion
    # of every formula/cask path, i.e. the first two slash-separated segments).
    local all_taps
    all_taps=$({
        grep -hoE '^tap "[a-z0-9_-]+/[a-z0-9_-]+"' "${files[@]}" 2>/dev/null \
            | sed -E 's/^tap "([^"]+)".*/\1/'
        grep -hoE '^(brew|cask) "[a-z0-9_-]+/[a-z0-9_-]+/[a-z0-9_./-]+"' "${files[@]}" 2>/dev/null \
            | sed -E 's/^(brew|cask) "([a-z0-9_-]+\/[a-z0-9_-]+)\/.*/\2/'
    } | sort -u)

    # Trust every tap. `|| true` guards against grep no-match (pipefail + set -e).
    echo "$all_taps" | while read -r t; do
        [ -n "$t" ] && brew trust --tap "$t" 2>/dev/null || true
    done || true

    # Trust non-official formula entries by full name
    grep -hoE '^brew "[a-z0-9_-]+/[a-z0-9_./-]+"' "${files[@]}" 2>/dev/null \
        | sed -E 's/^brew "([^"]+)".*/\1/' | sort -u \
        | while read -r f; do brew trust --formula "$f" 2>/dev/null || true; done || true

    # Trust non-official cask entries by full name
    grep -hoE '^cask "[a-z0-9_-]+/[a-z0-9_./-]+"' "${files[@]}" 2>/dev/null \
        | sed -E 's/^cask "([^"]+)".*/\1/' | sort -u \
        | while read -r c; do brew trust --cask "$c" 2>/dev/null || true; done || true
}

echo -e "\n\n\n${YELLOW}---- Homebrew updates${NC}"

if [ -f "$LOCAL_BREWFILE" ]; then
    echo -e "${GRAY}---- found local brewfile @ ~/.brewfile.local${NC}"
    echo -e "${GRAY}---- ~/.brewfile will load local dependencies during cleanup and install${NC}"
fi

echo -e "${GRAY}---- trusting taps/formulae/casks referenced in Brewfile(s)${NC}"
trust_brewfile_entries

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
