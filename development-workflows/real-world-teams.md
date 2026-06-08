# Real-World Team Workflows — How Production Teams Ship with Claude Code

These are documented workflows from teams that have shipped production software using Claude Code. Each is adapted from public community contributions.

---

## 1. The Superpowers Workflow (188k★)

**Origin**: The most-starred Claude Code workflow in the community.

**Philosophy**: Claude does the implementation. You do the architecture and review. The dividing line is clear.

```
┌─────────────────────────────────────────────────────┐
│              SUPERPOWERS WORKFLOW                    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. BRAINSTORM (you + Claude, plan mode)            │
│     "What are 3 approaches to this feature?"        │
│     Choose one. Commit to it.                       │
│                                                     │
│  2. WORKTREES (isolate the work)                    │
│     git worktree add ../feature -b feature/name     │
│                                                     │
│  3. DETAILED PLAN (plan mode, 15 min)               │
│     File-level plan with checkpoints                │
│                                                     │
│  4. SUBAGENT IMPLEMENTATION                         │
│     Spawn impl agent with the approved plan         │
│     Agent implements + runs tests                   │
│                                                     │
│  5. HUMAN REVIEW (you)                              │
│     Review the diff. Not the process, the output.  │
│                                                     │
│  6. SUBAGENT FIX (if review has issues)             │
│     Spawn fix agent with specific issues list       │
│                                                     │
│  7. MERGE                                           │
│     PR → merge → clean up worktree                 │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Key insight**: Brainstorm sessions use expensive models + plan mode. Implementation uses Sonnet. You only spend Opus on decisions, not execution.

**In practice**:
```bash
# Step 1-3: Planning session
claude --model claude-opus-4-7
/plan "implement user notification system"
# ... approve the plan ...

# Step 4: Implementation subagent
# (done automatically by the /plan command's approved output)
# Agent runs in the worktree

# Step 5: Your review
git -C ../feature diff main..HEAD | claude "review this diff for issues"

# Step 7: Merge
gh pr merge --squash
git worktree remove ../feature
```

---

## 2. The BMAD Method (Product → Production)

**Origin**: A product-first methodology that treats Claude as a full development team.

**Philosophy**: Product clarity drives code quality. Vague specs produce vague code.

```
Phase 1: PRODUCT BRIEF
  User: "I need a feature for X"
  Claude (Product Mode): "Here's a product brief: [users, problem, solution, metrics]"
  You: Approve or iterate

Phase 2: PRD (Product Requirements Document)
  Claude: Generates full PRD from brief
  You: Review, add constraints

Phase 3: ARCHITECTURE
  Claude (Architect Mode): Proposes technical approach
  You: Approve design

Phase 4: EPIC BREAKDOWN
  Claude: Breaks PRD into 3-5 epics
  You: Prioritize, define MVP

Phase 5: SPRINT PLANNING
  Claude: Breaks epic into 1-3 day tasks
  You: Assign, adjust

Phase 6: IMPLEMENTATION
  Claude: Codes each task using TDD
  You: Review PR per task

Phase 7: CODE REVIEW
  Claude (Reviewer Mode): Comprehensive review
  You: Final approval

Phase 8: RETROSPECTIVE
  Claude: "What did we learn? What should change in CLAUDE.md?"
  You: Update standards
```

**Commands for BMAD**:
```bash
/brief "feature idea"      # → product brief
/prd                       # → PRD from brief
/architect                 # → technical approach
/epics                     # → break into epics
/sprint                    # → sprint tasks
/implement [task]          # → code the task
/retro                     # → retrospective
```

---

## 3. The gstack Workflow (14-Stage Enterprise Flow)

**Origin**: A startup team shipping production features with a structured 14-stage process.

**Philosophy**: Nothing ships without passing through quality gates. Automation handles the mechanical parts.

```
Stage 1:  OFFICE HOURS     — weekly sync to choose next feature
Stage 2:  CEO REVIEW       — 1-line feature description approved
Stage 3:  ENGINEERING REVIEW — technical feasibility check
Stage 4:  DESIGN REVIEW    — UX/UI spec approved
Stage 5:  SPEC             — detailed spec written
Stage 6:  PLAN             — implementation plan approved
Stage 7:  CODE             — implementation (TDD)
Stage 8:  SELF REVIEW      — /review command, fix issues
Stage 9:  QA               — manual QA against spec
Stage 10: SECURITY         — /audit command
Stage 11: PERFORMANCE      — load test for user-facing features
Stage 12: STAGING          — deploy to staging, verify
Stage 13: PRODUCTION       — deploy with monitoring
Stage 14: METRICS          — verify feature metrics after 1 week
```

**What makes this powerful**: Each stage is a command or checklist that Claude can run. The process is encoded in `.claude/commands/`, not just in a Google Doc.

```bash
# Most stages map to a command:
/spec "feature"      # Stage 5
/plan                # Stage 6
# (code)             # Stage 7
/review              # Stage 8
/audit               # Stage 10
/deploy-staging      # Stage 12
/deploy-prod         # Stage 13
/metrics-check       # Stage 14
```

---

## 4. The Spec Kit Workflow (97k★)

**Origin**: A specification-driven workflow that uses Claude's reasoning to stress-test requirements.

**Philosophy**: Ambiguous specs are bugs. Fix them before they become code.

```
Step 1: CONSTITUTIONAL
  "Write a one-paragraph 'constitution' for this feature — 
  the principles it must satisfy above all else."

Step 2: SPECIFY  
  Claude generates: user stories, acceptance criteria, edge cases
  
Step 3: CLARIFY
  Claude plays devil's advocate:
  "What could a developer misinterpret about this spec?"
  "What user behavior isn't covered?"
  
Step 4: PLAN
  Implementation plan based on approved spec
  
Step 5: TASKS
  Spec broken into granular tasks with tests
  
Step 6: IMPLEMENT
  Code to the spec, not to assumptions
  
Step 7: VERIFY-SPEC
  Claude checks implementation against original spec
  Reports: satisfied / missing / extra behavior
```

**The constitutional step is the differentiator**:
```markdown
# Example constitution:
"This checkout flow must be: 
(1) forgiving — never lose a user's cart data, 
(2) transparent — always show users what they're paying and why, 
(3) recoverable — every error state must have a clear next step."
```

These principles guide all implementation decisions when the spec is ambiguous.

---

## 5. The Solo Indie Hacker Workflow

**Origin**: Synthesized from multiple solo developers shipping fast with Claude Code.

**Philosophy**: Ship fast, iterate often. Quality matters but so does speed.

```
Morning kickoff (10 min):
  Fresh session
  "Read the last 5 commits. What should I work on today for [goal]?"
  Choose one task. Start it.

Pomodoro coding (25 min):
  One focused session per Pomodoro
  Compact between Pomodoros
  Commit at end of each Pomodoro

Ship daily:
  Every working day ends with a PR or deployed change
  /ship before ending session

Weekly retrospect:
  "Read my git log for the last week. What patterns do you see?"
  Update CLAUDE.md based on what worked/didn't
```

**Key commands for solo devs**:
```bash
/kickoff        # daily orientation
/pomodoro       # 25-min focused sprint  
/ship           # end of day shipping
/retrospect     # weekly learning review
```

---

## 6. The Debugging War Room

**Origin**: Pattern used by on-call engineers for production incident investigation.

**Philosophy**: Production incidents need speed AND precision. Structure prevents panic mistakes.

```
ALERT FIRES:
  1. /incident "description of alert"
     → Claude reads recent commits, relevant code, checks for obvious causes
     → Returns: LIKELY CAUSE + CONFIDENCE + IMMEDIATE ACTIONS

  2. TRIAGE (5 min):
     Is this P0 (system down) or P1 (degraded)?
     P0: page the team immediately, then investigate
     P1: investigate first, page if not resolved in 30 min

  3. INVESTIGATE:
     /debug "error details + stack trace"
     → Systematic hypothesis testing
     → One fix attempt per hypothesis

  4. FIX:
     Minimal change only
     No refactoring during incidents
     Run tests before deploying

  5. VERIFY (10 min post-fix):
     Monitor error rate, latency, key metrics
     Confirm resolved

  6. POST-MORTEM (24h later):
     /post-mortem "incident summary"
     → Root cause analysis
     → What test would have caught this?
     → Update runbooks
```

**The `/incident` command**:
```markdown
<!-- .claude/commands/incident.md -->
# Incident Response: $ARGUMENTS

Immediate triage for: $ARGUMENTS

1. Check recent git commits (last 10):
   `git log --oneline -10`
   
2. Check for relevant recent changes to affected service

3. Read the relevant service files — focus on recently changed code

4. Check if any known issues match this pattern

Output:
- LIKELY CAUSE: [your best hypothesis]
- CONFIDENCE: [high/medium/low]
- IMMEDIATE CHECK: [one command to confirm/deny]
- IF CONFIRMED: [fix approach]
- BLAST RADIUS: [what else could be affected]
```

---

## What All These Workflows Have in Common

Looking across all these teams' approaches, the shared patterns are:

1. **Plan before code** — every team has an explicit planning phase
2. **Verification gates** — nothing moves forward without checking it
3. **Spec clarity** — ambiguous requirements are resolved before implementation
4. **Incremental shipping** — features ship as vertical slices, not horizontal layers
5. **Commands encode the process** — the workflow is `.claude/commands/`, not in someone's head
6. **CLAUDE.md evolves** — every mistake that gets fixed gets codified

The teams that get the most from Claude Code treat their `.claude/` directory as valuable infrastructure, not an afterthought.
