Whenever writing a Pull Request (PR), I want the following format to be adopted:

```
# What's changing

<A high level succinct but useful summary that tells me what's changing in this Pull Request overall. I don't want this to go beyond 4 lines>

## ASCII Overview (after)
<If applicable, show a simple diagram (preferably ASCII) or mermaid or flow chart that shows how the system will now look>

## ASCII Overview (before)
<If applicable, show a simple diagram (preferably ASCII) or mermaid or flow chart similar to previous section but how it used to be>

# Why
<bullet point list of problems that existed, sub bullet point on how this PR addresses it>

# How
<useful details expanding on how this PR is changing the system>

# Impact
<One line summary of what to watch out for, because of these changes. Expand in subsections if applicable or add new ones>
## Performance
## Behavior
```