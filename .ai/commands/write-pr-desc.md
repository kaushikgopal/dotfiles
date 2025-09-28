You are generating a GitHub Pull Request description. Follow these rules strictly:

# Core Principles
- Be concise, factual, and reviewer-centric
- Use short sentences, bullet points, and specific nouns
- Present tense, active voice
- Never make up information - only use what's in the code
- Focus on "why" over "what" - the diff shows what changed

# Required Sections

## Title (50 chars max)
Use imperative mood that completes: "If applied, this PR will..."
- Start with action verb: Add/Fix/Update/Remove/Refactor
- Capitalize first word, no period
- Examples: "Fix duplicate tab creation in Firefox", "Add caching layer for K/V reads"

## Summary
Brief overview explaining what this PR accomplishes:
- Primary change using imperative mood
- Scope: packages/modules affected
- Root cause (for bugs) or motivation (for features)
- Feature flags or configuration changes

## Why
Show the problem and solution through scenarios.

### [Component/Feature Name]
[One-line problem statement]

**Before:**
- Scenario: [specific situation] → [problem/outcome]
- Impact: [user/system effect]

```
[ASCII diagram if it clarifies flow - 5-10 lines]
User → ServiceA → ServiceB → Problem
```

**After:**
- Scenario: [same situation] → [fixed outcome]
- Impact: [improvement achieved]

```
[ASCII diagram of new flow if needed]
User → ServiceA → NewHandler → ServiceB → Success
```

## Implementation
3-5 bullets covering technical approach:
- Key design decisions and trade-offs
- New interfaces or patterns introduced
- Breaking changes or migrations
- Why this approach over alternatives
- Reference related commits if multiple logical changes

## Impact & Testing
**Risk:** [One line - what could break]

**Changes:**
- Performance: [complexity/latency if significant]
- Behavior: [user-facing/API changes]
- Security: [auth/data access if relevant]

**Testing:**
- Coverage: [what's tested]
- Manual validation: [if needed]

**Rollout:**
- [Feature flags, compatibility notes]

## Related
- Links: [issues, RFCs]
- Follow-ups: [TODOs with owners]

# Examples

## Bug Fix Example
**Title:** Fix duplicate tab creation in Firefox redirects

**Summary:**
Prevent duplicate tabs by tracking container switches within 1.5s window. Firefox redirect protection fires multiple URL events for single user actions, creating unwanted duplicate tabs.

**Why - recentContainerSwitches:**
Firefox's redirect protection creates multiple URL events for a single user action.

Before:
- Scenario: User clicks link → Firefox fires 2 events → 2 tabs created
- Impact: Confusing UX with duplicate tabs

After:
- Scenario: User clicks link → Firefox fires 2 events → Second event ignored (within 1.5s window)
- Impact: Single tab as expected

## Feature Example
**Title:** Add write-through cache layer for K/V store reads

**Summary:**
Implement LRU cache with TTL for K/V store reads, configurable per namespace. Reduces database load and improves response times. Behind feature flag `kv_cache_enabled`.

**Why - K/V Store Performance:**
Database queries creating latency spikes during peak traffic.

Before:
- Scenario: 1000 QPS → Each query hits DB → 500ms p99 latency
- Impact: Timeouts and degraded user experience

```
Client → API → DB (every request)
```

After:
- Scenario: 1000 QPS → 95% cache hit rate → 50ms p99 latency
- Impact: 10x latency reduction, eliminated timeouts

```
Client → API → Cache → DB (on miss only)
```

# Constraints
- Max ~200 lines total
- Every section must add unique value
- Concrete examples > abstract descriptions
- Scenario-driven explanations
- Include ASCII diagrams only when they clarify architecture
