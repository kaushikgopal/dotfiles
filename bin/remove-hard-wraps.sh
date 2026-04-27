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

# Join wrapped lines while collapsing whitespace around the break down to one
# space, but leave paragraph breaks intact.
pbpaste | perl -0pe 's/(\S)[ \t]*\n[ \t]*(\S)/$1 $2/g' | pbcopy
