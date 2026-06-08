#!/bin/bash
# Audit logger hook
# Logs all Claude tool calls for audit and debugging purposes
# Install: chmod +x this file, reference in .claude/settings.json PostToolUse with matcher ".*"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOOL="${CLAUDE_TOOL_NAME:-unknown}"
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/audit-$(date +%Y%m%d).log"

mkdir -p "$LOG_DIR"

# Read and sanitize tool input
RAW_INPUT=$(cat)
SANITIZED=$(echo "$RAW_INPUT" | \
  jq -c . 2>/dev/null | \
  sed 's/"password":"[^"]*"/"password":"[REDACTED]"/g' | \
  sed 's/"secret":"[^"]*"/"secret":"[REDACTED]"/g' | \
  sed 's/"token":"[^"]*"/"token":"[REDACTED]"/g' | \
  sed 's/"api_key":"[^"]*"/"api_key":"[REDACTED]"/g' | \
  cut -c1-400)

DIR=$(pwd | sed "s|$HOME|~|")

echo "$TIMESTAMP [$TOOL] dir=$DIR input=$SANITIZED" >> "$LOG_FILE"

exit 0
