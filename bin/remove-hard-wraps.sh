#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Remove Hard Wraps
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Kaush
# @raycast.authorURL https://kau.sh

pbpaste | perl -0pe 's/(?<!\n)\n(?!\n)/ /g' | pbcopy
