# Chunk Review Guide

How to review each logical chunk: first explain, then critique.

## Part 1: Explain

Help the user understand what changed and why.

### What to Cover

**The change itself:**
- What does the new code do?
- How does it differ from before? (if modifying existing code)
- What's the entry point / how is it triggered?

**Context:**
- How does this fit into the broader system?
- What depends on this? What does it depend on?
- Any relevant background from PR description or commits?

### Explanation Quality

| Good | Bad |
|------|-----|
| "Adds rate limiting middleware that caps requests to 100/min per IP, using a sliding window stored in Redis" | "Adds rate limiting" |
| "Changes the user lookup from O(n) linear scan to O(1) hash lookup by indexing on user_id" | "Optimizes user lookup" |
| "Moves validation from controller into a dedicated middleware so it can be reused across endpoints" | "Refactors validation" |

Be specific enough that user understands without reading the code.

## Part 2: Critique

Identify genuine issues, not nitpicks.

### What to Look For

**Correctness:**
- Logic errors
- Off-by-one errors
- Null/undefined handling
- Race conditions
- Error handling gaps

**Edge cases:**
- Empty inputs
- Large inputs
- Concurrent access
- Failure scenarios

**Compatibility:**
- Breaking changes to APIs
- Database migration issues
- Backwards compatibility

**Performance:**
- N+1 queries
- Unnecessary allocations
- Missing indexes
- Blocking operations

**Maintainability:**
- Unclear naming
- Missing documentation for complex logic
- Tight coupling
- Code duplication

### Critique Quality

| Good | Bad |
|------|-----|
| "The retry loop has no max attempts — could loop forever if service stays down" | "Should add error handling" |
| "This query runs inside a loop — will cause N+1 queries. Consider batching." | "Performance could be better" |
| "The function name `process` doesn't indicate it also sends emails — consider `processAndNotify`" | "Naming could be improved" |

Be specific: what's the issue, why it matters, and optionally how to fix.

### When There Are No Issues

If the chunk is solid:
```
**Concerns**: None identified. Implementation is clean and handles edge cases appropriately.
```

Don't invent problems. Good code exists.

## Severity Levels

If flagging concerns, indicate severity:

| Level | Meaning | Example |
|-------|---------|---------|
| **Critical** | Must fix before merge | Security vulnerability, data loss risk |
| **Important** | Should fix, or explicitly accept risk | Missing error handling in critical path |
| **Minor** | Nice to fix, not blocking | Naming improvement, minor optimization |
| **Note** | FYI, not necessarily a problem | "This assumes X — worth documenting" |

## Cross-Chunk Concerns

Note issues that span chunks:
- Inconsistent patterns across chunks
- Missing integration between chunks
- Ordering dependencies (chunk 2 assumes chunk 1)
- Test coverage gaps across features
