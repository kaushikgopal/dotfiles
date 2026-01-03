# PR Description Examples

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

---

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

---

## Refactor Example

**Title:** Extract validation logic into middleware

**Summary:**
Move request validation from controllers into dedicated middleware. Enables reuse across endpoints and standardizes error responses. No behavior change.

**Why - Validation Duplication:**
Same validation logic duplicated across 8 controllers.

Before:
- Scenario: Add new endpoint → Copy-paste validation → Inconsistent error formats
- Impact: Maintenance burden, inconsistent API responses

After:
- Scenario: Add new endpoint → Apply middleware → Consistent validation
- Impact: Single source of truth, uniform error responses

**Implementation:**
- Extract `ValidationMiddleware` with schema-based validation
- Migrate existing endpoints incrementally (no breaking changes)
- Add validation schemas to `/schemas` directory

**Risk:** Low — behavior unchanged, only code organization

---

## Key Patterns

**Titles:**
- Bug: "Fix [symptom] in [context]"
- Feature: "Add [capability] for [use case]"
- Refactor: "Extract/Move/Consolidate [component]"

**Before/After:**
- Always include both
- Be specific: numbers, scenarios, outcomes
- Show the contrast clearly

**ASCII Diagrams:**
- Only when they clarify flow
- Keep to 5-10 lines
- Show the key difference between before/after
