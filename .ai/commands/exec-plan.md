---
description: "Create or resume execution plan for autonomous feature implementation"
---

You are orchestrating an execution plan (ExecPlan) workflow for autonomous feature implementation. Read .ai/plans/PLANS.md for complete requirements. This command handles three scenarios: creating new plans, resuming existing plans, and updating plans with progress.

## Command Usage

`/exec-plan [feature-name]` - Create or resume an execution plan

If no feature name provided, infer from conversation context.

### Feature Name Normalization

Convert feature names to valid filenames:
- Lowercase: "User Authentication" → "user-authentication"
- Spaces to hyphens: "API Rate Limiting" → "api-rate-limiting"
- Remove special characters: "users/auth" → "users-auth"
- Truncate if > 50 characters

Example: `/exec-plan "API Rate Limiting"` → `.ai/plans/api-rate-limiting.md`

## Before Starting

At the start of ANY conversation (including after compaction):
1. Check conversation history for plan references (look for "Source of truth: .ai/plans/")
2. If found, read that plan file and check TASKS section for pending work
3. If pending tasks exist, ask user: "Resume execution of [feature-name]?"
4. If user confirms, skip to Step 3 (EXECUTION stage)

**When multiple plans exist:**
If ambiguous which plan to work on (no plan name specified, multiple active plans found), list them and ask:
```
Found multiple plans with pending tasks:
- feature-a.md (6 pending)
- feature-b.md (3 pending)

Which should I resume?
```

This ensures seamless resumption after compaction without manual intervention.

## Workflow Orchestration

### Step 1: Detect Current State

Check if `.ai/plans/[feature-name].md` exists:

- **If NO (new plan):** Proceed to DESIGN stage
- **If YES (existing plan):** Read the file and determine:
  - Are there pending tasks? → Resume EXECUTION
  - Has conversation progressed since last update? → Update plan then resume EXECUTION
  - Otherwise → Resume EXECUTION from current state

### Step 2: DESIGN Stage (New Plans Only)

Output stage transition:
```
====================================
🎨 Entering DESIGN stage
====================================
```

**Research Phase (Autonomous):**
1. Search codebase for relevant patterns, files, and integration points
2. Read key files to understand current architecture
3. Identify dependencies and libraries in use
4. Gather all necessary context

**Design Generation:**
Create the DESIGN section of the exec plan following the template in PLANS.md. Use hybrid prose/bullets:
- Purpose / Big Picture (prose, 2-4 sentences)
- Context & Orientation (prose for definitions, bullets for key files)
- Plan of Work (prose narrative)
- Concrete Steps (bullets with expected outputs)
- Interfaces & Dependencies (bullets with code examples)
- Validation & Acceptance (bullets)

**Clarification Phase (Collaborative):**
After generating initial design:
1. Show the design to user
2. Ask specific clarifying questions about:
   - Ambiguous requirements
   - Implementation approach choices
   - Integration decisions
   - Any unknowns that could affect design

**Iterate on design** based on user answers. Update the DESIGN section as needed.

**Confirmation:**
Once design is complete and all questions answered, ask:
```
Design complete. Ready to proceed to EXECUTION?
```

Wait for user confirmation before proceeding.

### Step 3: EXECUTION Stage

Output stage transition:
```
====================================
⚡ Entering EXECUTION stage
====================================

📋 Executing plan: .ai/plans/[feature-name].md
   This file is the SOURCE OF TRUTH for all context, decisions, and progress.
```

**If new plan:** Generate TASKS section with granular breakdown from DESIGN. Include subtasks for each major task.

**If existing plan:** Read TASKS section to see current state and next pending task.

**Autonomous Execution Loop:**

For each pending task:

1. **Execute the task** (implement code, run tests, make changes)
2. **Document decisions** in EXECUTION → Decision Log if any choices were made:
   ```
   - **Decision:** [what]
     **Rationale:** [why, alternatives considered]
     **Date:** [YYYY-MM-DDTHH:MM:SSZ]
     **Files Affected:** [paths]
   ```
3. **Document surprises** in EXECUTION → Surprises & Discoveries if anything unexpected happened
4. **Update TASKS section:**
   - Move task to Completed with timestamp (ISO 8601 format)
   - Add inline decision note (💡 Decision: ...)
   - Add files changed (📁 Files: ...)
   - Mark next task as In Progress
   - Update "Last Updated" field at top of file
5. **Output progress:**
   ```
   ✓ Task completed: [task name]
   ✓ TASKS updated (X completed, Y pending)
   📋 Source of truth: .ai/plans/[feature-name].md
   ```
   Immediately after posting this update in the conversation, continue executing the next pending task without pausing or waiting for replies unless a blocker occurs.
6. **Sync to TodoWrite** (if using Claude Code): Update TodoWrite todo list to match TASKS section
7. **Continue to next task without asking for permission**

**DO NOT:**
- Ask "should I continue?" between tasks
- Ask "is this correct?" after each edit
- Wait for user input during execution
- Stop prematurely

**ONLY stop when:**
- All tasks completed → Fill EXECUTION → Outcomes & Retrospective, then output: "✓ All tasks completed!"
- Blocker encountered → Explain issue, ask for guidance, update EXECUTION → Next Steps with what's needed to proceed

**When all tasks completed:**
1. Fill EXECUTION → Outcomes & Retrospective section:
   - What was delivered
   - What remains (if any)
   - Lessons learned
   - Compare result against original Purpose
2. Output: "✓ All tasks completed! Retrospective added."

### Step 4: Resuming After Compaction

Compaction is handled automatically via "Before Starting" instructions:
- Agent checks conversation history for plan references
- Finds "Source of truth: .ai/plans/[feature-name].md" in summary
- Reads plan file and checks for pending tasks
- Asks user to resume, then continues from current task

When resuming execution after compaction:

1. **Read the plan file:** `.ai/plans/[feature-name].md`
2. **Output:**
   ```
   Reading source of truth: .ai/plans/[feature-name].md

   Progress: X completed, Y pending
   Resuming from: [next task description]
   ```
3. **Resume EXECUTION loop** from current task

## Key Principles

### Source of Truth
- The exec plan file is **always** the source of truth
- Conversation context is **secondary** to the file
- After compaction, ignore conversation details - read the file

### Update Frequency
- **TASKS:** After every completed task (high frequency)
- **EXECUTION → Decision Log:** When making choices (as needed)
- **EXECUTION → Surprises:** When discovering unexpected behavior (as needed)
- **EXECUTION → Next Steps:** Before any stop (every stop)
- **EXECUTION → Current Status:** Before any stop (every stop)
- **DESIGN:** Only when design actually changes (rare)

### Timestamp Format
Always use ISO 8601 format for all timestamps: **YYYY-MM-DDTHH:MM:SSZ**

Examples:
- 2025-10-29T15:30:00Z
- 2025-11-01T09:00:00Z

Use this format for:
- Task completion timestamps
- Decision Log dates
- Surprises & Discoveries dates
- Last Updated field

### When to Update DESIGN

Update DESIGN section only when fundamental changes occur:
- Core approach changes (e.g., switching from REST to GraphQL)
- Architecture pivot (e.g., switching libraries, microservice → monolith)
- Major requirement change from user

When updating DESIGN:
1. Make the changes to relevant DESIGN subsections
2. Document in EXECUTION → Decision Log:
   - **Decision:** Updated DESIGN - [what changed]
   - **Rationale:** [why the change was necessary]
   - **DESIGN Changes:** [which subsections were updated]
   - **Date:** [YYYY-MM-DDTHH:MM:SSZ]

### Task Granularity
Break tasks into subtasks for maximum agent autonomy:

**Good (granular):**
```
- [ ] Implement user authentication
  - [ ] Create User model with password field
  - [ ] Add bcrypt password hashing
  - [ ] Set up Passport.js strategy
  - [ ] Add authentication middleware
```

**Bad (too high-level):**
```
- [ ] Implement user authentication
```

### Decision Documentation
When you make implementation choices, document them immediately with rationale:

```
- **Decision:** Use RS256 algorithm for JWT instead of HS256
  **Rationale:** RS256 allows key rotation without service redeployment. Public/private key pair is more secure for distributed systems. HS256 would require sharing secret across services.
  **Date:** 2025-10-29T10:15:00Z
  **Files Affected:** backend/src/auth/jwt.service.ts, backend/src/config/jwt.config.ts
```

This creates a clear audit trail of "what and why" that future agents (or humans) can understand.

### Output Format Consistency

Use exact formatting for stage transitions and progress updates so they survive compaction and are visually distinct:

```
====================================
[emoji] [Stage name]
====================================
```

Emojis: 🎨 for DESIGN, ⚡ for EXECUTION

## File Structure

Each exec plan is a single .md file with this structure:

```markdown
# [Feature Name]

This ExecPlan follows .ai/plans/PLANS.md requirements and is a living document.

If using Claude Code, you can derive TodoWrite session state from TASKS section.

Last Updated: [YYYY-MM-DDTHH:MM:SSZ]

---

# DESIGN
[sections per template in PLANS.md]

---

# EXECUTION
[sections per template in PLANS.md]

---

# TASKS
[sections per template in PLANS.md]
```

See <template></template> section in PLANS.md for complete structure.

## Examples

### Example 1: Creating New Plan

User runs: `/exec-plan user-authentication`

1. Check `.ai/plans/user-authentication.md` → doesn't exist
2. Output: `🎨 Entering DESIGN stage`
3. Research codebase autonomously
4. Generate DESIGN section
5. Ask clarifying questions: "Should we support refresh tokens? Email or username login?"
6. User answers questions
7. Update design based on answers
8. Ask: "Ready to proceed to EXECUTION?"
9. User: "yes"
10. Output: `⚡ Entering EXECUTION stage` + plan reference
11. Generate granular TASKS breakdown
12. Execute first task → update TASKS → output progress + plan reference
13. Execute second task → update TASKS → output progress + plan reference
14. Continue autonomously until all tasks complete or blocker

### Example 2: Resuming After Compaction

Conversation was compacted. New session starts:

1. Agent checks conversation summary → finds "Source of truth: .ai/plans/user-authentication.md"
2. Agent reads `.ai/plans/user-authentication.md`
3. Check TASKS → see 6 completed, 4 pending, currently "In Progress: Add JWT middleware"
4. Agent asks: "Resume execution of user-authentication?"
5. User: "yes" (or runs `/exec-plan user-authentication`)
6. Output: `Reading source of truth: .ai/plans/user-authentication.md`
7. Output: `Progress: 6 completed, 4 pending. Resuming from: Add error handling to JWT middleware`
8. Resume EXECUTION loop from current task
9. Complete task → update TASKS → output progress + plan reference
10. Continue autonomously

## Important Reminders

- **Fully autonomous during EXECUTION** - no interruptions between tasks
- **Output plan reference after every task** - ensures it survives compaction
- **Update file frequently** - it's external memory
- **Sync TodoWrite automatically** - keep both in sync
- **Document all decisions** - future you (or future agent) will thank you
- **Granular tasks with subtasks** - maximizes autonomy
- **Treat file as source of truth** - always read it after compaction
