#!/bin/bash
input=$(cat)

# Extract data
MODEL=$(echo "$input" | jq -r '.model // empty')
CURRENT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage | .input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size')

# Calculate values
PERCENT_USAGE=$(awk "BEGIN {printf \"%.1f\", $CURRENT_TOKENS * 100 / $CONTEXT_SIZE}")
CURRENT_K=$((CURRENT_TOKENS / 1000))
SIZE_K=$((CONTEXT_SIZE / 1000))

# Alternate display every minute (even=tokens, odd=percent)
if [ $((10#$(date +%M) % 2)) -eq 1 ] || true; then
  USAGE="${PERCENT_USAGE}%"
else
  USAGE="${CURRENT_K}/${SIZE_K}k"
fi

# Derive short model name
if echo "$MODEL" | grep -qi "opus"; then
  SHORT_MODEL="opus"
elif echo "$MODEL" | grep -qi "sonnet"; then
  SHORT_MODEL="sonnet"
elif echo "$MODEL" | grep -qi "haiku"; then
  SHORT_MODEL="haiku"
else
  SHORT_MODEL="$MODEL"
fi

# Color based on usage percentage
if awk "BEGIN {exit !($PERCENT_USAGE >= 80)}"; then
  COLOR='\033[31m'  # red
elif awk "BEGIN {exit !($PERCENT_USAGE >= 60)}"; then
  COLOR='\033[33m'  # orange
else
  COLOR='\033[90m'  # dark gray
fi

printf "\033[90m%s\033[0m ${COLOR}%s\033[0m" "$SHORT_MODEL" "$USAGE"
