#!/bin/bash
input=$(cat)

# Extract data
MODEL=$(echo "$input" | jq -r '.model.display_name')
CURRENT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage | .input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size')

# Calculate values
PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
CURRENT_K=$((CURRENT_TOKENS / 1000))
SIZE_K=$((CONTEXT_SIZE / 1000))

# Color based on usage percentage
if [ $PERCENT_USED -ge 80 ]; then
  COLOR='\033[31m'  # red
elif [ $PERCENT_USED -ge 60 ]; then
  COLOR='\033[33m'  # orange
else
  COLOR='\033[90m'  # dark gray
fi

printf "\033[90m%s\033[0m ${COLOR}%dk/%dk\033[0m" "$MODEL" "$CURRENT_K" "$SIZE_K"
