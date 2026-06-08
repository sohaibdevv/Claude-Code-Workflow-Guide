# Batch Migrations — Large-Scale Code Changes Across Worktrees

Boris Cherny's `/batch` pattern distributes large migrations across multiple Claude agents working in parallel. Use this for changes that touch dozens or hundreds of files.

---

## When to Use Batch Migration

**Good candidates for batch migration:**
- Renaming a function/class/variable used in 50+ files
- Migrating from one library to another (e.g., axios → fetch, moment → dayjs)
- Adding a required field to all models
- Updating an API client to a new version
- Converting file formats (JS → TS, CommonJS → ESM)
- Adding consistent error handling to all service files

**Bad candidates:**
- Changes requiring judgment per-file (different files need different approaches)
- Changes that depend on each other's output
- Anything involving database migrations (too risky to parallelize)

---

## The Batch Pattern

### Step 1: Discovery

First, understand the full scope:

```bash
# Find all files that need changing
grep -rn "oldFunctionName\|OldClassName\|old-package" --include="*.ts" --include="*.tsx" . | wc -l

# List them
grep -rl "oldFunctionName" --include="*.ts" . > /tmp/files-to-migrate.txt
cat /tmp/files-to-migrate.txt
```

### Step 2: Validate the Pattern

Before scaling up, validate on 2-3 files:

```bash
# Test the migration on a small sample
head -3 /tmp/files-to-migrate.txt | while read file; do
  echo "Testing migration on: $file"
  # Apply the change
  # Run the file's tests
  # Verify correctness
done
```

### Step 3: Partition into Batches

```bash
# Split 100 files into 5 batches of 20
split -l 20 /tmp/files-to-migrate.txt /tmp/batch-

# You get: batch-aa, batch-ab, batch-ac, batch-ad, batch-ae
ls /tmp/batch-*
```

### Step 4: Launch Parallel Agents

```bash
#!/bin/bash
# scripts/batch-migrate.sh

BATCH_DIR="/tmp"
MIGRATION_DESC="$1"  # e.g., "migrate from axios to fetch"

if [ -z "$MIGRATION_DESC" ]; then
  echo "Usage: $0 'migration description'"
  exit 1
fi

# Create worktrees for each batch
for batch_file in $BATCH_DIR/batch-*; do
  batch_name=$(basename "$batch_file")
  worktree_path="/tmp/migrate-$batch_name"

  git worktree add "$worktree_path" -b "migration/$batch_name" 2>/dev/null
  cp "$batch_file" "$worktree_path/.files-to-migrate"

  tmux new-window -n "migrate-$batch_name"
  tmux send-keys "cd $worktree_path && claude '
    Migrate the files listed in .files-to-migrate.
    Migration: $MIGRATION_DESC
    
    For each file:
    1. Read the current content
    2. Apply the migration
    3. Run its related tests to verify
    4. Fix any test failures caused by the migration
    
    When done with all files, commit: git add -A && git commit -m \"migration: $MIGRATION_DESC\"
    Then print: BATCH COMPLETE
  '" Enter
done

echo "Batch migration started. Monitor with: tmux attach"
```

### Step 5: Monitor Progress

```bash
# Watch each batch's progress
watch -n 10 'for dir in /tmp/migrate-*; do
  echo "=== $(basename $dir) ==="
  git -C "$dir" log --oneline -1
done'

# Check for "BATCH COMPLETE" output
tmux list-panes -a -F "#{pane_title}: #{pane_current_command}"
```

### Step 6: Merge and Verify

```bash
# After all batches complete
git fetch --all

# Merge each batch
for branch in $(git branch -r | grep "migration/batch-"); do
  local_branch="${branch#origin/}"
  git merge "$local_branch" --no-ff -m "Merge $local_branch"
done

# Run full test suite
npm test

# If tests pass, clean up worktrees
git worktree list | grep "/tmp/migrate-" | awk '{print $1}' | xargs -I{} git worktree remove {}
```

---

## The /batch Command

```markdown
<!-- .claude/commands/batch.md -->
# /batch — Distribute Migration Across Worktrees

Migration task: $ARGUMENTS

## Phase 1: Discovery
Find all files that need this migration. Count them. List them.

## Phase 2: Validation
Apply the migration to 2 files. Run their tests. Confirm the approach works before scaling.

## Phase 3: Partition
If > 10 files: split into batches of 15-20 files each.
If <= 10 files: handle in current session.

## Phase 4: Execute
For each batch: create a worktree and launch an agent.
Each agent handles its batch, runs tests, commits when done.

## Phase 5: Integrate
After all batches complete: merge all branches, run full test suite, clean up worktrees.

## Safety
- Never batch migrate migration files or schema files
- Always validate on 2-3 files before scaling
- Each batch agent must run tests and fix failures before committing
```

---

## Real Example: Migrating from CommonJS to ESM

```bash
# Discovery
grep -rl "require(" --include="*.ts" src/ > /tmp/cjs-files.txt
wc -l /tmp/cjs-files.txt  # 87 files

# Validate approach on 3 files
head -3 /tmp/cjs-files.txt | xargs -I{} claude --non-interactive \
  "Convert {} from CommonJS require() to ESM import syntax. Run related tests after."

# If validation passes: run the batch
./scripts/batch-migrate.sh "convert from CommonJS require() to ESM import syntax"
```

---

## Cost Consideration

Running 5 parallel migration agents each handling 20 files:
- Each agent reads 20 files + writes 20 files + runs tests
- Context per agent: ~50-100k tokens
- Total: ~5x normal cost

For a 100-file migration that would take 4 hours sequentially:
- Parallel approach: ~50 minutes
- Cost: ~5x per-agent Sonnet cost
- Time saved: 3+ hours

For large codebases, this trade-off is almost always worth it.
