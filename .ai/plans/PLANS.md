# Execution Plans (ExecPlans):

This document describes the requirements for an execution plan ("ExecPlan"), a design document that a coding agent can follow to deliver a working feature or system change. Treat the reader as a complete beginner to this repository: they have only the current working tree and the single ExecPlan file you provide. There is no memory of prior plans and no external context.

## How to use ExecPlans and PLANS.md

When authoring an executable specification (ExecPlan), follow PLANS.md _to the letter_. If it is not in your context, refresh your memory by reading the entire PLANS.md file. Be thorough in reading (and re-reading) source material to produce an accurate specification. When creating a spec, start from the template and flesh it out as you do your research.

When implementing an executable specification (ExecPlan), do not prompt the user for "next steps"; simply proceed autonomously. Keep all sections up to date, add or split entries in the list at every stopping point to affirmatively state the progress made and next steps. Resolve ambiguities autonomously, and commit frequently.

When discussing an executable specification (ExecPlan), record decisions in a log in the spec for posterity; it should be unambiguously clear why any change to the specification was made. ExecPlans are living documents, and it should always be possible to restart from _only_ the ExecPlan and no other work.

When researching a design with challenging requirements or significant unknowns, implement proof of concepts, "toy implementations", etc., that allow validating whether the user's proposal is feasible. Read the source code of libraries by finding or acquiring them, research deeply, and include prototypes to guide a fuller implementation.

## Requirements

NON-NEGOTIABLE REQUIREMENTS:

* Every ExecPlan must be fully self-contained. Self-contained means that in its current form it contains all knowledge and instructions needed for a novice to succeed.
* Every ExecPlan is a living document. Contributors are required to revise it as progress is made, as discoveries occur, and as design decisions are finalized. Each revision must remain fully self-contained.
* Every ExecPlan must enable a complete novice to implement the feature end-to-end without prior knowledge of this repo.
* Every ExecPlan must produce a demonstrably working behavior, not merely code changes to "meet a definition".
* Every ExecPlan must define every term of art in plain language or do not use it.

Purpose and intent come first. Begin by explaining, in a few sentences, why the work matters from a user's perspective: what someone can do after this change that they could not do before, and how to see it working. Then guide the reader through the exact steps to achieve that outcome, including what to edit, what to run, and what they should observe.

The agent executing your plan can list files, read files, search, run the project, and run tests. It does not know any prior context and cannot infer what you meant from earlier sections. Repeat any assumption you rely on. Do not point to external blogs or docs; if knowledge is required, embed it in the plan itself in your own words. If an ExecPlan builds upon a prior ExecPlan and that file is checked in, incorporate it by reference. If it is not, you must include all relevant context from that plan.

## Formatting

Format and envelope are simple and strict. Each ExecPlan must be one single fenced code block labeled as `md` that begins and ends with triple backticks. Do not nest additional triple-backtick code fences inside; when you need to show commands, transcripts, diffs, or code, present them as indented blocks within that single fence. Use indentation for clarity rather than code fences inside an ExecPlan to avoid prematurely closing the ExecPlan's code fence. Use two newlines after every heading, use # and ## and so on, and correct syntax for ordered and unordered lists.

When writing an ExecPlan to a Markdown (.md) file where the content of the file *is only* the single ExecPlan, you should omit the triple backticks.

Write using hybrid prose/bullets approach: prose where it helps understanding of "why" and flow, bullets where agent needs to scan "what" and "how". Checklists are mandatory in the TASKS section. DESIGN sections should be prose-focused for narrative clarity where it aids comprehension.

## Guidelines

Self-containment and plain language are paramount. If you introduce a phrase that is not ordinary English ("daemon", "middleware", "RPC gateway", "filter graph"), define it immediately and remind the reader how it manifests in this repository (for example, by naming the files or commands where it appears). Do not say "as defined previously" or "according to the architecture doc." Include the needed explanation here, even if you repeat yourself.

Avoid common failure modes. Do not rely on undefined jargon. Do not describe "the letter of a feature" so narrowly that the resulting code compiles but does nothing meaningful. Do not outsource key decisions to the reader. When ambiguity exists, resolve it in the plan itself and explain why you chose that path. Err on the side of over-explaining user-visible effects and under-specifying incidental implementation details.

Anchor the plan with observable outcomes. State what the user can do after implementation, the commands to run, and the outputs they should see. Acceptance should be phrased as behavior a human can verify ("after starting the server, navigating to [http://localhost:8080/health](http://localhost:8080/health) returns HTTP 200 with body OK") rather than internal attributes ("added a HealthCheck struct"). If a change is internal, explain how its impact can still be demonstrated (for example, by running tests that fail before and pass after, and by showing a scenario that uses the new behavior).

Specify repository context explicitly. Name files with full repository-relative paths, name functions and modules precisely, and describe where new files should be created. If touching multiple areas, include a short orientation paragraph that explains how those parts fit together so a novice can navigate confidently. When running commands, show the working directory and exact command line. When outcomes depend on environment, state the assumptions and provide alternatives when reasonable.

Be idempotent and safe. Write the steps so they can be run multiple times without causing damage or drift. If a step can fail halfway, include how to retry or adapt. If a migration or destructive operation is necessary, spell out backups or safe fallbacks. Prefer additive, testable changes that can be validated as you go.

Validation is not optional. Include instructions to run tests, to start the system if applicable, and to observe it doing something useful. Describe comprehensive testing for any new features or capabilities. Include expected outputs and error messages so a novice can tell success from failure. Where possible, show how to prove that the change is effective beyond compilation (for example, through a small end-to-end scenario, a CLI invocation, or an HTTP request/response transcript). State the exact test commands appropriate to the project’s toolchain and how to interpret their results.

Capture evidence. When your steps produce terminal output, short diffs, or logs, include them inside the single fenced block as indented examples. Keep them concise and focused on what proves success. If you need to include a patch, prefer file-scoped diffs or small excerpts that a reader can recreate by following your instructions rather than pasting large blobs.

## Living plans and design decisions

* ExecPlans are living documents. As you make key design decisions, update the plan to record both the decision and the thinking behind it. Record all decisions in the `Decision Log` section within EXECUTION.
* ExecPlans must contain and maintain a `TASKS` section, a `Surprises & Discoveries` section, a `Decision Log`, and an `Outcomes & Retrospective` section within EXECUTION. These are not optional.
* When you discover optimizer behavior, performance tradeoffs, unexpected bugs, or inverse/unapply semantics that shaped your approach, capture those observations in the `Surprises & Discoveries` section with short evidence snippets (test output is ideal).
* If you change course mid-implementation, document why in the `Decision Log` and reflect the implications in `TASKS` and `Next Steps`. Plans are guides for the next contributor as much as checklists for you.
* At completion of a major task or the full plan, write an `Outcomes & Retrospective` entry summarizing what was achieved, what remains, and lessons learned.

## Prototyping and parallel implementations

It is acceptable—-and often encouraged—-to include explicit prototyping phases when they de-risk a larger change. Examples: adding a low-level operator to a dependency to validate feasibility, or exploring two composition orders while measuring optimizer effects. Keep prototypes additive and testable. Clearly label the scope as "prototyping"; describe how to run and observe results; and state the criteria for promoting or discarding the prototype.

Prefer additive code changes followed by subtractions that keep tests passing. Parallel implementations (e.g., keeping an adapter alongside an older path during migration) are fine when they reduce risk or enable tests to continue passing during a large migration. Describe how to validate both paths and how to retire one safely with tests. When working with multiple new libraries or feature areas, consider creating spikes that evaluate the feasibility of these features _independently_ of one another, proving that the external library performs as expected and implements the features we need in isolation.

## ExecPlan Format (DESIGN/EXECUTION/TASKS)

For features requiring iterative autonomous execution with frequent context management, use this streamlined single-file format that separates stable design from dynamic execution state. This format optimizes for:

- **Surviving compaction**: Plan is external memory, not conversation context
- **Agent autonomy**: Minimal interruption during execution phase
- **Scannable progress**: Quick orientation without reading full prose
- **Clean git history**: Design stable, execution medium churn, tasks high churn

A single, stateless agent -- or a human novice -- can read your ExecPlan from top to bottom and produce a working, observable result. That is the bar: **SELF-CONTAINED, SELF-SUFFICIENT, NOVICE-GUIDING, OUTCOME-FOCUSED**.

### Source of Truth Priority

When exec plans exist in .ai/plans/:

- **ALWAYS treat them as source of truth** over conversation memory
- **When preparing to compact**: Update exec plan with current state first
- **When compacting**: Base summary on exec plan file, not conversation details
- **After compaction**: Check conversation summary for plan path, read that file, and resume autonomously
- **During execution**: Update plan frequently after every task completion, don't rely on conversation context
- **Output plan reference frequently**: After every task completion, output the plan file path so it survives summarization

### Format Overview

Each exec plan is a single .md file in .ai/plans/ with three major sections divided by H1 headers:

1. **DESIGN** - Stable comprehensive specification (updated only when design changes)
2. **EXECUTION** - Living log of decisions, discoveries, and context (updated as discoveries happen)
3. **TASKS** - Granular checklist with inline decision notes (updated after every task)

### Writing Style

Use hybrid prose/bullets approach to maximize both agent understanding and scannability:

**Use prose where it helps agent understand "why" and "flow":**
- Purpose / Big Picture (prose)
- Context & Orientation (prose for definitions, bullets for file lists)
- Plan of Work (prose narrative - helps agent see the big picture)

**Use bullets where agent needs to scan "what" and "how":**
- Concrete Steps (bullets)
- Interfaces & Dependencies (bullets with code examples)
- Validation (bullets)
- TASKS section (bullets/checklist)
- Next Steps (bullets)

### TodoWrite Integration

If using Claude Code: Automatically sync the TASKS section to TodoWrite for native todo UI tracking. When reading or updating the exec plan, populate TodoWrite from TASKS. When completing a task, update both exec plan TASKS and TodoWrite simultaneously. Keep both in sync throughout execution.

### Execution Behavior

**During DESIGN stage:**
- Agent asks clarifying questions
- Agent collaborates with user on design
- Agent may iterate multiple times
- Agent asks permission before proceeding to EXECUTION

**During EXECUTION stage:**
- Agent executes autonomously without interruption
- Agent does NOT ask "should I continue?" between tasks
- Agent does NOT ask "is this correct?" after each edit
- Agent updates TASKS after every completed task
- Agent outputs plan reference after every task
- Agent only stops when: all tasks complete, blocker encountered, or context approaching limit

**When context approaching limit:**
- Agent updates Next Steps with specific details
- Agent updates all completed tasks
- Agent outputs plan reference
- Agent continues working until hard limit (does not preemptively stop)

**After compaction:**
- Agent reads conversation summary for plan file path
- Agent reads the plan file (source of truth)
- Agent resumes from Next Steps
- Agent outputs: "Reading source of truth: [path]"

### Stage Transition Outputs

Output visual stage markers in chat (works across all LLM agents):

**Entering design:**
```
====================================
🎨 Entering DESIGN stage
====================================
```

**Entering execution:**
```
====================================
⚡ Entering EXECUTION stage
====================================

📋 Executing plan: .ai/plans/[feature-name].md
   This file is the SOURCE OF TRUTH for all context, decisions, and progress.
```

**After each task completion:**
```
✓ Task completed: [task name]
✓ TASKS updated (X completed, Y pending)
📋 Source of truth: .ai/plans/[feature-name].md
```

**When resuming after compaction:**
```
Reading source of truth: .ai/plans/[feature-name].md

Progress: X completed, Y pending
Resuming from: [next task]
```

<template>
# [Feature Name]

This ExecPlan follows .ai/plans/PLANS.md requirements and is a living document.

If using Claude Code, you can derive TodoWrite session state from TASKS section.

Last Updated: [YYYY-MM-DDTHH:MM:SSZ]

---

# DESIGN

## Purpose / Big Picture

Write 2-4 sentences explaining what the user can do after this change that they could not do before. Describe the observable outcome and how to demonstrate it working. Focus on user-visible value, not implementation details.

## Context & Orientation

Describe the current repository state relevant to this task. Define any technical terms in plain language. List key files with full repository-relative paths. Explain how the pieces fit together so a novice can navigate confidently. Do not assume prior knowledge.

Key files:
- [path/to/file.ext] - [purpose and role]
- [path/to/other.ext] - [purpose and role]

## Plan of Work

Write a prose narrative explaining the sequence of changes. Describe what will be edited or created and in what order. Keep it concrete but focus on the flow and reasoning, not every line of code. Help the agent understand the big picture and dependencies between steps.

## Concrete Steps

List the exact commands to run and where to run them. Show expected outputs so the reader can compare. Include test commands and how to verify each step worked.

- Step 1: [command]
  Expected: [output or behavior]

- Step 2: [command]
  Expected: [output or behavior]

## Interfaces & Dependencies

Specify the types, function signatures, libraries, and modules to use. Show code examples where helpful. Be prescriptive about naming and structure.

Dependencies:
- [library@version] - [why we're using it]

Key interfaces:

    interface ExampleInterface {
        method(param: Type): ReturnType;
    }

## Validation & Acceptance

Describe observable behavior that proves the feature works. Phrase as actions a human can take with expected results. Include test commands and criteria for success.

- Action: [what to do]
  Expected: [what should happen]

- Test: [command to run]
  Expected: [N tests pass, specific test names]

---

# EXECUTION

## Current Status

Write 2-3 sentences summarizing where we are in the implementation. What's been completed? What's currently being worked on? Any blockers or open questions?

## Decision Log

Record every decision made during implementation. Capture what was decided, why, when, and what was affected.

- **Decision:** [what was decided]
  **Rationale:** [why this choice was made, what alternatives were considered]
  **Date:** [YYYY-MM-DDTHH:MM:SSZ]
  **Files Affected:** [paths to files that implement this decision]

## Surprises & Discoveries

Document unexpected behaviors, bugs, performance characteristics, or insights discovered during implementation. Include evidence (error messages, test output, measurements).

- **Observation:** [what was discovered]
  **Evidence:** [error message, test output, or code snippet]
  **Date:** [YYYY-MM-DDTHH:MM:SSZ]
  **Resolution:** [how it was handled or what changed]

## Next Steps

List the immediate next actions to take. Be specific with file paths and line numbers where relevant. This section is critical for resuming after compaction.

- [Next immediate action with specific details]
- [Following action]

## Outcomes & Retrospective

(Leave empty until feature is complete or at major phases. Fill this when all tasks are done.)

At completion of the feature or at major phases, summarize what was achieved, what remains, and lessons learned. Compare the result against the original purpose stated in DESIGN.

- **What was delivered:** [Summary of completed functionality]
- **What remains:** [Known gaps or future enhancements]
- **Lessons learned:** [Insights for future work]
- **Comparison to original purpose:** [Did we achieve what we set out to do?]

---

# TASKS

## Completed

- [x] (YYYY-MM-DDTHH:MM:SSZ) [Task description]
  💡 Decision: [What approach was taken and why]
  📁 Files: [paths to files changed]

## In Progress

- [ ] [Task description] (started: YYYY-MM-DDTHH:MM:SSZ)
  - [x] [Completed subtask]
  - [ ] [Remaining subtask]

## Pending

- [ ] [Task description]
  - [ ] [Subtask]
  - [ ] [Subtask]
- [ ] [Next task]
</template>
