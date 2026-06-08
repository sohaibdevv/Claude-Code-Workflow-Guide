# Settings & Permissions — Complete Control Guide

The `settings.json` files are the control plane for Claude Code. They define what Claude can do, what model it uses, how it behaves, and what hooks fire. Mastering them gives you precise control over every aspect of how Claude operates.

---

## Settings File Hierarchy

```
~/.claude/settings.json           ← Global (all projects)
~/.claude/settings.local.json     ← Global local overrides (not synced)
<project>/.claude/settings.json   ← Project (committed to git, shared)
<project>/.claude/settings.local.json ← Project local (gitignored, personal)
```

**Load order**: global → global local → project → project local  
Later files win. A project setting overrides a global setting.

**What to put where:**
- Global: Personal preferences, personal allowed tools, global hooks
- Project: Team-shared rules, project-specific permissions, shared hooks
- Local: Your personal overrides that differ from the team

---

## Full Settings Schema

```json
{
  // ─────────────────────────────────────────────────────
  // MODEL CONFIGURATION
  // ─────────────────────────────────────────────────────
  
  "model": "claude-sonnet-4-6",
  // Options: "claude-opus-4-7", "claude-sonnet-4-6", "claude-haiku-4-5-20251001"
  
  // ─────────────────────────────────────────────────────
  // OUTPUT STYLE
  // ─────────────────────────────────────────────────────
  
  "outputStyle": "concise",
  // Options: "concise" (default) | "explanatory" (more verbose with reasoning)
  
  // ─────────────────────────────────────────────────────
  // PERMISSION MODE
  // ─────────────────────────────────────────────────────
  
  "permissionMode": "default",
  // Options:
  // "auto"    — no prompts, approve everything (use carefully)
  // "default" — prompt for potentially risky operations
  // "strict"  — prompt for most operations
  
  // ─────────────────────────────────────────────────────
  // TOOL PERMISSIONS
  // ─────────────────────────────────────────────────────
  
  "allowedTools": [
    // Exact tool name — allows all uses
    "Read",
    "Edit",
    "Write",
    
    // Tool with pattern — allows matching commands
    "Bash(git *)",
    "Bash(npm test*)",
    "Bash(npm run *)",
    "Bash(find . *)",
    "Bash(grep *)",
    "Bash(ls *)",
    "Bash(cat *)",
    "Bash(npx jest*)"
  ],
  
  "blockedTools": [
    // Block dangerous operations even in auto mode
    "Bash(rm -rf /*)",
    "Bash(git push --force*)",
    "Bash(git reset --hard*)",
    "Bash(eval *)",
    "Bash(curl * | bash*)",
    "Bash(wget * | sh*)",
    "Bash(DROP *)",
    "Bash(TRUNCATE *)"
  ],
  
  // ─────────────────────────────────────────────────────
  // ENVIRONMENT VARIABLES
  // ─────────────────────────────────────────────────────
  
  "env": {
    "NODE_ENV": "development",
    "LOG_LEVEL": "debug"
    // Never put secrets here — use ${ENV_VAR} references instead
  },
  
  // ─────────────────────────────────────────────────────
  // MCP SERVERS
  // ─────────────────────────────────────────────────────
  
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  },
  
  // ─────────────────────────────────────────────────────
  // HOOKS
  // ─────────────────────────────────────────────────────
  
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...],
    "SubagentStop": [...],
    "Notification": [...]
  }
}
```

---

## Permission Strategies by Use Case

### Read-Only Analysis
For sessions where you want Claude to explore but not change anything:

```json
{
  "permissionMode": "strict",
  "allowedTools": [
    "Read",
    "Bash(git log*)", "Bash(git diff*)", "Bash(git status)",
    "Bash(find . *)", "Bash(grep *)", "Bash(cat *)", "Bash(ls *)",
    "Bash(wc *)", "Bash(head *)", "Bash(tail *)"
  ],
  "blockedTools": ["Edit", "Write", "Bash(git commit*)", "Bash(npm*)", "Bash(rm*)"]
}
```

### TDD Development
Allow code editing and test running, block deployment:

```json
{
  "allowedTools": [
    "Read", "Edit", "Write",
    "Bash(npm test*)", "Bash(npx jest*)", "Bash(npm run test*)",
    "Bash(git status)", "Bash(git diff*)", "Bash(git add *)", "Bash(git commit*)"
  ],
  "blockedTools": [
    "Bash(npm run deploy*)", "Bash(git push*)",
    "Bash(rm *)", "Bash(rm -rf*)"
  ]
}
```

### Full Trust (CI/CD or trusted automation)
For automated pipelines where you've verified the workflow:

```json
{
  "permissionMode": "auto",
  "blockedTools": [
    "Bash(rm -rf /*)",
    "Bash(git push --force*)",
    "Bash(DROP TABLE*)",
    "Bash(curl * | bash*)"
  ]
}
```

### Security Audit
Lock down everything, allow only read operations:

```json
{
  "permissionMode": "strict",
  "allowedTools": ["Read", "Bash(grep *)", "Bash(find . *)"],
  "blockedTools": ["Edit", "Write", "Bash(*)"]
}
```

---

## Tool Pattern Matching

Allowed/blocked tool patterns support glob-style matching:

```
"Bash(git *)"         → matches: git status, git diff, git log, etc.
"Bash(npm test*)"     → matches: npm test, npm test:unit, npm test -- --watch
"Bash(git push*)"     → matches: git push, git push origin main, git push --force
"Bash(*)"             → matches all bash commands
"Bash(rm -rf /*)"     → exact match only (no glob)
```

**Specificity rule**: More specific rules take precedence.
```json
{
  "allowedTools": ["Bash(git *)"],   // allows git commands
  "blockedTools": ["Bash(git push --force*)"]  // blocks force push within git
}
```

---

## Protecting Sensitive Files

Use hooks to prevent Claude from reading or modifying sensitive files:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "~/.claude/hooks/protect-sensitive-files.sh"
        }]
      }
    ]
  }
}
```

```bash
#!/bin/bash
# ~/.claude/hooks/protect-sensitive-files.sh

FILE=$(cat | jq -r '.file_path // .path // empty')
[ -z "$FILE" ] && exit 0

SENSITIVE_PATTERNS=(
  ".env"
  ".env.production"
  ".env.*.local"
  "*.pem"
  "*.key"
  "*credentials*"
  "*secrets*"
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if [[ "$FILE" == $pattern ]] || [[ "$(basename "$FILE")" == $pattern ]]; then
    echo "BLOCKED: $FILE matches sensitive file pattern '$pattern'"
    exit 2
  fi
done

exit 0
```

---

## gitignore for Settings

```gitignore
# Always gitignore local settings files
.claude/settings.local.json
~/.claude/settings.local.json
```

```
# Commit these:
.claude/settings.json      ← shared team settings
.claude/commands/          ← shared commands
.claude/agents/            ← shared agent definitions
.claude/skills/            ← shared skills

# Never commit:
.claude/settings.local.json  ← personal overrides
```
