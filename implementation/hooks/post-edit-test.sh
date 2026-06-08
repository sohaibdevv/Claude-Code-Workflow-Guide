#!/bin/bash
# Post-edit test runner hook
# Runs related tests after Claude edits a source file
# Install: chmod +x this file, reference in .claude/settings.json PostToolUse

TOOL_INPUT=$(cat)
FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null)

[ -z "$FILE" ] || [ ! -f "$FILE" ] && exit 0

# Skip test files (we don't want to run tests when tests are edited)
if echo "$FILE" | grep -qE "\.(test|spec)\.(ts|tsx|js|jsx|py)$"; then
  exit 0
fi

# Skip non-source files
if ! echo "$FILE" | grep -qE "\.(ts|tsx|js|jsx|py|go|rb)$"; then
  exit 0
fi

# Navigate to git root
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$GIT_ROOT" || exit 0

echo "Running related tests for: $FILE"

# Node/TypeScript projects
if [ -f "package.json" ]; then
  if command -v npx &>/dev/null; then
    npx jest --findRelatedTests "$FILE" --passWithNoTests --silent 2>&1 | \
      grep -E "(PASS|FAIL|Tests:|✓|✕|×)" | tail -10
  fi

# Python projects
elif [ -f "pytest.ini" ] || [ -f "setup.cfg" ] || [ -f "pyproject.toml" ]; then
  if command -v pytest &>/dev/null; then
    pytest --quiet --tb=short "$FILE" 2>&1 | tail -10
  fi

# Go projects
elif [ -f "go.mod" ]; then
  if command -v go &>/dev/null; then
    PKG=$(dirname "$FILE" | sed "s|$GIT_ROOT/||")
    go test "./$PKG/..." 2>&1 | tail -10
  fi
fi

exit 0
