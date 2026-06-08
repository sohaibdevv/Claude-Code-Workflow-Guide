# CLAUDE.md — The Complete Mastery Guide

CLAUDE.md is the single most impactful configuration you can make for Claude Code. It's the project context file that Claude reads at the start of every session — your chance to give Claude everything it needs to work effectively in your codebase from the first message.

A great CLAUDE.md makes every session start at the level of an engineer who's been on the project for months. A missing or poor one means Claude reinvents context every session.

---

## What CLAUDE.md Is (and Isn't)

**CLAUDE.md is:**
- Project context that persists across sessions
- Rules and constraints for this codebase
- Patterns Claude should follow or avoid
- Architecture decisions and their rationale
- The "onboarding document" for an AI engineer

**CLAUDE.md is NOT:**
- Documentation for humans (CLAUDE.md is consumed by Claude, not people)
- A comprehensive README (keep it focused on what Claude needs)
- A place to paste your entire architecture (too much = ignored)
- Set-and-forget (it should evolve as the codebase does)

---

## The 200-Line Rule

CLAUDE.md has a practical limit: around 200 lines. Beyond that, the signal-to-noise ratio drops and Claude starts treating parts of it as background noise.

If your project genuinely needs more context, use the `rules/` pattern:

```
.claude/
├── rules/
│   ├── backend.md       ← loaded when working in /server
│   ├── frontend.md      ← loaded when working in /client
│   ├── database.md      ← loaded when touching DB code
│   └── security.md      ← loaded for auth/security work
```

Reference these from CLAUDE.md:
```markdown
For backend work: @.claude/rules/backend.md
For database work: @.claude/rules/database.md
```

Claude only loads them when relevant, keeping the active context focused.

---

## Anatomy of an Effective CLAUDE.md

### Section 1: Project Identity (5-10 lines)
```markdown
# [Project Name]

[2-3 sentence description of what this project does and who uses it.]

**Stack**: [frontend] + [backend] + [database] + [infra]
**Stage**: [production with X users / internal tool / prototype]
```

### Section 2: Development Commands (10-15 lines)
The exact commands Claude needs to run. Be precise — wrong commands waste everyone's time.

```markdown
## Development

```bash
npm install          # install deps
npm run dev          # start dev server (http://localhost:3000)
npm test             # run all tests
npm run test:watch   # run tests in watch mode
npm run lint         # check linting
npm run typecheck    # TypeScript type check
npm run build        # production build
```

Database:
```bash
npm run db:migrate   # run pending migrations
npm run db:seed      # seed development data
npm run db:reset     # drop + recreate + seed (local only)
```
```

### Section 3: Architecture Overview (15-20 lines)
Key structural decisions that affect how Claude should write code.

```markdown
## Architecture

**Authentication**: JWT tokens, 24-hour expiry, refresh token in HttpOnly cookie.
See `src/auth/` for all auth logic — do not implement auth elsewhere.

**Database Access**: All DB queries go through the repository pattern in `src/repositories/`.
Never write raw SQL outside of repositories. Use Prisma ORM.

**API Design**: REST endpoints in `src/routes/`, business logic in `src/services/`,
DB access in `src/repositories/`. Never skip layers.

**Error Handling**: All errors throw typed errors from `src/errors/`. 
Never throw plain Error objects. Never swallow errors silently.

**Configuration**: All config from environment variables via `src/config.ts`.
Never read process.env directly outside of config.ts.
```

### Section 4: Code Standards (15-20 lines)
The non-obvious rules and patterns specific to this project.

```markdown
## Code Standards

- TypeScript strict mode. No `any` types. Use `unknown` and narrow it.
- No `// @ts-ignore` or `// eslint-disable`. Fix the underlying issue.
- Async/await only. No raw Promises (.then/.catch) except in tests.
- All new code must have tests. No exceptions for "trivial" changes.
- Use named exports. No default exports (import ordering becomes a mess).
- Prefer composition over inheritance. No class hierarchies deeper than 1 level.
- All user-facing strings go through the i18n system at `src/i18n/`.
```

### Section 5: NEVER Section (critical rules)
The most important section — absolute prohibitions.

```markdown
## NEVER

- NEVER commit to main directly. Always use a branch + PR.
- NEVER add migrations without reviewing with the team first.
- NEVER hardcode secrets, URLs, or environment-specific values.
- NEVER edit generated files (check for the `// DO NOT EDIT` header).
- NEVER skip the test suite before proposing a merge.
- NEVER use `console.log` in production code. Use the logger at `src/lib/logger.ts`.
```

### Section 6: Important File Map (optional but valuable)
When the codebase has non-obvious structure.

```markdown
## Key Files

- `src/config.ts` — all environment config
- `src/types/index.ts` — global type definitions  
- `src/errors/index.ts` — all custom error types
- `prisma/schema.prisma` — database schema (source of truth)
- `src/auth/middleware.ts` — auth pattern to follow for new routes
- `src/routes/users.ts` — route pattern to follow for new routes
```

---

## The `<important if>` Pattern

Conditional rules prevent instruction overload. Claude only focuses on relevant rules.

```markdown
<important if="working on authentication or authorization">
All auth changes must:
1. Update the existing tests in tests/auth/
2. Be reviewed for token expiration edge cases
3. Never log sensitive user data
</important>

<important if="running database migrations">
Migration rules:
1. Always create down migrations
2. Never drop columns — use `deprecated_` prefix and drop in next release
3. Test on a copy of production data before submitting PR
</important>
```

---

## Monorepo CLAUDE.md Strategy

For large monorepos, use ancestor/descendant loading:

```
project/
├── CLAUDE.md              ← Global rules (loaded always)
├── apps/
│   ├── web/
│   │   └── CLAUDE.md      ← Frontend-specific rules
│   └── api/
│       └── CLAUDE.md      ← Backend-specific rules
└── packages/
    └── shared/
        └── CLAUDE.md      ← Shared package rules
```

When Claude works in `apps/web/`, it loads: root CLAUDE.md + `apps/web/CLAUDE.md`.
When Claude works in `apps/api/`, it loads: root CLAUDE.md + `apps/api/CLAUDE.md`.

Root CLAUDE.md: project-wide rules (security, git workflow, common patterns)
Sub-CLAUDE.mds: domain-specific rules (tech stack, component patterns, DB access)

---

## Keeping CLAUDE.md Current

CLAUDE.md rots if you don't maintain it. Schedule a monthly review:

- Remove instructions for patterns you no longer use
- Update commands when scripts change
- Add new NEVER rules when you discover new footguns
- Update architecture sections when you refactor

Stale CLAUDE.md is worse than no CLAUDE.md — outdated rules actively mislead.

---

## Validating Your CLAUDE.md

After writing or updating, verify it works:

```bash
# Start a new Claude session and ask:
"Based on our CLAUDE.md, what are the three most important rules for working in this codebase?"

"What command should I run to start the dev server?"

"If I wanted to add a new API endpoint, what pattern should I follow and which file should I look at as a reference?"
```

If Claude can't answer accurately, your CLAUDE.md needs work.
