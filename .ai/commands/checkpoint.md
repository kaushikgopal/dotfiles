# Command to create a checkpoint for any AI coding agent so you can resume later
name = "checkpoint"
description = "Create a checkpoint capturing current conversation state and context to resume work later"
prompt = """
# Checkpoint Command

**IMMEDIATE ACTION**: Determine the checkpoint operation based on user command.

## Operation Detection

### If command contains "review":
1. Find most recent checkpoint file in `.ai/checkpoints/`
2. Read the checkpoint and provide a concise summary:
   - Original request (1 sentence)
   - What was accomplished (bullet points, max 5)
   - Current blockers if any
   - Next immediate steps (max 3)
3. Keep summary under 10 lines total
4. End with: "Full checkpoint available at: [filepath]"

### If command contains "update":
1. Look for existing checkpoint files in `.ai/checkpoints/`
2. If multiple files exist, ask: "Which checkpoint should I update?" and list options
3. If only one exists, update that file
4. If none exist, create new checkpoint
5. For UPDATE operations:
   - Append new progress to existing sections
   - Update "Last Activity" timestamp
   - Move completed items from "In Progress" to "Completed"
   - Add new errors/blockers
   - Update "Next Steps" based on current state
   - Preserve original request and earlier context
   - Add separator: `---\n## Update: [timestamp]\n---`

### DEFAULT - Create New Checkpoint:
**This is the primary operation - DO NOT dilute or complicate this flow**

Create file `.ai/checkpoints/checkpoint-[timestamp].md` with the following analysis. Execute immediately without asking for confirmation.

## Step 1: Capture Current State (DO THIS FIRST)
- Run `git status` and `git diff --stat` to capture uncommitted changes
- Check for any active TODOs using available task tracking
- Note current directory and git branch
- Capture any error messages or failures from recent commands in this session

## Step 2: Analyze & Document

Create a markdown checkpoint with these sections:

### Session Context
**Original Request**: [Extract the user's initial ask/problem from this conversation]
**Current Objective**: [What we're trying to achieve right now]
**Session Start**: [Timestamp when work began]
**Last Activity**: [Most recent action taken]

### Progress Summary
**Completed**:
- [List what's been successfully done with file:line references]
- [Include specific functions/features implemented]
- [Note any successful tests or validations]

**In Progress**:
- [Current task being worked on]
- [Last command or edit attempted]
- [What was expected vs what happened]

**Blocked/Failed**:
- [What didn't work and why]
- [Include actual error messages with full context]
- [Note any unexpected behaviors]

### Code Changes
**Modified Files**: 
```
[git status output showing all changes]
```

**Key Implementation Details**:
- [Critical code sections added/modified with file:line references]
- [Design decisions made and why]
- [Architectural patterns followed]

### Conversation Highlights
**Important Decisions**:
- [Key choices made during this session]
- [Tradeoffs discussed]

**User Preferences**:
- [Any specific requirements or constraints mentioned]
- [Coding style preferences observed]

### Next Steps
**Immediate** (next 1-3 actions):
1. [Specific next action with exact command/edit]
2. [Following action]
3. [Third action if applicable]

**Remaining Tasks**:
- [What's left to complete the original request]
- [Any deferred improvements or optimizations]

**Open Questions**:
- [Decisions needing user input]
- [Ambiguities to clarify]
- [Technical uncertainties]

### Quick Resume Commands
```bash
# Get back to exact working state
cd [working directory]
git checkout [branch]
git status  # Verify state matches checkpoint

# If there were uncommitted changes:
[commands to recreate any temp files or state]

# Continue with next immediate action:
[exact command for next step]
```

### Key Code Snippets
Include 2-3 most relevant code sections from current work:

```[language]
// File: [path:line]
[code snippet showing important implementation]
```

### Error Context (if applicable)
**Last Error**:
```
[Full error message and stack trace]
```
**Error Location**: [file:line where error occurred]
**Attempted Fix**: [What was tried to resolve it]

### Environment State
- **Working Directory**: [pwd output]
- **Branch**: [current git branch]
- **Modified Files**: [count and list]
- **Tests Status**: [passing/failing if tests were run]
- **Dependencies**: [any new packages added]

## Step 3: Save Checkpoint
- Generate timestamp: `YYYYMMDD-HHMMSS`
- If working on specific feature/bug: save as `checkpoint-[feature-name]-[timestamp].md`
- Otherwise: save as `checkpoint-[timestamp].md`
- Create `.ai/checkpoints/` directory if it doesn't exist
- Save file and confirm location to user

## Important Instructions
1. Extract ALL context from our current conversation - don't ask what to include
2. Include actual code snippets, not just descriptions
3. Capture exact error messages, not summaries
4. Make the checkpoint immediately actionable - someone should be able to run the resume commands and continue
5. Focus on the current work session, not theoretical codebase analysis
6. Be specific with line numbers, file paths, and function names
7. Include enough context that you or another AI can resume in days/weeks

## Update Mode Instructions
When updating an existing checkpoint:
1. Read the entire existing checkpoint first
2. Preserve the original "Session Context" section
3. Append new progress with clear timestamps
4. Consolidate "Completed" items (remove duplicates)
5. Update "In Progress" to reflect current state
6. Keep historical error context but mark resolved ones
7. Update resume commands to latest state
8. Add update summary at the top of the update section:
   ```
   ### Update Summary
   - Time since last checkpoint: [duration]
   - New tasks completed: [count]
   - New issues encountered: [count]
   - Current focus: [what's being worked on now]
   ```

## Command Variants
- `/checkpoint` - Create new checkpoint file (DEFAULT - most common operation)
- `/checkpoint review` - Get concise summary of most recent checkpoint
- `/checkpoint update` - Update most recent or single existing checkpoint
- `/checkpoint update [filename]` - Update specific checkpoint file
- `/checkpoint new` - Force create new checkpoint even if one exists

This checkpoint should be superior to any compact summary - it should contain everything needed to resume work seamlessly.
"""
