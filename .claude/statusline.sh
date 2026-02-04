#!/bin/bash

input=$(cat)
output=""

# Get model name
model=$(echo "$input" | jq -r '.model // empty')
if [ -n "$model" ]; then
  # Extract short name (opus, sonnet, haiku) from model string
  if echo "$model" | grep -qi "opus"; then
    short_model="opus"
  elif echo "$model" | grep -qi "sonnet"; then
    short_model="sonnet"
  elif echo "$model" | grep -qi "haiku"; then
    short_model="haiku"
  else
    short_model="$model"
  fi
  output="\033[90m${short_model}\033[0m"
fi

# Get token usage
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
  current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
  size=$(echo "$input" | jq '.context_window.context_window_size')
  pct=$((current * 100 / size))
  current_k=$((current / 1000))
  size_k=$((size / 1000))

  # Color based on usage percentage
  if [ $pct -ge 80 ]; then
    c='\033[31m'  # red
  elif [ $pct -ge 60 ]; then
    c='\033[33m'  # orange/yellow
  else
    c='\033[32m'  # green
  fi

  if [ -n "$output" ]; then
    output="${output} "
  fi
  output="${output}${c}${current_k}k/${size_k}k\033[0m"
fi

printf "$output"
