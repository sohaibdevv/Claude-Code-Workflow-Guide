# Solo Developer vs. Team Workflows

Claude Code works differently depending on whether you're a solo developer or part of an engineering team. Here's how to optimize for each context.

---

## Solo Developer Patterns

When you're the only engineer, you have full context on everything. You can afford to be more experimental and less formal.

### The Solo Rapid Iteration Cycle

```
1. Describe what you want at a high level
2. Let Claude draft an approach
3. React to it — "yes but..." or "actually, let's..."
4. Iterate until the approach feels right
5. Execute in bigger chunks (you'll review anyway)
6. Commit frequently
7. Ship when tests pass
```

**Solo advantages**:
- No coordination overhead
- You have full context — less need for documentation
- Can change direction quickly without aligning others
- Personal settings can be very aggressive

**Solo CLAUDE.md tips**:
- Include your personal patterns (you don't need to convince a team)
- Document your "system" (e.g., "I always use functional React, never class components")
- Be opinionated — there's no one to disagree

### Solo Session Management
```bash
# Rename sessions for easy resumption
/rename shopping-cart-feature

# Multiple contexts across projects
tmux new-session -s project-a
tmux new-session -s project-b
```

---

## Team Workflows

When working with other engineers, Claude Code usage needs coordination so you're not working at cross-purposes.

### Shared Configuration (the foundation)

```
.claude/ (committed to git)
├── settings.json          # team-agreed permissions
├── commands/              # everyone gets the same commands
├── agents/                # shared agent definitions
└── skills/                # shared skill library
```

Every engineer runs the same Claude Code setup. No "it worked on my machine" for Claude config.

### The Feature Workflow for Teams

```
Engineer starts feature:
1. Create branch: git checkout -b feature/my-feature
2. Run /plan to create implementation plan
3. Paste plan into PR description (even before coding)
4. Get async feedback from team on the plan
5. Implement the approved plan
6. Run /review before pushing
7. Run /ship to create the PR
```

Sharing the plan before implementation prevents the common scenario of "the approach is wrong" review comments after a week of work.

### Avoiding Conflicts in Parallel Work

```markdown
# In CLAUDE.md for teams
## Parallel Work Protocol

If you need to modify a shared type, interface, or utility that other
team members' branches might also modify:

1. Check if there's an in-flight PR touching the same file:
   `gh pr list --search "path:src/types/"`
   
2. If yes: coordinate with the other PR before modifying
3. If no: document your change in your PR description
   under "Shared File Changes"
```

### Review Protocol

```
Claude generates first-pass review → 
Human reads and adds context Claude can't know (business intent, non-obvious constraints) →
Final review captures both
```

Don't replace human review with Claude review. Use Claude to catch mechanical issues (security, correctness, patterns) so humans can focus on higher-level concerns (design, requirements, tradeoffs).

---

## Hybrid: Small Teams (2-5 Engineers)

The sweet spot where you get coordination benefits without too much overhead.

### The Async Planning Model

```
Engineer proposes plan (via /plan or PR description) →
Team members can async-review the plan (comments, Slack) →
24-48 hour window for feedback →
Proceed if no blocking objections
```

This prevents unilateral design decisions while avoiding the overhead of synchronous design meetings for every feature.

### Shared Command Library

Build commands that encode your team's specific processes:

```markdown
<!-- .claude/commands/team-ship.md -->
# Team Ship

Before shipping, verify our team's specific requirements:

1. Tests pass: `npm test`
2. No circular dependencies: `npx madge --circular src/`
3. Bundle size within budget: `npm run build:analyze`
4. API endpoints documented: check openapi.json is updated
5. Changelog entry added for user-facing changes

Then create PR with our team's required sections:
- Description
- Test plan
- Screenshots (for UI changes)
- Breaking changes (if any)
- Rollback plan (for migrations)
```

Your team's shipping checklist, codified as a command. Everyone ships the same way.

---

## When Claude Code Hurts Team Velocity

Warning signs that Claude Code is becoming a liability:

**Over-reliance**: Engineers stop reading the code Claude writes. Bugs slip through because no one's really reviewing.

**Context drift**: Long-running sessions with many engineers jumping in and out produce inconsistent code because Claude's context is a mess.

**Documentation debt**: Moving fast with AI leads to under-documented decisions. Future engineers (including AI) can't understand why things are the way they are.

**Solutions**:
- Require human review of all Claude-generated code (like any PR)
- Establish session hygiene rules (fresh sessions for new tasks)
- Write ADRs for significant decisions, whether AI-assisted or not
