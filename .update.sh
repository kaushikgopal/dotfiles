#!/usr/bin/env bash

set -euo pipefail

YELLOW='\033[1;33m'
GRAY='\033[1;30m'
NC='\033[0m'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
brew_script="${BREW_SCRIPT:-$script_dir/.brew.sh}"
npm_script="${NPM_SCRIPT:-$script_dir/.npm.sh}"

if [[ ! -x "$brew_script" && -x "$HOME/.brew.sh" ]]; then
    brew_script="$HOME/.brew.sh"
fi

if [[ ! -x "$npm_script" && -x "$HOME/.npm.sh" ]]; then
    npm_script="$HOME/.npm.sh"
fi

echo -e "\n\n\n${YELLOW}---- Updating Homebrew dependencies${NC}"
if [[ -x "$brew_script" ]]; then
    "$brew_script"
else
    echo -e "${YELLOW}---- Homebrew setup script not found: $brew_script${NC}"
    exit 1
fi

echo -e "\n\n\n${YELLOW}---- Updating npm global CLIs${NC}"
if [[ -x "$npm_script" ]]; then
    "$npm_script"
else
    echo -e "${GRAY}---- npm setup script not found; skipping npm global CLIs${NC}"
fi
