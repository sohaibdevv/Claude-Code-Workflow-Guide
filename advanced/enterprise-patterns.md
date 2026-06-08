# Enterprise Patterns — Scaling Claude Code Across Teams

Taking Claude Code from individual usage to team-wide and org-wide adoption requires standardization, governance, and onboarding infrastructure. Here's how to do it right.

---

## Repository Structure for Teams

```
your-repo/
├── CLAUDE.md                    ← Project-wide rules (committed)
├── .claude/
│   ├── settings.json            ← Team-wide permissions (committed)
│   ├── settings.local.json      ← Personal overrides (gitignored)
│   ├── commands/                ← Shared slash commands (committed)
│   │   ├── plan.md
│   │   ├── ship.md
│   │   ├── review.md
│   │   └── ...
│   ├── agents/                  ← Shared agent definitions (committed)
│   │   ├── architect.md
│   │   └── reviewer.md
│   └── skills/                  ← Shared skills (committed)
│       └── deploy/
└── scripts/
    └── claude-setup.sh          ← Onboarding script
```

The `.claude/` directory (except `*.local.json`) is committed to git. Every engineer on the team gets the same commands, agents, skills, and settings.

---

## The Settings Split

**What goes in committed `settings.json` (team-wide):**
```json
{
  "blockedTools": ["Bash(rm -rf /*)", "Bash(git push --force*)"],
  "mcpServers": {
    "github": { ... }
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [{"type": "command", "command": ".claude/hooks/post-edit.sh"}]
      }
    ]
  }
}
```

**What goes in gitignored `settings.local.json` (personal):**
```json
{
  "model": "claude-opus-4-7",
  "outputStyle": "explanatory",
  "allowedTools": [
    "Bash(git *)",
    "Bash(npm *)"
  ]
}
```

This way the team enforces security policies (committed) while individuals can customize their experience (local).

---

## Onboarding Script

New engineers should be productive with Claude Code on day one:

```bash
#!/bin/bash
# scripts/claude-setup.sh

set -e

echo "Setting up Claude Code for this project..."

# Check Claude Code is installed
if ! command -v claude &>/dev/null; then
  echo "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
fi

# Check API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "ERROR: ANTHROPIC_API_KEY not set"
  echo "Get your key at: console.anthropic.com"
  exit 1
fi

# Install required MCP server dependencies
echo "Installing MCP dependencies..."
npx -y @modelcontextprotocol/server-github > /dev/null 2>&1 || true
npx -y @modelcontextprotocol/server-postgres > /dev/null 2>&1 || true

# Set up hooks directory
mkdir -p ~/.claude/hooks
cp .claude/hooks-templates/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
echo "Hooks installed."

# Set up personal settings template
if [ ! -f .claude/settings.local.json ]; then
  cp .claude/settings.local.json.template .claude/settings.local.json
  echo "Personal settings template created at .claude/settings.local.json"
  echo "Edit it to set your preferred model and style."
fi

# Verify setup
echo ""
echo "✓ Claude Code setup complete!"
echo ""
echo "Quick start:"
echo "  claude             — start a session"
echo "  claude /help       — see available commands"
echo "  claude /plan [task] — plan before executing"
echo "  claude /review     — review your changes"
echo ""
echo "Project commands: /plan /ship /review /debug /audit /spec /docs /refactor"
```

---

## Team Command Playbook

Create a living document of commands and their intended use:

```markdown
# Claude Code Playbook — [Team Name]

## Starting Work
- `claude /plan "feature description"` — plan before coding
- `claude /spec "feature description"` — generate detailed spec first

## During Development
- `claude /debug "error description"` — systematic debugging
- `claude /review` — self-review before pushing

## Before Merging
- `claude /ship` — full pre-ship checklist
- `claude /audit` — security and quality audit

## Special Workflows
- `/tdd "feature"` — test-driven development spiral
- `/refactor "target"` — safe refactoring with checklist

## When Things Go Wrong
- `/rollback` — guided rollback procedure
- `/incident "description"` — incident investigation workflow
```

---

## Governance: Approved Tools and Patterns

Define what's approved and what needs review:

```markdown
# Claude Code Governance

## Approved MCP Servers
The following MCP servers are approved for use:
- @modelcontextprotocol/server-github — GitHub integration
- @modelcontextprotocol/server-postgres — Read-only DB access
- @modelcontextprotocol/server-filesystem — Extended file access

## MCP Server Approval Process
Any non-listed MCP server requires security review before use.
Open a ticket in Linear project "PLATFORM" to request approval.

## Approved Use Cases
- Code review and quality analysis
- Feature implementation with human approval
- Test generation
- Documentation generation
- Automated dependency updates (minor/patch only)

## Requires Human Approval
- Database migrations
- Production deployments
- Changes to auth/security code
- Major version dependency upgrades

## Prohibited Automated Uses
- Automated PRs merging without human review
- Running in production environments
- Access to production databases (staging OK)
- Changes to payment processing code
```

---

## Metrics and Visibility

Track Claude Code adoption and impact across the team:

```bash
# ~/.claude/hooks/team-metrics.sh
# Track usage patterns (no code content, just metadata)

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOOL="${CLAUDE_TOOL_NAME:-unknown}"
USER=$(whoami)
DIR_HASH=$(echo "$(pwd)" | sha256sum | head -c 8)

# Send to internal metrics system
curl -s -X POST "$METRICS_ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "{\"timestamp\":\"$TIMESTAMP\",\"tool\":\"$TOOL\",\"user\":\"$USER\",\"project\":\"$DIR_HASH\"}" \
  2>/dev/null || true

exit 0
```

Useful metrics to track:
- Sessions per engineer per week
- Most used commands
- Average session length
- Feature completion velocity (before/after adoption)

---

## Common Enterprise Objections and Answers

**"We can't put our code in an AI model"**
Claude Code processes your code on Anthropic's servers, but Anthropic's API terms don't use customer data for training (at the API tier). Review and confirm the current terms with your legal team.

**"How do we prevent secrets from leaking?"**
Deploy the secrets protection hook (see security-patterns.md). Block `.env` and credential files. Use read-only database users for MCP. Conduct a secrets audit before enabling.

**"What if Claude deletes something important?"**
Use the blockedTools configuration and hooks to prevent dangerous operations. Maintain good git hygiene (frequent commits). For automated pipelines, require human approval for irreversible steps.

**"How do we standardize usage across the team?"**
Commit `.claude/` directory to git. Create an onboarding script. Run a 1-hour team workshop on core patterns. Build a command playbook.
