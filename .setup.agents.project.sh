#!/usr/bin/env bash
#
# Project-level agent setup
# Sets up .agents/ structure and tool-specific symlinks in a project directory.
#
# Usage: .setup.agents.project.sh <project-dir>
#    eg: .setup.agents.project.sh .

set -euo pipefail

GRAY="${GRAY:-\033[1;30m}"
NC="${NC:-\033[0m}"

project_dir="${1:-.}"
project_dir="$(cd "$project_dir" && pwd)"

echo -e "${GRAY}••••••• setting up agent structure in $project_dir ${NC}"
cd "$project_dir"

##############################################################
# AGENTS.md
##############################################################

if [ ! -f AGENTS.md ]; then
    touch AGENTS.md
    echo -e "${GRAY}••••••• created AGENTS.md ${NC}"
fi

# Claude doesn't read AGENTS.md natively
# https://github.com/anthropics/claude-code/issues/6235
if [ ! -f CLAUDE.md ]; then
    echo 'See @AGENTS.md' > CLAUDE.md
    echo -e "${GRAY}••••••• created CLAUDE.md -> @AGENTS.md ${NC}"
fi

##############################################################
# .agents/ structure
##############################################################

mkdir -p .agents/skills    # on-demand instructions ("progressive disclosure")
mkdir -p .agents/commands  # *.md prompt templates for frequent tasks
mkdir -p .agents/plans     # technical execution plans for large changes
mkdir -p .agents/tmp       # .gitignored scratch space for the current session

##############################################################
# Tool-specific symlinks
# Claude doesn't natively read .agents/ — needs explicit symlinks
##############################################################

mkdir -p .claude
ln -sfn ../.agents/commands .claude/commands
ln -sfn ../.agents/skills .claude/skills

mkdir -p .codex
ln -sfn ../.agents/commands .codex/prompts

mkdir -p .gemini
echo '{"context":{"fileName":["AGENTS.md"]}}' > .gemini/settings.json

##############################################################
# .gitignore entries
##############################################################

for pattern in ".agents/tmp/**"; do
    if ! grep -qxF "$pattern" .gitignore 2>/dev/null; then
        echo "$pattern" >> .gitignore
        echo -e "${GRAY}••••••• added $pattern to .gitignore ${NC}"
    fi
done

echo -e "${GRAY}••••••• agent setup complete in $project_dir ${NC}"
