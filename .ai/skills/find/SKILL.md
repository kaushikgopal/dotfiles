---
name: find
description: Fast file and code search using `fd` and `rg`. Use when the user asks to locate files or search code patterns.
compatibility: Assumes a filesystem shell with `fd` and `rg` installed.
allowed-tools: Bash(fd:*) Bash(rg:*)
---

Use `fd` for file search, `rg` for content search.

## Common Patterns

**Find files by name:**
```bash
fd "pattern" [path]
fd -H "pattern" [path]  # include hidden files
fd -e md -e txt "README" [path]
```

**Search file contents:**
```bash
rg -n "pattern" [path]
rg -i "pattern"  # case-insensitive
rg -S "pattern"  # smart case
rg --files-with-matches "pattern"  # list files only
rg -n "pattern" --glob '!node_modules/*'
```

**Find definitions:**
```bash
rg -n "^(class|interface|function|def)\\s+Name\\b"
rg -n "^class\\s+ClassName\\b" --type python
```

**Search with context:**
```bash
rg -n "pattern" -A 2 -B 2
```

**Combine searches:**
```bash
fd -0 "Controller" -t f | xargs -0 rg -n "handleRequest"
```
