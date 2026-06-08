# Boris Cherny's Production Workflow

Boris Cherny is the creator of Claude Code at Anthropic. This is how he actually uses it day-to-day — sourced directly from his public tips (Feb–Apr 2026).

---

## The Core Philosophy

> "Give Claude verification mechanisms. That's probably the most important thing. Testing improves final output quality by 2–3x."

Boris's entire workflow is built around one insight: **Claude performs dramatically better when it can verify its own work.** Not just running tests — systematic verification at every stage.

---

## The 5+5 Parallel Setup

Boris runs **5 Claude sessions locally** and **5–10 additional sessions on claude.ai/code** simultaneously.

```
Local terminal sessions (5 worktrees):
├── Session 1: Feature A  (git worktree)
├── Session 2: Feature B  (git worktree)
├── Session 3: Bug fixes  (git worktree)
├── Session 4: Tests      (git worktree)
└── Session 5: Infra work (git worktree)

Cloud sessions (claude.ai/code, 5-10):
├── Long-running research tasks
├── PR reviews
├── Documentation generation
└── Background refactors
```

**Why this works**: Each session has a fresh context window, a clean context, and a specific mandate. No session is contaminated by another's work.

---

## Model Selection (Boris's exact choice)

**Opus 4.7 with extended thinking, for coding.**

Counterintuitive: Opus is "larger and slower initially" but Boris found it:
- Requires significantly less steering (fewer corrections)
- Excels at tool use (bash, file editing)
- Completes tasks in fewer turns
- Ultimately faster end-to-end despite slower individual responses

**The rule**: Don't optimize for token speed. Optimize for task completion speed. A slower model that gets it right on turn 2 beats a fast model that needs 8 correction turns.

---

## Plan Mode (Boris's workflow)

Boris starts **every non-trivial task in Plan Mode**.

```
1. Enter plan mode: Shift+Tab
2. Describe the goal + constraints
3. Let Claude reason through the approach
4. Review the plan — push back, refine
5. Approve the plan
6. Exit plan mode — Claude executes autonomously
```

**The key**: Once the plan is approved, let Claude execute with minimal interruption. The plan phase absorbs the steering cost. The execution phase should be largely autonomous.

---

## Verification Loops (Boris's #1 tip)

This is the single most impactful technique Boris shares. See [verification-loop.md](verification-loop.md) for the full guide.

The short version:
```bash
# Instead of: implement → review manually
# Do: implement → auto-verify → fix → auto-verify → done
```

Configure hooks that run tests automatically after every edit. Claude sees the test results and self-corrects. Output quality improves 2–3x.

---

## The Shared CLAUDE.md Pattern

Boris keeps CLAUDE.md in version control with the team.

**The critical practice**: After every session where Claude makes a mistake, add a rule to CLAUDE.md preventing that mistake in the future.

```
# Bad session: Claude keeps adding unnecessary console.logs
→ Add to CLAUDE.md: "NEVER add console.log debugging. Use the logger at src/lib/logger.ts"

# Bad session: Claude keeps creating separate files for utilities
→ Add to CLAUDE.md: "Utility functions go in the nearest existing utils.ts, not new files"
```

This turns every mistake into a permanent improvement. CLAUDE.md gets better with every session.

---

## Slash Commands and Agents in `.claude/`

Boris stores all reusable workflows in `.claude/commands/` and `.claude/agents/`, committed to git.

The principle: **"If you've typed it more than once, it should be a command."**

Examples from Boris's setup:
- `/verify` — run the full test + lint + type check pipeline
- `/babysit-prs` — automated PR review and merge checking
- `/batch-migrate` — distribute a migration across worktrees
- `/voice` — enable voice dictation mode

---

## Voice-First Development

Boris primarily codes **via speech** rather than typing.

Why this matters for prompt quality:
- Spoken prompts are naturally more detailed (easier to talk than type)
- More context = better output
- Faster iteration on complex prompts

```bash
# Enable voice mode
/voice

# Speak your prompt instead of typing it
# "Refactor the authentication middleware to use the new JWT library,
#  make sure to handle token expiry edge cases, and update the tests.
#  Follow the pattern in src/auth/session.ts."
```

Voice naturally forces you to include the WHY (you'd feel odd saying "refactor auth" out loud without explaining why). Better prompts, less back-and-forth.

---

## Mobile Development

Boris reviews and makes code changes from his phone using the iOS/Android app.

**Practical mobile workflow**:
- Review PRs on mobile during commute
- Approve/reject plans while away from desk
- Quick bug investigations
- Check on running agent sessions

Not for heavy coding — for staying unblocked when away from your machine.

---

## The `/loop` Pattern

For automated, repeating tasks:

```bash
# Check PRs every 5 minutes and handle routine tasks
/loop 5m /babysit-prs

# Run daily code quality check
/loop 1d /audit

# Keep watching a failing test
/loop 30s "run the failing test and try to fix it if it fails"
```

`/loop` + `/babysit-prs` is Boris's way of handling PR queue management without manual attention.

---

## The `--bare` Performance Optimization

```bash
# Standard startup (normal speed)
claude

# Bare startup (up to 10x faster SDK startup)
claude --bare
```

Use `--bare` for scripted/automated Claude Code invocations where you don't need the full interactive UI. Significant speedup for CI pipelines and hook scripts.

---

## Cross-Device Sessions

```bash
# Start a session on your desktop
# Get the session ID
/rename my-feature-session

# Continue from another device or terminal
/remote-control
# or
/teleport my-feature-session
```

Long-running tasks started on your desktop can be monitored or continued from any device.
