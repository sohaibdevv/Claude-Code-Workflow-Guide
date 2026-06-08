# Subagents — Isolated Context for Complex Tasks

Subagents are Claude instances with their own fresh context windows. They're the solution to one of the hardest problems in Claude Code: how do you handle tasks too large or complex for a single context without losing quality?

---

## The Problem Subagents Solve

Every piece of information in your context window competes for Claude's "attention." A session that started with research, then planning, then debugging now contains all three phases' history. When you're in phase 4 (implementation), Claude's reasoning is being influenced by all the earlier context — some of it outdated, contradictory, or just irrelevant noise.

Subagents solve this by isolating each concern in its own context window.

```
Without subagents:
Main context: [research] [planning] [debugging] [attempt 1] [correction] [attempt 2]...
              ─────────────────────────────────────────────────────────────────
              By implementation phase, context is a mess of mixed concerns

With subagents:
Researcher:   [pure exploration, clean context]
Planner:      [pure design, starts fresh]
Implementer:  [pure coding, starts fresh]
Reviewer:     [pure review, starts fresh]
```

---

## Subagent Architecture Patterns

### 1. Specialist Chain
Each specialist gets a clean context for their domain.

```
Orchestrator (main context)
├── calls Researcher → returns findings summary
├── calls Architect → returns design document
├── calls Implementer → returns implementation
└── calls Reviewer → returns review findings
```

**Best for:** Complex features with distinct phases

### 2. Parallel Workers
Multiple agents work simultaneously on independent parts.

```
Orchestrator
├── spawns Agent A (handles module 1) ─── parallel
├── spawns Agent B (handles module 2) ─── parallel
└── spawns Agent C (handles module 3) ─── parallel
                    ↓
         Orchestrator merges results
```

**Best for:** Independent modules, multi-file refactors

### 3. Research Isolation
Keep exploration out of your main context entirely.

```
Main context (stays clean for execution)
└── Research subagent
    ├── reads 20+ files
    ├── runs many searches
    └── returns a 1-page summary
```

**Best for:** Understanding unfamiliar codebases

---

## Writing Effective Subagent Prompts

The #1 subagent failure mode: the prompt doesn't give the agent enough context because you assumed it knows things from the main session. It doesn't. Subagents start completely fresh.

### Required Elements

```markdown
## Context (What this is about)
[What the overall project is, what tech stack, what we're trying to achieve]

## Your Specific Task
[Exactly what this agent should do — not the overall goal, but THIS agent's job]

## Constraints
[What NOT to do — files to leave alone, operations to skip]
[Read-only vs. can-modify]

## Resources
[Specific files or paths to look at]

## Output Format
[Exactly what structure to return so the orchestrator can use it]

## Definition of Done
[How to know when the task is complete]
```

### Example: Research Subagent

```markdown
## Context
This is a Node.js + TypeScript e-commerce API. We're adding a product recommendation feature.

## Your Task
Research how product data is currently structured and accessed. Find:
1. The database schema for products (look in prisma/schema.prisma)
2. The Product model and its relationships
3. How products are queried (look in src/db/ and src/services/)
4. Any existing recommendation or "related products" logic
5. The API endpoints for products

## Constraints
- READ ONLY — do not modify any files
- Do not run any build or test commands
- Do not install any packages

## Output Format
Return a structured report:
### Database Schema
[Product table columns and relationships]
### Key Query Patterns
[How products are fetched, with file:line references]
### Existing Recommendation Logic
[Any existing related-product logic, or "None found"]
### Suggested Integration Points
[Where the new feature should hook in]
```

---

## Subagent vs Direct Work: Decision Guide

| Situation | Use Subagent? |
|---|---|
| Research spanning 10+ files | Yes — keep exploration isolated |
| Simple bug fix in 1-2 files | No — direct work |
| Parallel independent modules | Yes — run simultaneously |
| Single focused implementation | No — direct work |
| Code review of large diff | Yes — reviewer gets clean context |
| Writing tests for known code | No — direct work |
| Architecture design | Yes — architect gets focused context |
| Debugging a specific error | No — you need the error in main context |

---

## Controlling Subagent Output Size

Subagents can return a lot of output, which goes into your main context. Control this:

```markdown
# In subagent prompt:
Return a MAXIMUM 50-line summary. Be ruthlessly concise. 
Include file:line references but not full code snippets.
```

The richer detail lives in the subagent's context (which is discarded after it finishes). Only the actionable summary comes back to you.

---

## Subagent Error Handling

Subagents can fail or return incomplete results. Build robustness into your orchestration:

```markdown
# In orchestrator prompt:
Spawn the research subagent. If it returns "not found" or an error,
try the search with these alternative terms: [alternatives].
If research is inconclusive, report that and ask me before proceeding.
```

---

## Advanced: Nested Subagents

You can have subagents spawn their own subagents, but depth beyond 2 levels gets fragile. Keep nesting shallow.

```
Level 0: Your main session (orchestrator)
Level 1: Feature subagent (knows about the feature)
Level 2: File-specific subagent (knows about one module)
Level 3: ⚠️ Avoid — context overhead rarely worth it
```
