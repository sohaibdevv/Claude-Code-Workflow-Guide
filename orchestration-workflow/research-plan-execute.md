# Research → Plan → Execute → Review → Ship

The gold-standard workflow for any significant feature. Five distinct phases with clear handoffs.

---

## Phase Overview

```
RESEARCH          PLAN            EXECUTE          REVIEW           SHIP
────────────    ────────────    ────────────    ────────────    ────────────
Understand      Design the      Implement       Verify          Deploy
the problem     solution        it              quality         it
────────────    ────────────    ────────────    ────────────    ────────────
Subagent        Plan mode       Iterative       Subagent        /ship
explores        + approval      coding          reviews         command
codebase        gate            + tests         diff
```

---

## Phase 1: Research

**Goal**: Understand the current state before proposing changes.

**Trigger phrase**: "Before we start, let's understand what we're working with."

**Subagent prompt template**:
```markdown
Research task: [describe the area to explore]

1. Find all files related to [topic] — list with file paths
2. Describe the current architecture/approach
3. Identify the key functions/classes involved (with file:line references)
4. Find any existing tests for this area
5. Note any gotchas, non-obvious dependencies, or known issues

Read-only. Do not modify any files.

Return a structured report I can use to plan the implementation.
```

**Output**: A research report summarizing current state, relevant files, and integration points.

**Time budget**: 10-20% of total task time.

---

## Phase 2: Plan

**Goal**: Design the solution with full awareness of what exists.

**Trigger phrase**: "Based on the research, let's plan before coding."

**Enter plan mode**: `/plan` or `Shift+Tab`

**Plan must include**:
1. Goal restatement (confirm understanding)
2. Affected files (explicit list)
3. Step-by-step implementation with specifics
4. Test strategy
5. Irreversible steps identified
6. Rollback approach

**Approval gate**: Don't proceed until you've:
- Read the full plan
- Pushed back on any questionable decisions
- Confirmed the scope is right
- Verified no unexpected files are in the blast radius

**Time budget**: 15-25% of total task time.

---

## Phase 3: Execute

**Goal**: Implement the approved plan.

**Trigger phrase**: "Plan approved. Proceed with step 1."

**Execution rules**:
- One step at a time
- Run tests after each significant change
- Pause at checkpoints identified in the plan
- Show diffs at key decision points

**Mid-execution pattern**:
```
Execute step N →
Review diff →
Run tests →
Confirm before next step (if checkpoint)
```

**When to stop and re-plan**:
- Unexpected complexity discovered mid-implementation
- A step reveals new information that changes the approach
- Tests fail in ways that weren't anticipated

**Time budget**: 50-60% of total task time.

---

## Phase 4: Review

**Goal**: Verify the implementation meets quality standards before shipping.

**Trigger phrase**: "Implementation complete. Let's review before shipping."

**Review subagent**:
```markdown
Review the changes in this diff: [diff or branch name]

Check for:
1. Correctness — does it do what was specified?
2. Edge cases — are they handled?
3. Security — any vulnerabilities?
4. Tests — are they adequate?
5. Code quality — readable, maintainable?

Format findings as:
[SEVERITY] file:line — issue — suggestion
```

**Self-review checklist**:
- No debug code left in
- No hardcoded values
- No TODO comments that should be resolved
- Tests cover the main cases and edge cases

**Time budget**: 10-15% of total task time.

---

## Phase 5: Ship

**Goal**: Deploy with confidence.

**Trigger**: `/ship` command

**The /ship command handles**:
1. Final lint + typecheck + test run
2. Security scan of changed files
3. PR creation with full description
4. Deployment (if automated)

---

## When to Compress the Workflow

Not every task needs all five phases at full depth:

| Task Size | Research | Plan | Execute | Review | Ship |
|---|---|---|---|---|---|
| Large feature (1+ week) | Full | Full | Iterative | Full | Full |
| Medium feature (days) | Brief | Required | With tests | Quick | Full |
| Small bug fix (hours) | Quick look | Informal | Direct | Self-review | Full |
| Typo/trivial fix | Skip | Skip | Direct | Skip | `/ship` |

The key principle: phases can be abbreviated but shouldn't be skipped entirely for anything that touches production.
