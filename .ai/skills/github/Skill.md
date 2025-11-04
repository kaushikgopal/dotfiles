---
name: github
description: Use gh CLI for all GitHub operations like PRs, issues, workflows, releases. Always prefer gh commands over web URLs or API calls.
allowed-tools: [Bash]
---

You must start by printing this:

```
--- 🐙 github skill activated 🐙 ---
```

Use `gh` CLI for ALL GitHub operations. Never use web URLs or API calls.

## Key Rules
- **NEVER perform destructive operations**: no delete, close, merge, force-push, or destructive edits
- Only READ operations allowed: view, list, show, check status
- Use non-interactive flags: `--yes`, `--json`, `| cat` to avoid prompts/pagers
- If auth fails: prompt user to run `gh auth login`
- If repo context missing: use `--repo owner/name`

## Common Commands

**Pull Requests:**
```bash
gh pr list
gh pr view <number>
gh pr checkout <number>
gh pr checks
gh pr diff <number>
```

**Issues:**
```bash
gh issue list
gh issue view <number>
```

**CI/Workflows:**
```bash
gh run list
gh run view <id>
gh workflow list
```

**Repository:**
```bash
gh repo view
gh repo clone <repo>
```

**Releases:**
```bash
gh release list
gh release view <tag>
gh release create <tag>
```
