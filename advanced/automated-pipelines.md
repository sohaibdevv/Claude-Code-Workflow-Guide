# Automated Pipelines — Claude Code as Infrastructure

Claude Code's scheduling, hooks, and CLI mode enable automated pipelines that run without human intervention. This is Claude Code at its most powerful: autonomous development workflows.

---

## CLI / Non-Interactive Mode

The foundation of automation: running Claude without a human in the loop.

```bash
# Basic non-interactive run
claude --non-interactive "run the test suite and report results"

# With specific permissions (skip confirmation prompts)
claude --permission-mode auto --non-interactive "update all npm packages and run tests"

# Pipe output for use in scripts
RESULT=$(claude --non-interactive "analyze src/ for unused exports" 2>&1)
echo "$RESULT" | grep "UNUSED:"
```

---

## Scheduled Tasks

### Cron-Based Scheduling

```bash
# crontab -e

# Daily dependency check at 9am
0 9 * * * cd /path/to/project && claude --non-interactive "/audit" >> ~/.claude/logs/audit-$(date +\%Y\%m\%d).log 2>&1

# Weekly code quality report (Monday 8am)
0 8 * * 1 cd /path/to/project && claude --non-interactive "generate a code quality report: dead code, complexity hotspots, test coverage gaps" | mail -s "Weekly Code Report" team@yourcompany.com

# Nightly dependency updates (2am)
0 2 * * * cd /path/to/project && claude --non-interactive "check for safe minor/patch npm updates and create a PR if any found"
```

### Claude Code's Built-in Scheduling

```bash
# Schedule via Claude's schedule skill
claude "schedule: every Monday at 9am, run /audit and post results to Slack #eng-alerts"

# One-time scheduled task
claude "schedule: at 3pm today, remind me to review the PR from the auth feature branch"
```

---

## Pre-Commit Pipeline

Integrate Claude into your git hooks for automated pre-commit review:

```bash
# .git/hooks/pre-commit (or .husky/pre-commit)
#!/bin/bash

echo "Running Claude Code pre-commit review..."

# Get staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(ts|tsx|js|jsx)$')

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# Run security check on staged files
RESULT=$(claude --non-interactive \
  "Review these staged files for critical issues ONLY (security vulnerabilities, syntax errors, obvious bugs). 
  Files: $STAGED_FILES
  Output: PASS if no critical issues, or FAIL: [brief reason] if critical issues found.
  Be fast and conservative — only block for real problems." 2>&1)

if echo "$RESULT" | grep -q "^FAIL:"; then
  echo "❌ Claude Code pre-commit check failed:"
  echo "$RESULT" | grep "^FAIL:"
  exit 1
fi

echo "✅ Claude Code pre-commit check passed"
exit 0
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  claude-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # need full history for diff

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Run Claude Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Get the diff
          git diff origin/main...HEAD > /tmp/pr-diff.txt
          
          # Run review
          REVIEW=$(claude --non-interactive \
            "Review this PR diff for: security vulnerabilities, breaking changes, missing tests.
            Format output as GitHub review comments: FILE:LINE SEVERITY: description.
            Diff: $(cat /tmp/pr-diff.txt)" 2>&1)
          
          echo "$REVIEW" >> $GITHUB_STEP_SUMMARY

      - name: Post Review Comment
        uses: actions/github-script@v7
        with:
          script: |
            const review = process.env.REVIEW_RESULT;
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## Claude Code Review\n\n${review}`
            });
```

---

## Automated Dependency Management

```bash
#!/bin/bash
# scripts/auto-update-deps.sh

cd /path/to/project

echo "Checking for npm updates..."

# Get outdated packages
OUTDATED=$(npm outdated --json 2>/dev/null)

if [ -z "$OUTDATED" ] || [ "$OUTDATED" = "{}" ]; then
  echo "All packages up to date"
  exit 0
fi

# Ask Claude to assess and create a PR
claude --non-interactive \
  "Outdated npm packages: $OUTDATED
  
  Task:
  1. Update only packages where the change is MINOR or PATCH (not MAJOR)
  2. Run npm test after updates
  3. If tests pass, create a PR titled 'chore: update npm dependencies'
  4. If tests fail, revert the failing package and note it in the PR description
  
  Do not update major versions — those need manual review."
```

---

## Monitoring-Triggered Automation

Trigger Claude when monitoring alerts fire:

```bash
#!/bin/bash
# scripts/alert-handler.sh
# Called by PagerDuty/OpsGenie/etc. when an alert fires

ALERT_NAME="$1"
ALERT_DETAILS="$2"
SERVICE="$3"

echo "Alert received: $ALERT_NAME for $SERVICE"

# Ask Claude to investigate
claude --non-interactive \
  "Production alert triggered:
  Service: $SERVICE
  Alert: $ALERT_NAME
  Details: $ALERT_DETAILS
  
  1. Check recent git commits for $SERVICE that might have caused this
  2. Look for any obvious issues in the relevant code
  3. Check if there's a quick fix or if this needs immediate human attention
  4. Output: CRITICAL (wake someone up) / INVESTIGATE (add to queue) / FALSE_POSITIVE
  
  Be conservative — when in doubt, output CRITICAL." 2>&1 | \
  tee -a /var/log/claude-alerts.log
```

---

## Pipeline Design Principles

**Fail fast, fail loudly**: Automated pipelines should fail loudly with actionable output. Silent failures are worse than no automation.

**Idempotent operations**: Every pipeline step should be safe to run twice. If the PR already exists, don't create another one.

**Dry run mode**: For destructive or irreversible operations, always build a `--dry-run` mode that shows what would happen without doing it.

**Rate limiting**: Add delays and checks to prevent runaway automation. Don't create 50 PRs if a check finds 50 issues.

**Human in the loop for high stakes**: Automated review → OK. Automated merge to main → needs safeguards and human approval.

```bash
# Always add a human approval gate before irreversible actions in automation
if [ "$AUTO_APPROVE" != "true" ]; then
  read -p "Claude wants to run database migration. Approve? (yes/no): " CONFIRM
  [ "$CONFIRM" != "yes" ] && exit 1
fi
```
