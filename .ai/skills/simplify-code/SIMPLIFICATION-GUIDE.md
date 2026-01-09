# Simplification Guide

Detailed heuristics for code simplification. Reference this during the transformation phase.

## Core Principle

Every transformation must pass this test: **Would a new team member understand the result faster than the original?**

If not, it's not a simplification.

---

## Simplification Categories

### 1. Flatten Control Flow

**Goal**: Reduce nesting depth, make the "happy path" obvious.

#### Guard Clauses (Early Returns)

Convert nested conditionals to early exits:

```
// Before: nested
function process(x) {
  if (x != null) {
    if (x.isValid) {
      // ... 20 lines of logic
    }
  }
}

// After: flat
function process(x) {
  if (x == null) return
  if (!x.isValid) return
  // ... 20 lines of logic
}
```

**When to apply**:
- Validation/precondition checks
- Error conditions that abort early
- Nesting depth > 2

**When NOT to apply**:
- When early return would skip important cleanup
- When the "else" branch has significant logic (not just returning)

#### Invert Conditions for Clarity

Prefer positive conditions when possible:

```
// Before
if (!user.isDisabled) { ... }

// After (if semantically equivalent)
if (user.isEnabled) { ... }
```

#### Consolidate Nested Ifs

```
// Before
if (a) {
  if (b) {
    doThing()
  }
}

// After
if (a && b) {
  doThing()
}
```

**Only if** neither condition has an else branch with different logic.

---

### 2. Remove Redundancy

#### Dead Code

Remove code that:
- Is never executed (unreachable after return/throw)
- Is commented out (if it's needed, it should be in version control)
- Assigns to variables never read
- Defines functions never called

#### Duplicate Logic

Identify repeated patterns. Extract **only if**:
- The pattern appears 3+ times
- The extraction has a clear, meaningful name
- The abstraction is stable (won't diverge between call sites)

Do NOT extract if:
- Only 2 occurrences (wait for the third)
- The "pattern" is coincidental, not conceptual
- Extraction requires many parameters

#### Unnecessary Variables

```
// Before
const result = computeValue()
return result

// After
return computeValue()
```

**Keep the variable if**:
- The name adds semantic meaning
- It's used in debugging/logging
- The expression is complex and benefits from a name

#### Redundant Conditionals

```
// Before
if (condition) {
  return true
} else {
  return false
}

// After
return condition
```

```
// Before
if (condition) {
  return x
}
return x

// After
return x
```

---

### 3. Clarify Names

**Rename only within the modified surface area.** Do not chase renames across the codebase.

#### Variable Names

- Avoid single letters except for conventional uses (i/j for loops, e for events/errors)
- Name should describe content, not type (`users` not `userArray`)
- Boolean names should read as yes/no questions (`isValid`, `hasPermission`, `canEdit`)

#### Function Names

- Verb + noun format (`validateUser`, `fetchOrders`)
- Name should describe **what**, not **how**
- Side-effecting functions: verb implies mutation (`updateCache`, `sendEmail`)
- Pure functions: verb implies computation (`calculateTotal`, `formatDate`)

#### Avoid Renaming When

- The current name is adequate (not great, but understandable)
- Renaming would require changes outside modified files
- The name follows existing codebase conventions

---

### 4. Decompose Functions

Split a function **only if**:
- It's doing multiple distinct things
- A section can be named meaningfully
- The extraction reduces cognitive load, not just line count

Do NOT split if:
- The function is already coherent
- Extraction would require passing many parameters
- The "extracted" function would only be called once and has no standalone meaning

#### Signs a Function Should Be Split

- Multiple levels of abstraction mixed together
- Comments that say "Step 1", "Step 2" or similar
- Distinct setup/process/cleanup phases
- Reusable logic buried in context-specific code

#### Signs to Leave It Alone

- Linear flow that reads top-to-bottom
- All code is at the same abstraction level
- Splitting would just move code without adding clarity

---

### 5. Normalize Patterns

Align code with existing conventions in the codebase. Check AGENTS.md if present.

#### What to Normalize

- Error handling approach (exceptions vs. result types vs. callbacks)
- Naming conventions (camelCase, snake_case, etc.)
- Import/module organization
- Formatting (defer to existing style or formatter config)

#### What NOT to Normalize During Simplification

- Framework or library choices
- Architecture patterns
- Test structure

These require broader discussion, not opportunistic changes.

---

## Anti-Patterns to Avoid

### Nested Ternaries

```
// Never do this
const result = a ? (b ? x : y) : (c ? z : w)

// Use if/else or switch
let result
if (a) {
  result = b ? x : y
} else {
  result = c ? z : w
}
```

Even single ternaries should be simple. If condition or branches are complex, use if/else.

### Dense One-Liners

```
// Avoid
return items.filter(x => x.active).map(x => x.id).reduce((a, b) => a + b, 0) || defaultValue

// Prefer
const activeItems = items.filter(x => x.active)
const ids = activeItems.map(x => x.id)
const sum = ids.reduce((a, b) => a + b, 0)
return sum || defaultValue
```

Each line should do one thing. Chain length > 2 is a smell.

### Premature Abstraction

```
// Avoid: abstraction for one use case
function processWithOptions(data, options = {}) {
  const { transform = x => x, filter = () => true, sort = () => 0 } = options
  return data.filter(filter).map(transform).sort(sort)
}

// Prefer: direct code until patterns emerge
const filtered = data.filter(x => x.active)
const transformed = filtered.map(x => x.value)
```

Wait for the third occurrence before abstracting.

### Clever Bit Manipulation

```
// Avoid (unless in performance-critical code with comments)
const isEven = !(n & 1)

// Prefer
const isEven = n % 2 === 0
```

### Abusing Short-Circuit Evaluation

```
// Avoid: using && for control flow
condition && doSomething()

// Prefer
if (condition) {
  doSomething()
}
```

Exception: `value || defaultValue` and `value && value.property` are idiomatic.

### Over-Parameterization

```
// Avoid
function format(value, options) {
  const {
    prefix = '',
    suffix = '',
    transform = x => x,
    validate = () => true,
    onError = () => {}
  } = options
  // ...
}

// Prefer: separate functions for distinct behaviors
function formatWithPrefix(value, prefix) { ... }
function formatWithValidation(value, validator) { ... }
```

---

## Preservation Checklist

Before finalizing changes, verify:

### Behavior

- [ ] All function outputs unchanged for same inputs
- [ ] Side effects occur in same order and conditions
- [ ] Error messages and codes unchanged
- [ ] Logging/telemetry unchanged (unless explicitly asked)

### API Surface

- [ ] Function signatures unchanged (names, parameters, return types)
- [ ] Exported/public interfaces unchanged
- [ ] Exceptions/errors thrown are same types

### Performance

- [ ] No algorithmic complexity increase (O(n) doesn't become O(n^2))
- [ ] No additional allocations in hot paths
- [ ] No removed optimizations (caching, memoization) unless buggy

### Edge Cases

- [ ] Null/empty handling unchanged
- [ ] Boundary conditions unchanged
- [ ] Concurrent access behavior unchanged (if applicable)

---

## Quality Signals

### Red Flags to Address

- Nesting depth > 3 levels
- Functions > 50 lines (context-dependent)
- More than 5 parameters
- Boolean parameters that change behavior
- Comments explaining "what" instead of "why"
- Catch blocks that swallow errors silently
- Magic numbers/strings without names

### Green Flags to Preserve

- Descriptive variable names
- Guard clauses at function start
- Single level of abstraction per function
- Clear error messages with context
- Consistent patterns with rest of codebase
- Intentional defensive code with clear purpose

---

## When NOT to Simplify

Leave code alone if:

- You don't fully understand what it does
- It has comments explaining non-obvious constraints
- Performance characteristics are critical and not obvious
- Changes would cascade outside the modified area
- The code is generated or third-party
- The "simpler" version is actually just shorter, not clearer
