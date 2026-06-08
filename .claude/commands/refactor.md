# /refactor — Safe Refactoring Workflow

Refactor: $ARGUMENTS

## Pre-Refactor Safety Check

Before touching anything:

1. **Confirm tests exist** — run them, they must pass
```bash
npm test
```
If tests don't exist or don't pass, STOP and report before proceeding.

2. **Snapshot behavior** — note what the code currently does at a high level

3. **Identify dependencies** — what calls this? What does this call?

## Refactoring Rules

- Make ONE type of change at a time (rename OR restructure OR extract, not all together)
- Run tests after each change
- Commit at each stable point
- Do NOT fix bugs or add features during refactor (separate work)

## Change Types (in safe order)

### Level 1: Rename Only
Rename files, functions, variables for clarity.
```
Old: getUserData()
New: fetchUserProfile()
```

### Level 2: Extract
Extract repeated logic into shared functions.
```
Before: same 10 lines in 3 places
After: one shared utility function
```

### Level 3: Restructure
Move code between files, reorganize module boundaries.

### Level 4: Rewrite
Full rewrite of logic — requires most test coverage.

## Post-Refactor Verification

1. All tests still pass
2. No behavior change (output identical for same inputs)
3. Complexity reduced (fewer lines, cleaner structure)
4. No dead code introduced

Report: lines removed, complexity reduced, test status.
