# Context Management — The Complete Guide

Context is the most precious resource in Claude Code. Every character of every file you read, every bash output, every message in the conversation — it all counts against the context budget. Managing it well is the difference between a productive session and a degraded one.

---

## Understanding the Context Window

Think of context like RAM. You have a finite amount. When it fills up:
- Early content gets "compressed" or dropped
- Quality of responses starts declining
- Claude starts "forgetting" earlier decisions
- Instructions at the top of your session get deprioritized

The context window in Claude Code is large (200k tokens for Claude 3.5+), but it fills faster than you think once you start reading files and getting shell output.

---

## The Context Budget Allocation

```
Token budget breakdown during a typical session:
┌─────────────────────────────────────────────┐
│ System prompt + CLAUDE.md      ~10,000 tok  │
│ Conversation history           grows fast   │
│ File reads                     0-50,000 tok │
│ Bash outputs                   0-30,000 tok │
│ Available for reasoning        remaining    │
└─────────────────────────────────────────────┘
```

A single `npm install` output can be 5,000 tokens. Reading a large file can be 10,000. A test run output can be 20,000. It adds up.

---

## The 30% Rule

Keep context utilization below 30-40%. The colored indicator in Claude Code's status bar tells you:

- **Green**: healthy, full quality
- **Yellow**: degrading, consider compacting
- **Orange**: significant degradation, compact soon
- **Red**: critical, start a new session

Don't wait for red. Act at yellow.

---

## Rewind vs Correct

This is one of the most important habits to build.

**Wrong pattern:**
```
Claude makes a mistake →
You explain what's wrong →
Claude tries to correct →
Correction is imperfect →
You explain again →
Context balloons with failed attempts
```

**Right pattern:**
```
Claude makes a mistake →
Press ESC to stop →
/rewind to last clean state →
Re-issue with better instruction
```

Corrections pile on top of the mistake. Rewinding starts fresh. Always rewind.

---

## `/compact` Strategy

`/compact` summarizes prior conversation to free up context. But it's not magic — if you don't give it a hint, it may summarize away things you need.

**Effective compact usage:**
```bash
# Tell Claude what to preserve
/compact "keep: the schema design decisions we made, the file list we identified, the fact we're using optimistic locking"

# Tell Claude what to drop
/compact "drop the research phase discussion, keep only the final decisions"
```

When to compact:
- Before switching from planning to execution
- After completing a research phase
- When context hits 40%
- Before a long execution block (migrations, big refactors)

---

## Surgical File Reading

Every file read costs tokens. Read only what you need.

```
# Wasteful
"Read the entire auth module and tell me how sessions work"

# Surgical
"Read only src/auth/session.ts and find where session tokens are created"

# Even more surgical  
"In src/auth/session.ts, find and read only the createSession function"
```

When Claude does need to read large files, ask it to summarize the relevant parts rather than dump the full content into context.

---

## Bounding Bash Output

Bash commands can flood context with output you don't need.

```bash
# Unbounded — could be thousands of lines
npm install
npm test

# Bounded
npm install 2>&1 | tail -20
npm test 2>&1 | tail -50

# Status only
npm test > /dev/null 2>&1 && echo "PASS" || echo "FAIL"
```

For exploratory commands, always pipe through `head` or `tail`.

---

## Session Lifecycle Strategy

**Short tasks (< 30 min):**
- Single session, compact once if needed

**Medium tasks (30 min - 2 hours):**
- Compact between major phases
- Consider splitting at logical boundaries

**Long tasks (2+ hours):**
- Plan phase in session 1, save plan
- Execute phase in session 2 (load plan via CLAUDE.md or file)
- Review phase in session 3

**Multi-day work:**
- Use CLAUDE.md to persist cross-session context
- Use git commits to persist progress
- New session each day — don't resume stale sessions

---

## Context Preservation Techniques

**Use git as context storage:**
```bash
# Commit frequently during long tasks
# Each commit message = context you can re-read cheaply later
git commit -m "step 3/7: added UserSession type and createSession function"
```

**Use files as context:**
```bash
# Write decisions to a temp file
echo "Decision: using optimistic locking for inventory" >> /tmp/session-notes.md
# Read it in new sessions
cat /tmp/session-notes.md
```

**Use `/rename` and `/resume`:**
```bash
/rename auth-refactor-2026
# Later:
/resume auth-refactor-2026
```

---

## Signs of Context Degradation

Watch for these red flags:
- Claude contradicts decisions made earlier in the session
- Responses become vaguer and less specific
- Claude asks questions it already answered
- Code style suddenly shifts away from established patterns
- Instructions from early in the session are ignored

When you notice these: compact or start fresh. Don't push through.
