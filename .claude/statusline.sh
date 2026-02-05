#!/bin/bash
input=$(cat)

# Colors
GRAY='\033[90m'
ORANGE='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Extract all data with single jq call
eval "$(echo "$input" | jq -r '
  @sh "CWD=\(.cwd // empty)",
  @sh "MODEL=\(.model.display_name // .model // empty | ascii_downcase)",
  @sh "PCT=\(.context_window.used_percentage // 0 | floor)",
  @sh "CTX_K=\((.context_window.context_window_size // 200000) / 1000 | floor)"
')"

# Git branch and directory
BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
DIR=$(basename "$CWD")

# Color based on usage
COLOR=$GRAY
((PCT >= 60)) && COLOR=$ORANGE
((PCT >= 80)) && COLOR=$RED

# Output
LOC="$DIR${BRANCH:+ | $BRANCH}"
printf "${GRAY}%s | ${COLOR}%s%%/%sk${GRAY}    %s${RESET}" "$MODEL" "$PCT" "$CTX_K" "$LOC"
