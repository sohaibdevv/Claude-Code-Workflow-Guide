# Babysit PRs — Automated PR Queue Management

Boris Cherny uses `/loop 5m /babysit-prs` to handle PR management without manual attention. This workflow automates the tedious parts of maintaining a PR queue.

---

## What "Babysitting PRs" Means

A PR that's open but stale has a cost:
- Merge conflicts accumulate
- CI results expire
- Reviewers forget context
- Features sit unreleased

"Babysitting" means continuously monitoring and advancing PRs through their lifecycle — resolving CI failures, addressing review comments, rebasing, and merging when ready.

---

## The `/babysit-prs` Command

```markdown
<!-- .claude/commands/babysit-prs.md -->
# Babysit PRs — Monitor and Advance Open PRs

Check all open PRs and take appropriate action for each.

## Fetch Open PRs
```bash
gh pr list --state open --json number,title,statusCheckRollup,reviewDecision,mergeable,updatedAt
```

## For Each PR, Take Action:

### If CI is failing:
1. Fetch the failure details: `gh pr checks [number]`
2. Checkout the branch locally
3. Investigate the failure
4. Fix if the issue is clear and safe to fix
5. Push the fix
6. Comment on the PR: "Fixed CI failure: [brief description]"

### If there are review changes requested:
1. Read the review comments: `gh pr review [number] --comments`
2. If the changes are clear and unambiguous: make them
3. If the changes require discussion: add a comment asking for clarification
4. Re-request review when done: `gh pr review [number] --request-review`

### If approved and CI passes:
1. Check for conflicts: `gh pr view [number] --json mergeable`
2. If no conflicts: `gh pr merge [number] --squash --auto`
3. If conflicts: rebase and resolve

### If stale (no activity in 5+ days):
1. Post a comment: "This PR has been inactive for [N] days. Is it still in progress?"

### If draft:
- Skip — drafts are not ready for action

## Report
After processing all PRs, output a summary:
- PRs merged: [list]
- PRs fixed: [list]
- PRs needing human attention: [list with reason]
```

---

## The `/loop` Setup

```bash
# Run babysit-prs every 5 minutes
/loop 5m /babysit-prs

# Run every 30 minutes during business hours
/loop 30m /babysit-prs

# Run once (manual)
/babysit-prs
```

---

## Safety Guards

Before setting up automated PR merging, add safeguards:

```markdown
<!-- Add to babysit-prs.md -->

## Safety Rules (NEVER violate these)

- NEVER merge to main without at least 1 human approval
- NEVER merge if there are unresolved review threads
- NEVER force-push to shared branches
- NEVER merge PRs tagged with "do-not-merge" or "WIP"
- NEVER merge if the PR author explicitly said "don't merge yet"
- ALWAYS check that CI passes completely (not just required checks)

If any safety rule would be violated: skip the PR and add it to "needs human attention" report.
```

---

## PR Health Dashboard

Add this to your session start or as a scheduled check:

```bash
# .claude/commands/pr-dashboard.md
# Show PR queue health

Generate a PR health dashboard:

```bash
gh pr list --state open --json number,title,author,createdAt,reviewDecision,statusCheckRollup,mergeable
```

Format as a table:
| PR | Title | Age | Status | CI | Action Needed |
|---|---|---|---|---|---|
[populate from data]

Color coding (text):
- READY: approved + CI passing + no conflicts
- BLOCKED: has unresolved review threads  
- FAILING: CI failing
- STALE: no activity in 3+ days
- CONFLICT: has merge conflicts
```

---

## Integration with Notifications

Add a hook to notify you when babysit-prs takes significant action:

```bash
#!/bin/bash
# hooks/pr-notification.sh

# Called after babysit-prs completes
RESULT=$(cat)

MERGED=$(echo "$RESULT" | grep "Merged:" | wc -l)
NEEDS_HUMAN=$(echo "$RESULT" | grep "needs human attention" | wc -l)

if [ $MERGED -gt 0 ] || [ $NEEDS_HUMAN -gt 0 ]; then
  # macOS notification
  osascript -e "display notification \"$MERGED merged, $NEEDS_HUMAN need attention\" with title \"PR Babysitter\"" 2>/dev/null

  # Slack notification
  [ -n "$SLACK_WEBHOOK" ] && curl -s -X POST "$SLACK_WEBHOOK" \
    -d "{\"text\":\"PR Update: $MERGED merged, $NEEDS_HUMAN need your attention\"}" 2>/dev/null
fi
```
