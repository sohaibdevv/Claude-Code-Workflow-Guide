#!/bin/bash
# Pre-bash security hook
# Blocks dangerous shell commands before Claude executes them
# Install: chmod +x this file, reference in .claude/settings.json

COMMAND=$(cat | jq -r '.command // empty' 2>/dev/null)
[ -z "$COMMAND" ] && exit 0

# Block force push to protected branches
if echo "$COMMAND" | grep -qE "git push.*(--force|-f).*(main|master|production|prod)"; then
  echo "BLOCKED: Force push to protected branch"
  exit 2
fi

# Block dangerous recursive deletes
if echo "$COMMAND" | grep -qE "rm\s+(-rf|-fr)\s+(/|~/|~$|\.\.$)"; then
  echo "BLOCKED: Dangerous recursive delete from root/home/parent"
  exit 2
fi

# Block pipe-to-shell (supply chain attack vector)
if echo "$COMMAND" | grep -qE "(curl|wget).+\|\s*(ba)?sh"; then
  echo "BLOCKED: Pipe-to-shell commands not allowed"
  exit 2
fi

# Block eval/exec with user-controlled input (injection risk)
if echo "$COMMAND" | grep -qE "^\s*(eval|exec)\s+"; then
  echo "BLOCKED: eval/exec commands not allowed"
  exit 2
fi

# Block raw SQL DROP/TRUNCATE outside of explicit migration context
if echo "$COMMAND" | grep -qiE "(DROP\s+(TABLE|DATABASE)|TRUNCATE\s+TABLE)" && \
   ! echo "$COMMAND" | grep -q "migrate"; then
  echo "BLOCKED: Direct DROP/TRUNCATE SQL - use migration scripts"
  exit 2
fi

# Allow everything else
exit 0
