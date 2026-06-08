# Agent Teams Report — Real-World Multi-Agent Patterns

---

## When Agent Teams Make Sense

Multi-agent teams are not a silver bullet. They add overhead (coordination, context setup, potential conflicts). They're worth it when:

1. **Tasks are genuinely parallelizable** — no shared state, no sequential dependencies
2. **Each task justifies a fresh context** — the isolation benefit outweighs the setup cost
3. **The total work is significant** — parallelizing a 10-minute task is rarely worth it; parallelizing a 10-hour task often is

For most day-to-day work, a single focused session is faster than a multi-agent setup.

---

## Validated Patterns

### Pattern 1: Research Isolation

**Scenario**: Before implementing a complex feature, you need to understand a large codebase area you haven't touched.

**Setup**:
```
Main session: planning context (stays clean)
Research agent: reads 20+ files, explores architecture
```

**Result**: The research agent can read everything needed without polluting your planning context with file contents. It returns a structured 1-page summary. Your planning session has clean context to reason about the design.

**ROI**: High. Research can consume 30-50k tokens of context. Isolating it preserves the main session quality for the more valuable planning and execution phases.

---

### Pattern 2: Parallel Module Development

**Scenario**: Sprint with 3 independent features needed by end of week.

**Setup**:
```bash
git worktree add ../sprint-auth -b sprint/auth
git worktree add ../sprint-ui -b sprint/ui
git worktree add ../sprint-api -b sprint/api
```

Three agents work simultaneously. Merge at end of sprint.

**Works well when**:
- Modules are in different directories
- No shared types modified
- No shared database tables modified
- Integration happens at a well-defined interface

**Fails when**:
- Both agents need to modify shared types
- Features depend on each other's output
- The codebase has poor module boundaries

**ROI**: High for greenfield modules with clear separation. Low for tightly coupled codebases.

---

### Pattern 3: Specialist Review

**Scenario**: Code written by one agent (or by you) needs review before merging.

**Setup**:
```
Writing agent: implements the feature, focused on correctness
Review agent:  fresh context, focused on quality, security, patterns
```

The review agent starts with no knowledge of how the implementation was arrived at. This simulates what a real code reviewer experiences — they see the output, not the process.

**Finding**: Fresh-context review catches more issues than same-context review. When Claude writes code and then reviews it in the same session, it's influenced by its own reasoning. A fresh agent isn't.

---

### Pattern 4: Incremental Complexity

**Scenario**: A large feature with 5+ sequential phases, each building on the last.

**Setup**: Not parallel — sequential, but each phase in its own session.

```
Session 1: Research + Plan → output: approved_plan.md
Session 2: Core data model → reads approved_plan.md, commits work
Session 3: Business logic → reads approved_plan.md + git log, builds on session 2
Session 4: API layer → builds on session 3
Session 5: Tests + Review → reviews all of sessions 2-4
```

Each session starts fresh, reads the plan + git log for context. Context stays clean per session.

**ROI**: High for long-running features (days+). Prevents context degradation across the full feature.

---

## Failure Modes and Lessons

### Failure: Agents modify shared files

**What happened**: Two parallel agents both needed to modify `src/types/user.ts`. Both modified it independently. Merge conflict that neither agent's context could resolve correctly.

**Lesson**: Before launching parallel agents, explicitly check which files each will touch. Any shared file → serialize those changes, don't parallelize.

**Prevention**: In agent prompts, include "If you discover you need to modify [shared files list], STOP and report back instead of making the change."

---

### Failure: Context didn't transfer correctly

**What happened**: Research agent returned findings, but the prompt for the planning agent didn't include enough of those findings. The plan had gaps that research had actually answered.

**Lesson**: Structured handoffs are mandatory. Research agent returns JSON. Planning agent receives that JSON explicitly. Don't rely on summaries that might drop key details.

---

### Failure: Parallel agents diverged on patterns

**What happened**: Three parallel agents implementing different features each made slightly different choices for shared patterns (error handling format, response schema). Integration required harmonizing all three.

**Lesson**: Include a "pattern reference" in agent prompts: "Follow the pattern in [reference file] for error handling, response format, and logging." This locks pattern choices before divergence can happen.

---

## Cost-Benefit Analysis

A 3-agent parallel setup for a 6-hour feature:

| Without agents | With agents |
|---|---|
| 1 session, 6 hours | 3 parallel sessions, 2 hours |
| 1 context (can get noisy) | 3 fresh contexts |
| Sequential implementation | Parallel implementation |
| ~1x cost | ~3x context cost (3 sessions) |

**Net result**: 4 hours saved, 3x the token cost. For expensive models (Opus), evaluate whether the time savings justifies the cost. For Sonnet, almost always worth it.

For daily small tasks (< 1 hour): not worth the multi-agent overhead. For weekly large features (> 4 hours): almost always worth it.
