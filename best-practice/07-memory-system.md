# Memory System — Persistent Knowledge Across Sessions

Claude Code's memory system lets it remember information between sessions. Without memory, every session starts from zero — Claude has to rediscover your preferences, relearn your project's quirks, and rebuild context that you've already established. With memory, Claude accumulates a working knowledge of you and your project over time.

---

## Memory Architecture

Memory lives in your filesystem at:
```
~/.claude/projects/<project-slug>/memory/
├── MEMORY.md              ← Index (always loaded automatically)
├── user_profile.md        ← Who you are, your preferences
├── feedback_style.md      ← What style of responses you prefer
├── feedback_testing.md    ← Testing preferences
├── project_goals.md       ← Current project goals and context
├── project_decisions.md   ← Architecture decisions made
└── reference_systems.md   ← Where important things live
```

`MEMORY.md` is an index with one-line summaries and links. It's loaded at the start of every session. The individual memory files are loaded on-demand when relevant.

---

## Memory Types

### User Memory
What Claude knows about you as a developer.

```markdown
---
name: developer-profile
description: Vignesh's background, expertise, and working preferences
metadata:
  type: user
---

Senior full-stack developer, strong in TypeScript and Node.js, newer to Rust.
Prefers direct, terse responses — no step-by-step explanations for patterns 
already understood. Values code quality over speed. 
Favors functional patterns over class-heavy OOP.
```

### Feedback Memory
Corrections and confirmations that shape future behavior.

```markdown
---
name: feedback-response-style
description: How to format responses — no trailing summaries, no "I'll now..."
metadata:
  type: feedback
---

Do not narrate what you're about to do ("I'll now create the file...").
Do not summarize what you just did at the end.
Do not add emojis unless asked.
When making file changes, just make them — no preamble.

**Why**: User finds narration adds length without value. Direct output preferred.
**How to apply**: In all responses, skip the meta-commentary. Act, then optionally note key decisions.
```

### Project Memory
Goals, decisions, and context for the current work.

```markdown
---
name: project-auth-decisions
description: Auth architecture decisions for the e-commerce platform
metadata:
  type: project
---

Auth uses stateless JWTs (no session DB). Refresh tokens stored in HttpOnly cookies.
Access token: 15 min TTL. Refresh token: 30 days.

**Why**: We evaluated session-based auth but chose stateless to support horizontal scaling.
**How to apply**: When suggesting auth changes, don't propose session-based solutions 
unless specifically asked. Any token storage change must maintain the HttpOnly cookie approach.
```

### Reference Memory
Where things live in external systems.

```markdown
---
name: reference-infrastructure
description: Where infrastructure and monitoring systems are located
metadata:
  type: reference
---

- Grafana: grafana.internal/d/api-latency (oncall dashboard)
- Linear: project "BACKEND" for backend tickets, "FRONTEND" for frontend
- Slack: #incidents for production issues, #deployments for deploy notifications
- Staging: staging.yourapp.com (resets nightly at 2am UTC)
- Production logs: Datadog, query: service:api env:prod
```

---

## When to Save Memories

### Save immediately when:
- You correct Claude's approach and want the correction to stick
- Claude does something exactly right in a non-obvious way
- You make an architecture decision that will affect future work
- You discover a project quirk that Claude will need to know repeatedly

### Don't save:
- Things obvious from reading the code
- Temporary task state ("we're working on the login page")
- Things already in CLAUDE.md or documentation
- Recent git history (use `git log` instead)

### Trigger memory saves explicitly:
```
"Remember that I prefer Jest over Vitest for this project"
"Save this decision: we're using Redis for rate limiting, not the database"
"Note: the CI pipeline is slow because of the E2E tests. Don't wait for it before continuing."
```

---

## MEMORY.md Format

The index file — kept under 200 lines, one line per entry:

```markdown
# Memory Index

## User
- [Developer Profile](user_profile.md) — TypeScript/Node expert, new to Rust, prefers terse responses
- [Response Style](feedback_style.md) — no narration, no summaries, direct output

## Project: E-Commerce Platform
- [Auth Decisions](project_auth_decisions.md) — JWT stateless, 15min/30day tokens, HttpOnly cookies
- [Architecture](project_architecture.md) — REST API, PostgreSQL, Redis cache, event-driven notifications
- [Current Sprint](project_sprint.md) — shipping checkout flow by 2026-05-20

## References
- [Infrastructure](reference_infrastructure.md) — Grafana, Linear, Slack channels, staging URL
```

---

## Memory Maintenance

Memories go stale. File paths change, decisions get reversed, people's roles evolve.

**Monthly**: Review all memories for accuracy. Delete or update stale ones.

**After major refactors**: Update architecture and reference memories.

**After changing approaches**: Update relevant feedback memories to reflect the new preference.

Stale memories are worse than no memories. A memory that says "we use Redux" when you migrated to Zustand three months ago will actively confuse Claude.

---

## Memory vs CLAUDE.md — When to Use Which

| | CLAUDE.md | Memory |
|---|---|---|
| Project-wide rules | ✅ | ❌ |
| Team-shared context | ✅ | ❌ |
| Personal preferences | ❌ | ✅ |
| Architecture decisions | ✅ | For non-obvious ones |
| Development commands | ✅ | ❌ |
| User style preferences | ❌ | ✅ |
| External system locations | ❌ | ✅ |
| Committed to git | Yes | No |
