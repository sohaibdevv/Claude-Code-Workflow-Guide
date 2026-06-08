# Model Selection — Choosing the Right Model for the Task

Claude Code gives you access to multiple models. Picking the right one for each task is a meaningful optimization — both for output quality and for cost/speed.

---

## The Model Lineup (2026)

| Model | ID | Strength | Cost | Speed |
|---|---|---|---|---|
| **Opus 4.7** | `claude-opus-4-7` | Deepest reasoning, best for hard problems | High | Slower |
| **Sonnet 4.6** | `claude-sonnet-4-6` | Balanced — great code, good reasoning | Medium | Fast |
| **Haiku 4.5** | `claude-haiku-4-5-20251001` | Simple tasks, lookups, formatting | Low | Fastest |

---

## Model Selection Framework

```
Task Complexity
    │
    ├── Simple (lookup, rename, format)     → Haiku
    │
    ├── Medium (implement feature, fix bug) → Sonnet
    │
    └── Complex (architecture, security,   → Opus
               novel algorithm, hard debug)
```

Add a risk dimension:

```
                    LOW RISK                 HIGH RISK
                  (reversible,             (irreversible,
                   non-critical)           security, prod)
                ─────────────────────────────────────────
  SIMPLE TASK   │     Haiku          │     Sonnet        │
  ──────────────┼────────────────────┼───────────────────┤
  MEDIUM TASK   │     Sonnet         │     Sonnet/Opus   │
  ──────────────┼────────────────────┼───────────────────┤
  COMPLEX TASK  │     Sonnet         │     Opus          │
                ─────────────────────────────────────────
```

---

## When to Use Opus

Use Opus when the quality of the decision matters more than the speed or cost.

**Architecture decisions:**
- "Design the caching architecture for this high-traffic API"
- "Should we use event sourcing or traditional CRUD for this domain?"

**Security review:**
- "Review this auth implementation for vulnerabilities"
- "Analyze this SQL query for injection risks"

**Hard debugging:**
- Race conditions, memory leaks, heisenbug diagnosis
- When Sonnet has already tried and missed

**Complex refactoring:**
- Large-scale architectural changes
- Untangling deeply coupled legacy code

**Novel algorithms:**
- When the problem doesn't have an obvious off-the-shelf solution
- When correctness is critical and can't be easily tested

---

## When to Use Sonnet

Sonnet is your default workhorse. Use it for the majority of tasks.

- Implementing well-defined features
- Writing tests for existing code
- Fixing bugs with known root causes
- Code review
- Writing documentation
- Refactoring with clear objectives
- Building CRUD endpoints
- Migrations from known patterns

---

## When to Use Haiku

Haiku for tasks where speed matters more than depth.

- Symbol lookups: "Where is UserSession defined?"
- Quick format checks: "Is this JSON valid?"
- Simple transformations: "Convert this to TypeScript interface"
- Test file generation for boilerplate-heavy patterns
- Quick syntax questions

---

## Switching Models Mid-Session

You can switch models during a session without losing context:

```bash
# Switch to Opus for a hard problem
/model claude-opus-4-7

# Switch back to Sonnet for implementation
/model claude-sonnet-4-6
```

**Practical pattern:**
```
1. Start with Sonnet (fast, get oriented)
2. Hit a hard design decision → /model opus
3. Design decision made → /model sonnet
4. Implement with Sonnet
5. Final security review → /model opus
6. Ship
```

---

## Fast Mode

`/fast` toggles faster output mode. It doesn't downgrade the model — it optimizes for faster streaming.

Use it for:
- Long implementation sessions where you're grinding through code
- When you're in flow and don't need to read every word before Claude continues
- Iterative tasks where you'll review the final output anyway

Turn it off for:
- Complex reasoning tasks where you want to follow Claude's thinking
- Security or architecture reviews
- When you need to catch mistakes early in long responses

---

## Cost vs. Quality Trade-offs

Rough relative costs (token-for-token):
- Haiku: 1x
- Sonnet: ~15x
- Opus: ~75x

For a typical development session:
- If you use Sonnet for everything: reasonable cost, good quality
- If you use Opus for everything: expensive, overkill for most tasks
- If you use the right model for each task: 60-70% cheaper than all-Opus with similar quality on complex tasks

**The rule**: Don't default to Opus out of habit. Use it when you actually need it.

---

## Subagent Model Selection

When spawning subagents, specify the model based on the subagent's task:

```javascript
Agent({
  description: "Security audit",
  model: "opus",    // security needs deep reasoning
  prompt: "..."
})

Agent({
  description: "Find all test files",
  model: "haiku",   // simple search task
  prompt: "..."
})
```

The right model per subagent multiplies the efficiency gain of subagent isolation.
