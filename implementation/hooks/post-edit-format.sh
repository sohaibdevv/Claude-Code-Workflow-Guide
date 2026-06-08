#!/bin/bash
# Post-edit auto-format hook
# Automatically formats files after Claude edits them
# Install: chmod +x this file, reference in .claude/settings.json PostToolUse

TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)

[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.scss|*.md|*.yaml|*.yml)
    if command -v prettier &>/dev/null; then
      prettier --write "$FILE" 2>/dev/null && echo "Formatted: $FILE"
    fi
    ;;

  *.py)
    if command -v black &>/dev/null; then
      black --quiet "$FILE" 2>/dev/null && echo "Formatted: $FILE"
    elif command -v autopep8 &>/dev/null; then
      autopep8 --in-place "$FILE" 2>/dev/null
    fi
    ;;

  *.go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE" 2>/dev/null && echo "Formatted: $FILE"
    fi
    ;;

  *.rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE" 2>/dev/null && echo "Formatted: $FILE"
    fi
    ;;

  *.rb)
    if command -v rubocop &>/dev/null; then
      rubocop --autocorrect --no-color "$FILE" 2>/dev/null
    fi
    ;;
esac

exit 0
