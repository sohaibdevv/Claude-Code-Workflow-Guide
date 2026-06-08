# Plan Mode — Think Before You Act

Plan mode is the most powerful tool in Claude Code for complex, high-stakes, or irreversible tasks. It separates thinking from acting — and that separation is everything.

---

## The Core Insight

When Claude jumps straight to coding, it commits early. The first file it edits constrains the second. The second constrains the third. By the time you're deep into implementation, you may realize the approach was wrong — but unwinding it is painful.

Plan mode forces the design to be explicit and reviewable *before* any changes are made. You can push back, ask questions, and refine the plan at near-zero cost. Doing the same thing mid-implementation costs 10x more.

---

## When to Use Plan Mode

**Always use for:**
- Changes spanning 3+ files
- Database migrations or schema changes
- Breaking API changes
- Auth or security systems
- Any operation that's hard to undo
- When you're uncertain about the approach

**Optional for:**
- Well-understood 1-2 file changes
- Adding tests to existing code
- Documentation updates

**Skip for:**
- Renaming a variable
- Fixing a typo
- Adding a comment

---

## Entering Plan Mode

```bash
# Via CLI flag (starts in plan mode)
claude --plan "migrate user passwords to bcrypt"

# Via slash command mid-session
/plan

# Via keyboard shortcut
Shift + Tab

# Via instruction at start of message
"Before making any changes, give me a complete plan first."
```

---

## What a Good Plan Looks Like

A good plan is **specific enough to execute without ambiguity**. Vague plans produce vague implementations.

### Bad Plan
```
1. Update the auth system
2. Add bcrypt
3. Test it
```

### Good Plan
```
Goal: Migrate password hashing from MD5 to bcrypt

Files to modify:
- src/auth/password.ts — replace hashPassword() and verifyPassword()
- src/db/migrations/ — new migration to add temp column
- tests/auth/password.test.ts — update test expectations

Steps:
1. Add `bcrypt` package: npm install bcrypt @types/bcrypt
2. Create migration `0042_password_migration.sql`:
   - Add column `password_hash_bcrypt VARCHAR(72)`
   - Keep existing `password_hash_md5` column (for rollback)
3. Update hashPassword() in src/auth/password.ts:
   - Replace md5(password) with await bcrypt.hash(password, 12)
4. Update verifyPassword() to check bcrypt hash first, fall back to MD5
5. Write migration script to re-hash all existing users on next login
6. Update tests to reflect new hash format

Irreversible step: step 2 migration (mitigated by keeping MD5 column)

Rollback plan: revert migration, restore original hashPassword() — no data loss since MD5 column preserved until cleanup

Tests to run after each step: npm test src/auth/
```

---

## Plan Review Checklist

When reviewing a plan before approving:

- [ ] Are all affected files listed?
- [ ] Is the sequence of steps logical?
- [ ] Are irreversible steps identified?
- [ ] Is there a rollback plan?
- [ ] Are tests accounted for?
- [ ] Is the blast radius bounded?
- [ ] Are there hidden assumptions?
- [ ] What could go wrong?

---

## Challenging the Plan

Plan mode is most valuable when you **engage with it**, not just rubber-stamp it.

Questions to ask:
```
"Why this approach over [alternative]?"
"What happens if step 3 fails halfway?"
"Is there a simpler way to achieve the same outcome?"
"What test would catch a regression in this area?"
"Can we make this change incrementally rather than all at once?"
```

The goal is to uncover bad assumptions before they become bad code.

---

## Vertical Slices, Not Horizontal Layers

One of the most common planning mistakes: horizontal-layered plans.

**Horizontal (bad):**
```
1. Update all database models
2. Update all business logic
3. Update all API endpoints
4. Update all frontend components
5. Update all tests
```
This produces an un-shippable half-finished feature for most of the work.

**Vertical (good):**
```
Slice 1: User can log in with email
  - DB model for login session
  - Business logic for auth
  - API endpoint /auth/login
  - Frontend login form
  - Tests for the whole slice

Slice 2: User can log out
  - Session deletion logic
  - API endpoint /auth/logout
  - Frontend logout button
  - Tests
```
Each slice is shippable. You can stop after any slice and have working software.

---

## Plan Mode for Teams

When working with other engineers, plan mode output becomes a natural artifact for review:
1. Generate the plan
2. Share it in PR description or design doc
3. Get feedback before any code is written
4. Align before investing in implementation

This eliminates the classic "wrong approach" PR review that wastes a week of work.
