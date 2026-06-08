# Verification Loops — The #1 Quality Multiplier

This is Boris Cherny's (Claude Code creator) most important tip:

> **"Enable verification loops. This is probably the most important thing. Testing improves final output quality by 2–3x."**

Without verification loops, Claude implements → you review manually → you correct → Claude re-implements. This loop is slow and context-heavy.

With verification loops, Claude implements → automated checks run → Claude sees results → Claude self-corrects. This loop is fast, context-efficient, and produces dramatically better output.

---

## What Is a Verification Loop?

A verification loop is any automated check that Claude can see and respond to:

```
Claude makes a change
      │
      ▼
Verification runs automatically (test, lint, typecheck, etc.)
      │
      ▼
Claude sees the result
      │
      ├─ PASS → proceed to next step
      └─ FAIL → Claude fixes the issue and re-runs
```

The key: Claude doesn't just write code and stop. It writes code, checks it, fixes it, checks again. The loop closes automatically.

---

## Setting Up Verification Loops

### Method 1: PostToolUse Hook (automatic)

Every time Claude edits a file, related tests run automatically:

```bash
#!/bin/bash
# .claude/hooks/verification-loop.sh

TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

# Skip test files themselves
echo "$FILE" | grep -qE "\.(test|spec)\." && exit 0

# Only for source files
echo "$FILE" | grep -qE "\.(ts|tsx|js|jsx|py|go)$" || exit 0

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$GIT_ROOT"

echo "=== Verification Loop: $FILE ==="

# Run related tests
if [ -f "package.json" ]; then
  npx jest --findRelatedTests "$FILE" --passWithNoTests 2>&1 | tail -15
fi

# Run type check on the changed file
if echo "$FILE" | grep -qE "\.tsx?$" && command -v npx &>/dev/null; then
  npx tsc --noEmit 2>&1 | grep -E "error TS" | head -5
fi

exit 0
```

```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": ".claude/hooks/verification-loop.sh"}]
      }
    ]
  }
}
```

Claude sees this output after every file edit and self-corrects before moving to the next step.

---

### Method 2: Explicit Verification Instructions

In your CLAUDE.md or at the start of a session:

```markdown
## Verification Protocol

After every code change:
1. Run: npm test -- --findRelatedTests [changed file]
2. Run: npm run typecheck
3. If any failures: fix them before proceeding to the next step
4. Only say "done" when all checks pass
```

This makes verification a first-class step in every task.

---

### Method 3: End-of-Step Gates

In commands and skills, build verification gates:

```markdown
<!-- .claude/commands/implement.md -->
# Implement: $ARGUMENTS

For each implementation step:
1. Make the change
2. Run: `npm test -- --findRelatedTests [changed file] 2>&1 | tail -20`
3. Run: `npm run typecheck 2>&1 | grep "error" | head -10`
4. If PASS on both: proceed
5. If FAIL: fix and re-run before proceeding

Do not move to the next step until current step's verification passes.
```

---

## Verification Loop Configurations by Language

### TypeScript / Node.js

```bash
# Type check
npx tsc --noEmit 2>&1 | grep -c "error" | xargs -I{} sh -c '[ {} -eq 0 ] && echo "TYPES: PASS" || echo "TYPES: {} errors"'

# Tests
npx jest --findRelatedTests $FILE --passWithNoTests --silent 2>&1 | tail -5

# Lint
npx eslint $FILE --format compact 2>&1 | tail -5
```

### Python

```bash
# Type check
mypy $FILE 2>&1 | tail -5

# Tests
pytest --quiet --tb=short $FILE 2>&1 | tail -10

# Lint
ruff check $FILE 2>&1 | tail -5
```

### Go

```bash
# Build (catches type errors)
go build ./... 2>&1 | head -10

# Tests
go test $(dirname $FILE)/... 2>&1 | tail -10

# Lint
golangci-lint run $FILE 2>&1 | head -10
```

---

## The Compound Effect

Each verification loop turn produces slightly better code. Over a 10-step implementation:

```
Without verification loops:
Step 1-10: implement → human review → correct
Total: 10 implementations + 10 reviews + corrections

With verification loops:
Step 1: implement → verify (pass)
Step 2: implement → verify (fail) → fix → verify (pass)
...
Total: 10 implementations + automated verification
Human review finds 2-3 issues instead of 15-20
```

Boris's claim: 2–3x quality improvement. In practice this means:
- PR comments drop significantly
- Bugs caught before they reach review
- Claude produces production-quality code on the first pass more often

---

## Advanced: Multi-Stage Verification

For high-stakes code (auth, payments, data pipelines):

```bash
#!/bin/bash
# .claude/hooks/multi-stage-verify.sh

FILE=$(cat | jq -r '.file_path // empty')
[ -z "$FILE" ] && exit 0

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$GIT_ROOT"

FAILURES=0

echo "=== Stage 1: Type Check ==="
npx tsc --noEmit 2>&1 | grep "error TS" | head -5
[ ${PIPESTATUS[0]} -ne 0 ] && FAILURES=$((FAILURES + 1))

echo "=== Stage 2: Unit Tests ==="
npx jest --findRelatedTests "$FILE" --passWithNoTests 2>&1 | tail -5
[ ${PIPESTATUS[0]} -ne 0 ] && FAILURES=$((FAILURES + 1))

echo "=== Stage 3: Lint ==="
npx eslint "$FILE" --max-warnings 0 2>&1 | tail -5
[ ${PIPESTATUS[0]} -ne 0 ] && FAILURES=$((FAILURES + 1))

if [ $FAILURES -gt 0 ]; then
  echo ""
  echo "⚠️  $FAILURES verification stage(s) failed. Fix before continuing."
fi

exit 0
```

---

## Verification vs. Manual Review

Verification loops do **not** replace human review. They replace the tedious part of human review.

**Verification loop catches**: type errors, test failures, lint violations, obvious bugs
**Human review catches**: wrong abstraction level, missing business requirements, design issues, security nuances

Set up verification loops so your human reviews focus on the things only humans can catch.
