#!/usr/bin/env bash

set -euo pipefail

YELLOW='\033[1;33m'
GRAY='\033[1;30m'
NC='\033[0m'

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="${NPM_GLOBAL_PACKAGES_FILE:-$script_dir/.npm-global-packages}"
local_manifest="${NPM_GLOBAL_PACKAGES_LOCAL_FILE:-$HOME/.npm-global-packages.local}"

if [[ ! -f "$manifest" && -f "$HOME/.npm-global-packages" ]]; then
    manifest="$HOME/.npm-global-packages"
fi

if [[ ! -f "$manifest" && ! -f "$local_manifest" ]]; then
    echo -e "${YELLOW}---- npm global package manifest not found: $manifest${NC}"
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo -e "${YELLOW}---- npm not found; install Node first${NC}"
    exit 1
fi

packages=()
package_manifests=()
function add_packages_from_manifest {
    local package_manifest="$1"

    [[ -f "$package_manifest" ]] || return 0

    package_manifests+=("$package_manifest")
    while IFS= read -r line; do
        line="${line%%#*}"
        line="$(printf '%s' "$line" | xargs)"
        [[ -n "$line" ]] && packages+=("$line")
    done < "$package_manifest"
}

add_packages_from_manifest "$manifest"
if [[ -f "$local_manifest" ]]; then
    echo -e "${GRAY}---- found local npm package manifest @ ~/.npm-global-packages.local${NC}"
    add_packages_from_manifest "$local_manifest"
fi

if [[ "${#packages[@]}" -eq 0 ]]; then
    echo -e "${GRAY}---- no npm global packages listed in configured manifests${NC}"
    exit 0
fi

echo -e "${YELLOW}---- installing npm global CLIs from ${package_manifests[*]}${NC}"
npm install -g "${packages[@]}"
