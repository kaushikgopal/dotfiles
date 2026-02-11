#!/usr/bin/env bash
#
# User-level (global) agent setup
# Sets up ~/.agents as the canonical intermediary, then wires each tool to it.
#
# Can be run standalone or sourced from .setup.sh

set -euo pipefail

GRAY="${GRAY:-\033[1;30m}"
NC="${NC:-\033[0m}"

# Detect dotfiles directory: use $current_dir if set (sourced from .setup.sh),
# otherwise derive from this script's location
dotfiles_dir="${current_dir:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

echo -e "${GRAY}••••••• setting up agent symlinks${NC}"

##############################################################
# Legacy cleanup
##############################################################

if [ -L "$HOME/.ai" ] || [ -e "$HOME/.ai" ]; then
    echo -e "${GRAY}••••••• removing legacy $HOME/.ai ${NC}"
    rm -rf "$HOME/.ai"
fi

##############################################################
# ~/.agents -> dotfiles/.agents (one canonical intermediary)
##############################################################

echo -e "${GRAY}••••••• symlinking $dotfiles_dir/.agents -> $HOME/.agents ${NC}"
rm -rf "$HOME/.agents"
ln -sfn "$dotfiles_dir/.agents" "$HOME/.agents"

echo -e "${GRAY}••••••• symlinking $HOME/.agents/AGENTS.md -> $HOME/AGENTS.md ${NC}"
rm -rf "$HOME/AGENTS.md"
ln -sfn "$HOME/.agents/AGENTS.md" "$HOME/AGENTS.md"

##############################################################
# Claude Code
# ~/.claude is a real directory (not a repo symlink)
# - agent assets go through ~/.agents intermediary
# - tool-specific files (statusline.sh) link directly to dotfiles repo
##############################################################

if [ -L "$HOME/.claude" ]; then
    echo -e "${GRAY}••••••• removing legacy $HOME/.claude symlink ${NC}"
    rm "$HOME/.claude"
fi
mkdir -p "$HOME/.claude"

echo -e "${GRAY}••••••• symlinking (claude) files${NC}"
ln -sfn "$HOME/.agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
ln -sfn "$HOME/.agents/commands"  "$HOME/.claude/commands"
ln -sfn "$HOME/.agents/skills"    "$HOME/.claude/skills"
ln -sfn "$dotfiles_dir/.claude/statusline.sh" "$HOME/.claude/statusline.sh"
ln -sfn "$dotfiles_dir/.claude/settings.json" "$HOME/.claude/settings.json"

mkdir -p "$HOME/.claude/hooks"

##############################################################
# Codex
##############################################################

echo -e "${GRAY}••••••• symlinking (codex) files${NC}"
mkdir -p "$HOME/.codex"

rm -rf "$HOME/.codex/prompts"
ln -sfn "$HOME/.agents/commands" "$HOME/.codex/prompts"
ln -sfn "$HOME/AGENTS.md" "$HOME/.codex/AGENTS.md"
