# Context Rot — Understanding and Preventing Quality Degradation

Thariq from Anthropic's Claude Code team introduced the concept of **context rot**: the gradual degradation of Claude's output quality as the context window fills up.

---

## What Is Context Rot?

Even with Claude's 1M token context window, quality degrades before you run out of space.

**Thariq's observation**: Context rot typically starts around 300–400k tokens.

Why it happens: as the context grows, Claude's attention spreads across more tokens. Earlier context gets less "weight" in the model's processing. Important instructions from the start of the session get diluted by everything that came after.

Symptoms:
- Claude ignores rules you stated at the start of the session
- Responses become more generic
- Code style drifts from the established pattern
- Claude asks questions it already answered
- Contradictions with earlier decisions

**Key insight from Thariq**: *"Just because your model hasn't run out of context, it doesn't mean you shouldn't start a new session."*

---

## The 5 Decision Points After Each Turn

After every response from Claude, you have 5 choices. Knowing which to pick is the skill.

```
                    Claude responds
                          │
         ┌────────────────┼────────────────────────┐
         ▼                ▼                ▼        ▼        ▼
     CONTINUE         REWIND           /COMPACT   /CLEAR  SUBAGENT
   (everything      (undo last       (summarize) (fresh  (delegate
    is fine)         turn, retry)     in place)   start)  and isolate)
```

### 1. Continue
Use when: output was correct, context is healthy (< 40%), no drift.

### 2. Rewind
Use when: Claude made a mistake and you want to try a different approach.

**Rewind vs. correction**: This is critical.

```
CORRECTION (bad):
"Actually that's wrong, you should have..."
→ Adds more context on top of the mistake
→ Claude tries to reconcile the mistake with your correction
→ Context grows, confusion grows

REWIND (good):
Press ESC → /rewind
→ Returns to before the mistake
→ Re-prompt with better instruction
→ Clean slate for that step
```

**Thariq's rule**: *"Instead of typing corrections after failed attempts, jump back to before the error and re-prompt with the insights you gained."*

### 3. /compact
Use when: context is filling up (40–60%) but you're mid-task and want to maintain momentum.

```bash
# Without hint (Claude guesses what to keep):
/compact

# With hint (Claude knows what's important):
/compact "keep: the schema design, the auth approach we chose, the file list. 
          drop: all the research phase discussion."
```

`/compact` summarizes prior conversation in place. You stay in the session but with a smaller footprint. **Claude decides what to summarize** — so the hint matters.

### 4. /clear
Use when: you're about to start a new phase and you want to control exactly what carries forward.

```bash
/clear
# Then re-establish context manually:
"We just completed phase 1: [summary]. 
Phase 2 goal: [goal]. 
Key decisions made: [decisions].
Files modified: [list].
Now: [next task]"
```

`/clear` gives you complete control over what the fresh session knows. More work than `/compact`, but better for high-stakes transitions.

### 5. Subagents
Use when: you need something done but don't want the exploration/research polluting your main context.

**Thariq's framing**: Subagents *"garbage-collect exploration noise automatically."* When a subagent finishes, its full working context is discarded. Only the result comes back to you.

---

## Context Budget by Task Type

How much context budget to allocate:

```
Simple bug fix:
├── Problem description: 1k tokens
├── Relevant files: 5-10k tokens
├── Solution: 2-5k tokens
└── Total: ~20k tokens (well under rot threshold)

Medium feature:
├── CLAUDE.md: 5k tokens
├── Research phase: 20-30k tokens  ← compact after this
├── Planning: 10k tokens
├── Implementation: 30-50k tokens
└── Total: ~70-100k tokens (need to manage)

Large feature / multi-day:
├── Use separate sessions per phase
├── Compact or clear between phases
├── Don't try to fit in one session
└── Target: < 100k per session
```

---

## Context Rot Detection

Watch for these signals in real-time:

| Signal | Severity | Action |
|---|---|---|
| Response slower than usual | Low | Monitor |
| Generic answers where specific expected | Medium | Compact |
| Ignoring CLAUDE.md rules stated earlier | High | Compact or clear |
| Contradicting prior decisions | High | Clear |
| Context bar is yellow | Medium | Compact soon |
| Context bar is orange | High | Compact now |
| Context bar is red | Critical | Clear + start fresh |

---

## Prevention Strategies

### Strategy 1: Compact at Phase Transitions
```
Research phase ends → /compact before planning
Planning phase ends → /compact before execution
```

### Strategy 2: Surgical File Reading
Every file read adds to context. Read only what you need:
```
"Read only the createOrder function in src/orders.ts, not the whole file"
```

### Strategy 3: Bound Bash Output
```bash
# Context bomb: could be 10k+ tokens
npm test

# Bounded: max 20 lines
npm test 2>&1 | tail -20

# Result-only: 1 line
npm test > /dev/null 2>&1 && echo "PASS" || echo "FAIL"
```

### Strategy 4: Session-Per-Phase
For features spanning multiple days, use separate sessions with a handoff document:

```bash
# End of day 1 session:
# Ask Claude to write a handoff note
"Write a handoff note for tomorrow's session. Include:
- What was accomplished
- Current state of each file we touched
- Key decisions made and why
- Exact next steps
- Any blockers"

# Save it
claude > /tmp/handoff-day1.md

# Start of day 2 session:
"Read /tmp/handoff-day1.md and orient yourself on where we are"
```

### Strategy 5: Subagent for Research
Never do open-ended research in your main session. Always isolate it:

```
Main session: planning + execution (stays clean)
Research subagent: reads 30+ files (context discarded after)
```

---

## The Compact vs. Clear Decision

```
Is the task still in progress?
├── YES: Use /compact (maintains momentum)
└── NO (phase transition, or context is bad):
    ├── Is context quality still good?
    │   ├── YES: /compact with good hints
    │   └── NO (rot detected): /clear + manual re-briefing
    └── Starting completely new concern:
        Always /clear
```

When in doubt: start fresh. The cost of re-establishing context (2-3 minutes) is almost always less than the cost of working with degraded context (poor output quality for the rest of the session).
