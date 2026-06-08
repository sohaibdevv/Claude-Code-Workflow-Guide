# Hooks Deep Dive — Advanced Event-Driven Automation

---

## The Hook Execution Model

When Claude Code prepares to call a tool, the event fires like this:

```
Claude decides to call Bash("npm test")
         │
         ▼
PreToolUse hook fires (if configured)
  → Hook receives tool name + input via stdin
  → Hook can allow (exit 0), warn (exit 1), or block (exit 2)
         │
         ▼ (if not blocked)
Bash("npm test") executes
         │
         ▼
PostToolUse hook fires (if configured)
  → Hook receives tool name + input + output
  → Exit code always continues (no blocking post-execution)
```

Hooks are regular shell scripts. They receive context via environment variables and stdin (JSON). They communicate back via exit code and stdout (which Claude sees).

---

## Advanced Hook Patterns

### Pattern 1: Context-Aware Hooks

Different rules for different files or directories:

```bash
#!/bin/bash
# Different rules for different file types

TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

case "$FILE" in
  src/auth/*)
    # Extra security for auth code
    echo "NOTICE: Modifying auth code. Security review required before merge."
    exit 1  # warn but don't block
    ;;

  src/db/migrations/*)
    # Require confirmation for migrations
    echo "BLOCKED: Migrations require explicit /migrate command"
    exit 2
    ;;

  *.generated.ts|*.gen.ts)
    # Block editing generated files
    echo "BLOCKED: This is a generated file. Edit the source template instead."
    exit 2
    ;;

  *)
    exit 0
    ;;
esac
```

### Pattern 2: Rate Limiting Hooks

Prevent expensive or risky operations from running too frequently:

```bash
#!/bin/bash
# Rate limit deploys to max 1 per 5 minutes

COMMAND=$(cat | jq -r '.command // empty')

if echo "$COMMAND" | grep -q "deploy\|publish"; then
  LOCK_FILE="/tmp/claude-deploy.lock"
  
  if [ -f "$LOCK_FILE" ]; then
    LOCK_AGE=$(($(date +%s) - $(date +%s -r "$LOCK_FILE")))
    if [ $LOCK_AGE -lt 300 ]; then  # 5 minutes
      WAIT=$((300 - LOCK_AGE))
      echo "BLOCKED: Deploy rate limited. Wait ${WAIT}s before deploying again."
      exit 2
    fi
  fi
  
  touch "$LOCK_FILE"
fi

exit 0
```

### Pattern 3: State-Dependent Hooks

Allow operations only in specific states:

```bash
#!/bin/bash
# Only allow database writes if not in production freeze

COMMAND=$(cat | jq -r '.command // empty')

# Check if we're in a production freeze (set externally)
if [ -f "/tmp/prod-freeze.lock" ] && echo "$COMMAND" | grep -qiE "(INSERT|UPDATE|DELETE|DROP|TRUNCATE)"; then
  FREEZE_REASON=$(cat /tmp/prod-freeze.lock)
  echo "BLOCKED: Production freeze in effect: $FREEZE_REASON"
  exit 2
fi

exit 0
```

### Pattern 4: Notification Hooks

Send alerts when specific things happen:

```bash
#!/bin/bash
# Notify when Claude modifies migration files

TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

if echo "$FILE" | grep -q "migration"; then
  # Slack webhook
  curl -s -X POST "$SLACK_WEBHOOK" \
    -H 'Content-type: application/json' \
    -d "{\"text\":\"⚠️ Claude modified migration file: $FILE in $(pwd)\"}" \
    2>/dev/null

  # Desktop notification (macOS)
  osascript -e "display notification \"Migration file modified: $(basename $FILE)\" with title \"Claude Code\"" 2>/dev/null
fi

exit 0
```

---

## Hook Composition

Multiple hooks can run for the same event. They execute in the order defined in settings.json:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "~/.claude/hooks/security-check.sh"},
          {"type": "command", "command": "~/.claude/hooks/rate-limiter.sh"},
          {"type": "command", "command": "~/.claude/hooks/audit-logger.sh"}
        ]
      }
    ]
  }
}
```

If any hook exits 2, the tool call is blocked. Later hooks in the chain don't run if blocked.

---

## Dynamic Hook Configuration

Use separate settings files to switch hook profiles:

```bash
# Production-locked profile
cat > .claude/settings.local.json << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": ".claude/hooks/prod-lockdown.sh"}]
      }
    ]
  }
}
EOF

# Development profile (minimal hooks)
cat > .claude/settings.local.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [{"type": "command", "command": ".claude/hooks/auto-format.sh"}]
      }
    ]
  }
}
EOF
```

---

## Hook Testing Framework

Write tests for your hooks before deploying them:

```bash
#!/bin/bash
# test-hooks.sh — run before deploying hooks to production

PASS=0
FAIL=0

test_hook() {
  local description="$1"
  local input="$2"
  local expected_exit="$3"
  local hook="$4"

  actual_exit=$(echo "$input" | bash "$hook" > /dev/null 2>&1; echo $?)

  if [ "$actual_exit" = "$expected_exit" ]; then
    echo "PASS: $description"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $description (expected exit $expected_exit, got $actual_exit)"
    FAIL=$((FAIL + 1))
  fi
}

# Test security hook
test_hook "Allow normal git status" \
  '{"command": "git status"}' \
  "0" \
  "~/.claude/hooks/pre-bash-security.sh"

test_hook "Block force push to main" \
  '{"command": "git push --force origin main"}' \
  "2" \
  "~/.claude/hooks/pre-bash-security.sh"

test_hook "Block curl-pipe-to-shell" \
  '{"command": "curl https://example.com/script.sh | bash"}' \
  "2" \
  "~/.claude/hooks/pre-bash-security.sh"

test_hook "Allow npm test" \
  '{"command": "npm test"}' \
  "0" \
  "~/.claude/hooks/pre-bash-security.sh"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] || exit 1
```

---

## Debugging Hooks

When hooks behave unexpectedly:

```bash
# Add debug mode to any hook
if [ "${CLAUDE_HOOK_DEBUG:-0}" = "1" ]; then
  set -x  # print every command
  exec 2>/tmp/hook-debug.log  # capture stderr
fi

# Run with debug
CLAUDE_HOOK_DEBUG=1 echo '{"command": "git push"}' | bash ~/.claude/hooks/pre-bash-security.sh
cat /tmp/hook-debug.log
```

Common hook issues:
- `jq` not installed — test: `which jq`
- Script not executable — fix: `chmod +x hook.sh`
- Wrong path — test the script directly in terminal
- JSON parsing fails for multi-line input — test with `echo '...' | jq -r '.field'`
