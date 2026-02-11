---
name: simplify-code
description: Simplifies code for clarity and maintainability while preserving exact behavior. Focuses on recently modified code. Use when user says "simplify", "simplify code", "make this simpler", "clean up", or "refactor for clarity".
compatibility: Requires filesystem read/write access. Uses git if available to scope changes. Language-agnostic.
---

# Simplify Code

Reduce unnecessary complexity while preserving exact functionality. Prioritize clarity and maintainability over brevity.

## Philosophy

**Simple code is not short code.** Simplicity means:

- Easy to read sequentially without mental backtracking
- Intent is obvious from structure, not comments
- Each function/block does one thing
- Control flow is linear where possible
- No cleverness that requires explanation

Compression that hurts readability is not simplification.

## Scope

Default scope: **recently modified code** in the current session.

To identify scope:
1. Check staged changes: `git diff --staged`
2. Fall back to unstaged: `git diff`
3. Use user-provided file paths if specified

Do **not** perform broad refactors (cross-file renames, architecture changes) unless explicitly requested.

## Process

### 1. Identify Target Code

```bash
git diff --staged --name-only  # or git diff --name-only
```

Read the modified files. Focus only on changed sections and their immediate context.

### 2. Establish Constraints

Before making changes, confirm these preservation requirements:

- **Behavior**: All outputs, side effects, and observable behavior unchanged
- **API surface**: Public functions, exports, and interfaces unchanged
- **Error handling**: All error paths and messages preserved
- **Performance**: No algorithmic complexity regressions

If unsure whether a change preserves behavior, do not make it.

### 3. Apply Simplifications

Work through the code applying transformations in priority order. Open [SIMPLIFICATION-GUIDE.md](SIMPLIFICATION-GUIDE.md) for detailed heuristics.

**Priority order** (highest first):

1. **Flatten control flow**: Guard clauses, early returns, reduce nesting depth
2. **Remove redundancy**: Dead code, duplicate logic, unused variables, unreachable branches
3. **Clarify names**: Rename only within the modified surface area
4. **Decompose**: Split functions only when it reduces cognitive load
5. **Normalize patterns**: Align with existing conventions (check AGENTS.md if present)

### 4. Avoid Anti-Patterns

Do **not** introduce:

- Nested ternaries (use if/else or early returns)
- Dense one-liners that hide control flow
- Abstractions that exist only to reduce line count
- Clever solutions that require explanation
- Changes outside the touched surface area

See [SIMPLIFICATION-GUIDE.md](SIMPLIFICATION-GUIDE.md) for detailed anti-patterns.

### 5. Validate

1. Run the narrowest available test/check for the modified area
2. Review the diff to confirm only intended changes
3. Verify no new dependencies or imports added unnecessarily

### 6. Report

Summarize what changed and why it's simpler.

## Output Format

After completing simplification, provide:

```markdown
## Simplification Summary

**Scope**: {files or areas modified}

### Changes Made

- {Change 1}: {what was done and why it's simpler}
- {Change 2}: {what was done and why it's simpler}
- ...

### Why Simpler

- {Reduced nesting from N to M levels}
- {Eliminated N lines of duplicate logic}
- {Clearer control flow via guard clauses}

### Preserved

- {Confirm behavior unchanged}
- {Confirm API unchanged}
- {Note any intentional complexity retained and why}

### Verification

- {Tests/checks run, or "none available"}
- {Diff reviewed: yes/no}
```

## Guidelines

- **Preserve first**: When in doubt, don't change it
- **Small changes**: Multiple small improvements > one large rewrite
- **Explain tradeoffs**: If you leave complexity in place, note why
- **Local conventions**: Follow patterns already in the codebase (check AGENTS.md)
- **No feature creep**: Simplification is not the time to add functionality
