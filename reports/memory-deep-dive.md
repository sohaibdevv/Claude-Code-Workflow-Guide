# Memory System Deep Dive — How It Works and How to Use It Effectively

---

## Overview

Claude Code's memory system is a file-based persistent knowledge store that allows Claude to accumulate and recall information across sessions. Unlike the conversation context window (which resets each session), memory persists indefinitely.

The system is intentionally simple: it's just files in `~/.claude/projects/<project-slug>/memory/` that you control completely.

---

## Technical Architecture

### File Structure

```
~/.claude/
└── projects/
    └── -Users-vignesh-my-project/    ← slugified absolute path
        └── memory/
            ├── MEMORY.md              ← index (always loaded)
            ├── user_profile.md
            ├── feedback_style.md
            ├── project_decisions.md
            └── reference_systems.md
```

### How Memory Is Loaded

1. At session start, Claude loads `MEMORY.md` (the index)
2. During the session, Claude reads individual memory files when relevant
3. `MEMORY.md` has a ~200-line limit — entries beyond that are truncated

This means:
- Every session sees the index
- Individual memories are loaded on demand (doesn't bloat context upfront)
- Old/stale memories in the index will still affect behavior

### Memory File Format

```markdown
---
name: feedback-response-style
description: How to format responses — no trailing summaries, no narration
metadata:
  type: feedback
---

[Memory content here]

**Why**: [Reason this was established]
**How to apply**: [When/where this guidance kicks in]
```

The `description` field is used to determine relevance. Write it as a retrieval query: "What would I search for when I need this?"

---

## What Makes a Good Memory

### The Non-Obvious Test

Before saving a memory, ask: "Could a future Claude session derive this by reading the codebase or asking me?"

If yes → don't save it (it's redundant).
If no → save it (it's genuinely valuable persistent knowledge).

**Bad memory** (derivable from codebase):
```
project uses PostgreSQL
```
A future Claude can read package.json and know this.

**Good memory** (non-obvious, contextual):
```
We evaluated MySQL but chose PostgreSQL specifically for its JSON column support
for the dynamic pricing rules. Don't suggest switching databases.
```
A future Claude can't derive the decision rationale or the constraint.

---

## The Four Memory Types in Practice

### User Memories — Build a developer profile

The goal: future sessions work with a complete picture of who you are.

```markdown
---
name: developer-context
description: Vignesh's technical background, current expertise areas, learning goals
metadata:
  type: user
---

Full-stack developer (5+ years TypeScript/Node, 2+ years React).
Strong on backend systems and databases, newer to DevOps/Kubernetes.
Currently learning Rust — frame Rust explanations in terms of TypeScript analogues.
Prefers functional programming patterns. Doesn't like OOP class hierarchies.
Works solo on side projects, leads a team of 3 on day job.
```

### Feedback Memories — Capture corrections AND confirmations

Most engineers only save corrections. Don't miss confirmations — they're equally valuable.

```markdown
---
name: feedback-commit-style
description: How to write commit messages — no co-author line, conventional commits format
metadata:
  type: feedback
---

Commit messages: use conventional commits (feat:, fix:, chore:, etc.)
Do NOT add "Co-Authored-By: Claude" lines — commits show only the developer's name.
Keep subject line under 72 chars. No period at the end.

**Why**: User explicitly prefers clean git history attributable to them only.
**How to apply**: All commits, always.
```

```markdown
---
name: feedback-validated-bundled-prs
description: For this project, bundled PRs are preferred over many small ones
metadata:
  type: feedback
---

For refactors and related changes in this project, bundle into one PR rather than
splitting into many small ones. Confirmed as right approach after choosing to 
bundle auth + session cleanup into one PR.

**Why**: Small team, splitting creates unnecessary coordination overhead.
**How to apply**: When deciding PR scope for refactors/cleanup, lean toward bundling.
```

### Project Memories — Track evolving state

```markdown
---
name: project-sprint-may-2026
description: Current sprint goals and status for e-commerce platform (May 2026)
metadata:
  type: project
---

Current sprint (ends 2026-05-20):
- ✅ Payment method CRUD
- 🔄 Checkout flow (in progress)  
- ⏳ Order confirmation emails (not started)

**Why**: Keeps Claude focused on sprint goals when proposing new work.
**How to apply**: If user asks about unrelated features, note we're mid-sprint.
```

### Reference Memories — External system pointers

```markdown
---
name: reference-monitoring
description: Where monitoring dashboards and logs live for this project
metadata:
  type: reference
---

Production monitoring:
- Grafana: grafana.internal/d/api-latency (primary oncall dashboard)
- Datadog: service:api env:prod (log queries)
- Sentry: sentry.io/organizations/myorg/issues/?project=api

Staging: staging.myapp.com (resets nightly at 2am UTC from prod snapshot)
CI: github.com/myorg/myapp/actions

**Why**: Prevents needing to re-explain where things are each session.
**How to apply**: When debugging or monitoring discussions arise.
```

---

## Memory Maintenance Lifecycle

```
Create memory → Use in sessions → Update when outdated → Delete when irrelevant
```

**Signs a memory needs updating**:
- It references a file path that no longer exists
- It describes an approach that's been replaced
- The dates are more than 3 months old for fast-moving project context

**Signs a memory should be deleted**:
- It's contradicted by the current code
- The project context it describes is complete/finished
- The preference it captures has reversed

**Monthly memory audit**:
1. Read all memories in MEMORY.md index
2. For each: is it still true? Is it still relevant?
3. Update stale ones, delete irrelevant ones
4. Keep the index under 200 lines

---

## Memory Anti-Patterns

**The code snapshot**: Saving a summary of current architecture or file structure. The codebase changes; the snapshot becomes outdated and misleading. Use `git log` for history.

**The task list**: Saving "we still need to implement X, Y, Z." Use your project management tool for this. Memory is for context, not tasks.

**The preference without a why**: "User prefers Jest" without explaining why. When an exception comes up, you don't know if the preference applies. Always include **Why** and **How to apply**.

**The giant memory**: Saving a 500-word memory when 50 words would do. Longer memories dilute the signal and consume more context when loaded.
