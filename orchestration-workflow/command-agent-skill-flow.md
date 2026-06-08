# Command → Agent → Skill Flow

The most powerful orchestration pattern in Claude Code: user invokes a command, the command spawns specialized agents, agents use skills to complete their work.

---

## The Architecture

```
User: /feature "add dark mode"
           │
           ▼
   ┌───────────────┐
   │ /feature cmd  │  ← reads feature.md command file
   │               │  ← gathers context from CLAUDE.md
   └───────┬───────┘
           │ spawns
           ├─────────────────────────────────────┐
           ▼                                     ▼
   ┌───────────────┐                   ┌───────────────┐
   │  Research     │                   │  Planning     │
   │  Agent        │                   │  Agent        │
   │  (Explore)    │                   │  (Plan mode)  │
   └───────┬───────┘                   └───────┬───────┘
           │ returns findings                   │ returns plan
           └──────────────┬──────────────────────┘
                          ▼
                  ┌───────────────┐
                  │  Coding Agent │  ← uses /tdd skill
                  │  (Sonnet)     │
                  └───────┬───────┘
                          │ returns implementation
                          ▼
                  ┌───────────────┐
                  │ Review Agent  │  ← uses /review skill
                  │  (Opus)       │
                  └───────┬───────┘
                          │ approved
                          ▼
                  ┌───────────────┐
                  │  /ship        │  ← ship command
                  └───────────────┘
```

---

## Example: The /feature Command

```markdown
<!-- .claude/commands/feature.md -->
# /feature — Full Feature Development Workflow

Build the feature: $ARGUMENTS

## Step 1: Research (Subagent)
Spawn a research agent to understand the codebase context for this feature.
The agent should read relevant files and return a summary of:
- Where this feature fits in the architecture
- Files likely to be modified
- Existing patterns to follow
- Any gotchas

## Step 2: Plan (Plan Mode)
Using the research findings, enter plan mode and create:
- Implementation steps with specific file changes
- Test strategy
- Rollback plan

Present the plan. Wait for approval before proceeding.

## Step 3: Implement
Execute the approved plan:
- Follow the TDD workflow for all logic
- Run tests after each major change
- Pause at checkpoints for review

## Step 4: Review (Subagent)
Spawn a review agent to check the implementation:
- Security review
- Code quality check
- Test coverage verification

## Step 5: Ship
Run /ship to complete the workflow.
```

---

## Building Composable Skills

Skills can be referenced from commands to keep things DRY:

```markdown
<!-- .claude/commands/feature-with-skills.md -->
# /feature — Build Feature Using Skills

For feature: $ARGUMENTS

1. Use @.claude/skills/research/SKILL.md to explore the codebase
2. Use @.claude/skills/tdd/SKILL.md to implement with tests
3. Use @.claude/skills/review/SKILL.md to verify
4. Run /ship to finalize
```

```markdown
<!-- .claude/skills/research/SKILL.md -->
---
name: codebase-research
description: Use when you need to understand the codebase before making changes. Explores relevant files and returns a structured report.
---

# Codebase Research Skill

Spawn an Explore subagent to:
1. Find all files related to the task
2. Map the data flow
3. Identify patterns to follow
4. Return a 1-page research report

The subagent is read-only. Never modify files during research.
```

---

## Conditional Branching

Commands can branch based on task properties:

```markdown
<!-- .claude/commands/smart-fix.md -->
# /smart-fix — Intelligent Bug Fix

Fix: $ARGUMENTS

First, assess the complexity:
- If it's a 1-line fix: fix it directly, run tests, ship
- If it requires 1-3 file changes: quick plan, implement, quick review, ship
- If it's complex (4+ files or security-related): full RPRS workflow

Choose the appropriate path and execute it.
```

---

## Handoff Protocol Between Agents

When one agent's output feeds another, define the handoff format explicitly:

```markdown
## Research Agent → Planning Agent Handoff

Research agent must return:
```json
{
  "relevant_files": ["path/to/file.ts:line", ...],
  "current_approach": "description of how it works now",
  "integration_points": ["where new code hooks in"],
  "patterns_to_follow": "reference to existing pattern",
  "risks": ["list of things to be careful about"]
}
```

Planning agent receives this JSON and uses it to generate the implementation plan.
```

Structured handoffs prevent the planning agent from making assumptions about what the research agent found.
