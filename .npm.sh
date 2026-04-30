#!/usr/bin/env bash

set -euo pipefail

YELLOW='\033[1;33m'
GRAY='\033[1;30m'
NC='\033[0m'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="${NPM_GLOBAL_PACKAGES_FILE:-$script_dir/.npm-global-packages}"

if [[ ! -f "$manifest" && -f "$HOME/.npm-global-packages" ]]; then
    manifest="$HOME/.npm-global-packages"
fi

if [[ ! -f "$manifest" ]]; then
    echo -e "${YELLOW}---- npm global package manifest not found: $manifest${NC}"
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo -e "${YELLOW}---- npm not found; install Node first${NC}"
    exit 1
fi

packages=()
while IFS= read -r line; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | xargs)"
    [[ -n "$line" ]] && packages+=("$line")
done < "$manifest"

if [[ "${#packages[@]}" -eq 0 ]]; then
    echo -e "${GRAY}---- no npm global packages listed in $manifest${NC}"
    exit 0
fi

echo -e "${YELLOW}---- installing npm global CLIs from $manifest${NC}"
npm install -g "${packages[@]}"
