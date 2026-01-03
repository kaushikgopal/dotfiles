# Analysis Guide

Framework for analyzing each line of code thoroughly.

## For Each Line, Ask

### What Does It Do?

- What is the immediate effect of this line?
- What state does it read? What state does it modify?
- What does it return or produce?

### Why This Approach?

- Why this method/function and not an alternative?
- Why this data structure?
- Why this order of operations?
- Is there a performance reason?
- Is there a readability/maintainability reason?
- Is this defensive coding against something?

### What Could Go Wrong?

- What inputs would break this?
- What if the data is empty? Null? Huge?
- What if this is called concurrently?
- What exceptions could be thrown?
- What if a dependency fails?

### What's Non-Obvious?

- Implicit type conversions
- Side effects not obvious from the function name
- Mutations of input parameters
- Reliance on external state
- Ordering dependencies with other code
- Magic numbers or strings

## Common Patterns to Recognize

### Control Flow
- Guard clauses (early returns)
- Null coalescing
- Short-circuit evaluation
- Loop invariants

### Data Handling
- Defensive copying
- Immutability patterns
- Lazy initialization
- Memoization

### Error Handling
- Try/catch scope decisions
- Error propagation vs handling
- Fallback values
- Retry logic

### Performance
- Caching
- Batch operations
- Avoiding repeated computation
- Memory vs CPU tradeoffs
- Algorithm complexity choices

### Concurrency
- Synchronization
- Atomic operations
- Race condition prevention
- Deadlock avoidance

## Red Flags to Note

- Catch-all exception handlers that swallow errors
- Magic numbers without explanation
- Commented-out code
- TODO/FIXME/HACK comments
- Overly clever one-liners
- Deep nesting (>3 levels)
- Functions doing multiple unrelated things
- Mutable global state access
- Inconsistent error handling

## Green Flags to Note

- Clear variable names that explain intent
- Single responsibility
- Appropriate abstraction level
- Good error messages
- Defensive programming where appropriate
- Efficient algorithms for the data size
- Consistent patterns with rest of codebase
