# /plan — Enter Structured Planning Mode

Activate deep planning mode for: $ARGUMENTS

## Instructions

Before writing a single line of code or making any file change, produce a complete implementation plan using the following structure:

---

## 1. Goal Restatement
Restate the goal in your own words to confirm understanding.

## 2. Affected Files
List every file that will be:
- **Created** (new files)
- **Modified** (existing files changed)
- **Deleted** (files to be removed)
- **Left alone** (explicitly confirm nothing else is touched)

## 3. Implementation Steps
Number each step. Be specific — not "update auth" but "add `refreshToken` field to `UserSession` type in `src/types/auth.ts:42`".

## 4. Test Strategy
- What existing tests need to be updated?
- What new tests should be written?
- What's the command to run them?

## 5. Risks & Irreversible Steps
Highlight any:
- Database migrations
- Schema changes
- Breaking API changes
- Secrets/credential changes

## 6. Rollback Plan
If something goes wrong at step N, how do we restore the previous state?

## 7. Checkpoints
After which steps should I review the diff before continuing?

---

**DO NOT EXECUTE until the plan is reviewed and approved.**
