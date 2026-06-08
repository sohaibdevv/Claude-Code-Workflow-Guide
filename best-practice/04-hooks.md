# Hooks — Event-Driven Automation for Claude Code

Hooks are shell scripts that Claude Code executes automatically at lifecycle events. They're the most powerful mechanism for enforcing consistent behavior, automating repetitive tasks, and adding guardrails to Claude's actions.

---

## Hook Events Reference

| Event | Fires When | Common Use |
|---|---|---|
| `PreToolUse` | Before any tool call | Validation, blocking, logging |
| `PostToolUse` | After any tool call | Auto-formatting, notifications |
| `Stop` | Claude finishes responding | Summary generation, cleanup |
| `SubagentStop` | A subagent completes | Collect results, log output |
| `Notification` | Claude sends a notification | Route alerts to your tools |

---

## Hook Configuration

Hooks live in `settings.json`. They can be global (`~/.claude/settings.json`) or project-scoped (`.claude/settings.json`).

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/pre-bash.sh"
          }
        ]
      },
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/pre-edit.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/post-all.sh"
          }
        ]
      }
    ]
  }
}
```

**Matchers** are regex patterns matched against the tool name: `Bash`, `Edit`, `Write`, `Read`, `.*` (all tools).

---

## Exit Code Semantics

| Exit Code | Meaning |
|---|---|
| `0` | Success — continue normally |
| `1` | Error/warning — Claude sees output, continues |
| `2` | **Block** — tool call is cancelled (PreToolUse only) |

Exit code 2 is powerful but use it sparingly. Blocking too aggressively makes Claude unable to do its job.

---

## Environment Variables Available in Hooks

Hook scripts receive context via environment variables and stdin:

```bash
# Available in hooks:
CLAUDE_TOOL_NAME      # Name of the tool being called
CLAUDE_TOOL_INPUT     # JSON of the tool input (read via jq)

# Read via stdin:
cat  # Receives the full tool call as JSON
```

Example: reading tool input in a hook:
```bash
#!/bin/bash
TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')
```

---

## Essential Hooks to Set Up

### 1. Security Guard (PreToolUse)

```bash
#!/bin/bash
# ~/.claude/hooks/pre-bash-security.sh

COMMAND=$(cat | jq -r '.command // empty')

# Block force push to main
if echo "$COMMAND" | grep -qE "git push.*(--force|-f).*(main|master)"; then
  echo "BLOCKED: Force push to main/master is not allowed"
  exit 2
fi

# Block dangerous recursive deletes
if echo "$COMMAND" | grep -qE "rm\s+(-rf|-fr)\s+/[^t]"; then
  echo "BLOCKED: Potentially dangerous recursive delete"
  exit 2
fi

# Block pipe-to-shell patterns
if echo "$COMMAND" | grep -qE "(curl|wget).*\|\s*(ba)?sh"; then
  echo "BLOCKED: Pipe-to-shell commands are not allowed"
  exit 2
fi

exit 0
```

### 2. Auto-Format After Edit (PostToolUse)

```bash
#!/bin/bash
# ~/.claude/hooks/post-edit-format.sh

TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

[ -z "$FILE" ] && exit 0

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
    if command -v prettier &>/dev/null; then
      prettier --write "$FILE" 2>/dev/null
    fi
    ;;
  *.py)
    if command -v black &>/dev/null; then
      black --quiet "$FILE" 2>/dev/null
    fi
    ;;
  *.go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE" 2>/dev/null
    fi
    ;;
  *.rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE" 2>/dev/null
    fi
    ;;
esac

exit 0
```

### 3. Auto-Run Related Tests (PostToolUse)

```bash
#!/bin/bash
# ~/.claude/hooks/post-edit-test.sh

TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

[ -z "$FILE" ] && exit 0

# Skip test files themselves and non-source files
if echo "$FILE" | grep -qE "\.(test|spec)\.(ts|js|tsx|jsx)$"; then
  exit 0
fi

# Only run for source files
if echo "$FILE" | grep -qE "\.(ts|tsx|js|jsx)$"; then
  echo "Running related tests for $FILE..."
  cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  npx jest --findRelatedTests "$FILE" --passWithNoTests --silent 2>&1 | tail -10
fi

exit 0
```

### 4. Audit Logger (PostToolUse — all tools)

```bash
#!/bin/bash
# ~/.claude/hooks/audit-logger.sh

TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
TOOL_INPUT=$(cat)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="$HOME/.claude/audit.log"

# Log to file (truncate tool input to 200 chars)
SHORT_INPUT=$(echo "$TOOL_INPUT" | jq -c . | cut -c1-200)
echo "$TIMESTAMP [$TOOL_NAME] $SHORT_INPUT" >> "$LOG_FILE"

exit 0
```

### 5. Session Summary on Stop

```bash
#!/bin/bash
# ~/.claude/hooks/session-summary.sh

TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
SESSION_FILE="$HOME/.claude/sessions/$(date +%Y%m%d).md"
mkdir -p "$(dirname "$SESSION_FILE")"

echo "" >> "$SESSION_FILE"
echo "## Session: $TIMESTAMP" >> "$SESSION_FILE"
echo "Directory: $(pwd)" >> "$SESSION_FILE"
echo "Git status: $(git status --short 2>/dev/null | head -5 || echo 'not a git repo')" >> "$SESSION_FILE"

exit 0
```

---

## Hook Development Best Practices

### Test Hooks Independently
```bash
# Simulate what Claude Code passes to your hook
echo '{"command": "rm -rf /tmp/test"}' | bash ~/.claude/hooks/pre-bash-security.sh
echo $?  # Should be 2 (blocked)

echo '{"command": "npm test"}' | bash ~/.claude/hooks/pre-bash-security.sh
echo $?  # Should be 0 (allowed)
```

### Keep Hooks Fast
Hooks run on every tool call. If your PostToolUse hook takes 5 seconds, every file edit adds 5 seconds of latency. Keep hooks under 500ms for routine operations.

### Make Hooks Idempotent
Hooks may run multiple times for the same file. Formatting a file twice should produce the same result as formatting it once.

### Don't Put Logic in Hooks
Hooks are policy enforcement, not business logic. If a hook is getting complex, it's a sign the logic belongs in a command or skill.

---

## Hook Debugging

When a hook blocks something unexpectedly:

```bash
# Add verbose logging to your hook temporarily
set -x  # print every command as it runs
# ... your hook logic ...
set +x
```

```bash
# Check what input your hook actually receives
cat > /tmp/test-hook.sh << 'EOF'
#!/bin/bash
INPUT=$(cat)
echo "HOOK RECEIVED: $INPUT" >&2
echo "TOOL NAME: $CLAUDE_TOOL_NAME" >&2
exit 0
EOF
chmod +x /tmp/test-hook.sh
```
