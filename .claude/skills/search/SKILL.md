---
name: search
description: Fast file and code searching using fd and rg. Use when user asks to find files or search code patterns.
allowed-tools: [Bash, Glob, Grep, Read]
---

You must start by printing this:

```
--- 🥷 search skill activated 🥷 ---
```

Use `fd` for file search, `rg` for content search.

## Common Patterns

**Find files by name:**
```bash
fd "pattern" [path]
fd -e md -e txt "README"
```

**Search file contents:**
```bash
rg "pattern" [path]
rg -i "pattern"  # case-insensitive
rg --files-with-matches "pattern"  # list files only
```

**Find definitions:**
```bash
rg "^(class|interface|function|def)\s+Name"
rg "^class\s+ClassName" --type python
```

**Search with context:**
```bash
rg "pattern" -A 2 -B 2
```

**Combine searches:**
```bash
fd "Controller" | xargs rg "handleRequest"
```
