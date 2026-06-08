<div align="center">

# Claude Code — Practical patterns for real-world use

**A friendly guide for using Claude Code in projects and teams**
*Workflows, tools, and guardrails that help you stay productive and in control.*

[![Stars](https://img.shields.io/github/stars/vignesh2027/claude-best-practice?style=for-the-badge&color=gold)](https://github.com/vignesh2027/claude-best-practice/stargazers)
[![Forks](https://img.shields.io/github/forks/vignesh2027/claude-best-practice?style=for-the-badge&color=blue)](https://github.com/vignesh2027/claude-best-practice/network)
[![License](https://img.shields.io/github/license/vignesh2027/claude-best-practice?style=for-the-badge)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge)](CONTRIBUTING.md)
[![Last Updated](https://img.shields.io/badge/Updated-May%202026-purple?style=for-the-badge)]()

> Practical, grounded guidance for working with Claude Code.

</div>

---

## 📖 Table of Contents

- [Why This Guide Exists](#-why-this-guide-exists)
- [What is Claude Code?](#-what-is-claude-code)
- [Architecture Overview](#-architecture-overview)
- [Quick Start](#-quick-start)
- [Core Concepts](#-core-concepts)
  - [Context Management](#1-context-management)
  - [Plan Mode](#2-plan-mode)
  - [Subagents](#3-subagents)
  - [Commands](#4-commands)
  - [Skills](#5-skills)
  - [Hooks](#6-hooks)
  - [MCP Servers](#7-mcp-servers)
  - [Memory System](#8-memory-system)
  - [Settings & Permissions](#9-settings--permissions)
- [Advanced Patterns](#-advanced-patterns)
  - [Multi-Agent Teams](#multi-agent-teams)
  - [Cross-Model Routing](#cross-model-routing)
  - [Automated Pipelines](#automated-pipelines)
  - [Security Patterns](#security-patterns)
  - [Enterprise Patterns](#enterprise-patterns)
- [Development Workflows](#-development-workflows)
  - [Boris Cherny Creator Workflow](#boris-cherny-creator-workflow)
  - [Verification Loops](#verification-loops--the-1-quality-multiplier)
  - [Real-World Team Patterns](#real-world-team-patterns)
  - [Babysit PRs](#babysit-prs--automated-pr-management)
  - [Batch Migrations](#batch-migrations)
- [Orchestration Patterns](#-orchestration-patterns)
- [Tips & Tricks (190+)](#-tips--tricks-190)
- [CLAUDE.md Mastery](#-claudemd-mastery)
- [Model Selection Strategy](#-model-selection-strategy)
- [Session Management](#-session-management)
- [Debugging Claude Code](#-debugging-claude-code)
- [Performance Optimization](#-performance-optimization)
- [Security Best Practices](#-security-best-practices)
- [Team & Enterprise Usage](#-team--enterprise-usage)
- [Directory Structure](#-directory-structure)
- [Contributing](#-contributing)

---

## 🎯 Why This Guide Exists

Claude Code can do a lot, and it works best when you have practical patterns to follow.
This guide focuses on useful workflows, safety habits, and repeatable setups you can apply right away.

What you’ll find here:

- Clear examples of how to structure Claude Code projects
- Practical anti-patterns so you can avoid common mistakes
- Workflows for commands, skills, hooks, and subagents
- Advice for solo projects and team environments

Whether you are exploring Claude Code for the first time or looking to make it more reliable in a project, this guide is meant to be easy to use and realistic.

---

## 🧠 What is Claude Code?

Claude Code connects a Claude model to your repository, shell, and project configuration.
It helps you ask the model to interact with real files, run commands, and follow coding workflows.

Claude Code can:

- Read and edit your source files directly
- Run shell commands like tests, builds, and lint checks
- Coordinate multi-file changes in a codebase
- Support structured workflows with subagents and plan mode
- Integrate external tools through MCP (Model Context Protocol)
- Work with shared project settings, hooks, and guardrails

### Core capabilities at a glance

- Full access to repository files
- Shell and tool integration
- Reusable command and skill workflows
- Context-aware automation with hooks
- External tool access through MCP servers

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLAUDE CODE SYSTEM                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   USER INPUT                                                        │
│      │                                                              │
│      ▼                                                              │
│   ┌──────────────────────────────────────────────────────────────┐ │
│   │                    CLAUDE ORCHESTRATOR                        │ │
│   │  • Reads CLAUDE.md (project context)                         │ │
│   │  • Applies settings.json (permissions/model/style)           │ │
│   │  • Fires pre-tool hooks                                      │ │
│   │  • Routes to subagents / invokes tools                       │ │
│   └──────────┬───────────────────────────────────────────────────┘ │
│              │                                                       │
│     ┌────────┼────────────────────────────────────┐                │
│     ▼        ▼                    ▼                ▼                │
│  ┌──────┐ ┌──────┐           ┌────────┐       ┌────────┐           │
│  │ Read │ │ Edit │           │  Bash  │       │  MCP   │           │
│  │ File │ │ File │           │ Shell  │       │ Tools  │           │
│  └──────┘ └──────┘           └────────┘       └────────┘           │
│                                                                     │
│   SUBAGENTS (isolated context windows)                              │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐             │
│   │ Explore  │ │ Planner  │ │  Coder   │ │ Reviewer │             │
│   │  Agent   │ │  Agent   │ │  Agent   │ │  Agent   │             │
│   └──────────┘ └──────────┘ └──────────┘ └──────────┘             │
│                                                                     │
│   HOOKS (event-driven automation)                                   │
│   PreToolUse → PostToolUse → Stop → SubagentStop                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Installation
```bash
# Install Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Or use the VS Code / JetBrains extension
# Or access via claude.ai/code
```

### Your First Session
```bash
# Navigate to your project
cd my-project

# Start Claude Code
claude

# Or start with a specific task
claude "explain the architecture of this codebase"

# Enable plan mode for complex tasks
claude --plan "refactor the authentication system"
```

### Essential First Setup
```bash
# Initialize CLAUDE.md for your project
claude /init

# Check settings
claude /config

# View available commands
claude /help
```

---

## 📚 Core Concepts

### 1. Context Management

Context matters in Claude Code. If your sessions get too large, output quality can drop.

#### The Context Budget

Claude Code operates within a token context window. Think of it like RAM — finite, precious, and easy to exhaust.

```
Context Window
├── System prompt (CLAUDE.md + settings)    ~5-10%
├── Conversation history                    grows with each turn
├── File contents (read files)              can be large
├── Tool outputs (bash, search results)     often very large
└── Available for response                  shrinks as above grows
```

#### Context Health Rules

**Rule 1: The 30% Rule**
Keep your context utilization below 30-40%. Above this threshold, Claude starts "forgetting" earlier context and output quality degrades.

```
0%  ────────────────────── 30% ──────────── 60% ──── 80% ── 100%
     IDEAL ZONE              WARNING        DANGER   CRITICAL
```

**Rule 2: Rewind Don't Correct**
When Claude makes a mistake mid-task, don't keep piling on corrections. The corrections consume context AND confuse the model. Instead:
- Press `ESC` to interrupt
- Use `/rewind` to go back to the last clean state
- Re-issue the instruction with more specificity

**Rule 3: Fresh Sessions for Fresh Tasks**
```bash
# Wrong: Continuing from a long session for an unrelated task
# (you're now paying the cost of all that prior context)

# Right: New task = new session
claude /clear
claude "new task here"

# Or use /compact to summarize and continue
claude /compact "focus on the auth refactor"
```

**Rule 4: Strategic `/compact`**
Use `/compact` with a specific hint so Claude summarizes what matters:
```bash
# Bad (no hint — Claude guesses what to keep)
/compact

# Good (Claude knows what to preserve)
/compact "we're mid-way through the database migration, keep all schema decisions"
```

#### Context-Aware File Reading

Don't read files you don't need. Be surgical:
```
# Instead of asking Claude to read the whole codebase, guide it:
"Read only src/auth/middleware.ts and tell me what token validation logic exists"

# Not:
"Read the codebase and tell me about auth"
```

---

### 2. Plan Mode

Plan Mode is a useful workflow for complex, multi-step tasks. It separates **thinking** from **acting**, helping you avoid premature execution.

#### When to Use Plan Mode

| Task Type | Plan Mode? |
|---|---|
| Simple bug fix (1-2 files) | Optional |
| Feature spanning 3+ files | **Yes** |
| Refactoring/architecture changes | **Yes** |
| Database migrations | **Yes, always** |
| Security-sensitive changes | **Yes, always** |
| Anything you can't easily undo | **Yes** |

#### How to Enter Plan Mode

```bash
# Via CLI flag
claude --plan "migrate the users table to add OAuth columns"

# Via slash command mid-session
/plan

# Via keyboard shortcut
Shift + Tab  # toggle plan/execute mode
```

#### Effective Plan Mode Usage

```
GOOD PLAN WORKFLOW:
1. Enter plan mode
2. State the goal + constraints
3. Review the plan Claude proposes
4. Ask questions / push back on decisions
5. Refine until you're confident
6. Exit plan mode → execute

BAD PLAN WORKFLOW:
1. Skip plan mode
2. Ask Claude to "just do it"
3. Get halfway through, realize the approach was wrong
4. Spend 3x as long cleaning up
```

#### Plan Mode Prompting

```markdown
# Template for complex tasks
I need to [GOAL].

Constraints:
- [constraint 1]
- [constraint 2]

Do NOT touch:
- [file/system to leave alone]

Before executing, give me a step-by-step plan including:
1. Which files will be modified
2. What tests need to run
3. Any risks or irreversible steps
```

---

### 3. Subagents

Subagents are isolated Claude instances with their own context windows. They help keep complex tasks from overwhelming your main context.

#### Why Subagents?

```
WITHOUT SUBAGENTS:
Main Context: [task 1 history] [task 2 history] [task 3 history]
               ─────────────────────────────────────────────────
               Context fills up → quality degrades

WITH SUBAGENTS:
Main Context: [orchestration logic only]  ← stays clean
Subagent 1:   [task 1 isolated]
Subagent 2:   [task 2 isolated]
Subagent 3:   [task 3 isolated]
               Each starts fresh → quality stays high
```

#### Spawning Subagents

```javascript
// In a slash command or skill:
Agent({
  description: "Analyze authentication vulnerabilities",
  subagent_type: "general-purpose",
  prompt: `
    Review src/auth/ for security vulnerabilities.
    Check for: SQL injection, JWT mishandling, session fixation.
    Report findings with file paths and line numbers.
    Do NOT modify any files — research only.
  `
})
```

#### Subagent Types

| Type | Best For |
|---|---|
| `general-purpose` | Research, analysis, multi-step tasks |
| `Explore` | Fast read-only code search (keyword/pattern lookup) |
| `Plan` | Architecture design, implementation planning |
| `claude` | Catch-all for complex tasks needing full capabilities |

#### Subagent Patterns

**Pattern 1: Research → Execute**
```
Subagent 1: Research the codebase, find all auth-related files
Main: Review findings, decide on approach
Subagent 2: Execute the changes based on the research
```

**Pattern 2: Parallel Workers**
```
Subagents 1-3 (parallel): Each handles one module
Main: Collect results, integrate
```

**Pattern 3: Specialist Chain**
```
Architect subagent → designs the solution
Coder subagent    → implements it
Reviewer subagent → checks the implementation
Tester subagent   → writes and runs tests
```

#### Subagent Communication Best Practices

```markdown
# Good subagent prompt structure:
## Context
[What the overall task is]

## Your Specific Job
[Exactly what THIS subagent should do]

## What NOT To Do
[Boundaries — files to leave alone, operations to skip]

## Output Format
[Exactly what to return so the orchestrator can use it]
```

---

### 4. Commands

Commands are slash commands (`/command-name`) that trigger predefined workflows. They're the equivalent of keyboard macros for your development process.

#### Creating a Command

Commands live in `.claude/commands/`. Each `.md` file becomes a `/command-name`.

```markdown
<!-- .claude/commands/ship.md -->
# Ship Feature

Prepare and ship the current feature branch.

## Steps
1. Run tests: `npm test`
2. Run linter: `npm run lint`
3. Check for TODO/FIXME comments
4. Generate a changelog entry
5. Create a PR with description
```

#### Command Categories

**Development Commands**
```
/plan    — enter structured planning mode
/ship    — run checks and create PR
/review  — self-review before submitting
/debug   — systematic debugging workflow
/refactor — safe refactoring checklist
```

**Analysis Commands**
```
/audit      — security audit of changed files
/perf       — performance analysis
/complexity — flag overly complex functions
/dead-code  — find unused code
```

**Documentation Commands**
```
/docs   — generate documentation
/readme — update README
/changelog — generate changelog from git log
```

#### Parameterized Commands

```markdown
<!-- .claude/commands/test-feature.md -->
# Test Feature: $ARGUMENTS

Run comprehensive tests for: $ARGUMENTS

1. Find all test files related to "$ARGUMENTS"
2. Run them with coverage
3. Report any failures with suggested fixes
```

```bash
# Usage:
/test-feature authentication
/test-feature payment-processing
```

#### Dynamic Commands with Shell Output

```markdown
<!-- .claude/commands/context-check.md -->
Current git status:
!`git status`

Recent changes:
!`git diff --stat HEAD~3`

Now review these changes and suggest what to test next.
```

The `!` prefix runs the shell command and injects its output into the prompt.

---

### 5. Skills

Skills are reusable, composable task templates with progressive disclosure. They are often more useful than commands for complex workflows because they support structured context loading.

#### Skill vs Command

| | Command | Skill |
|---|---|---|
| Trigger | `/command-name` | Auto-detected by description |
| Complexity | Simple workflows | Complex, multi-file patterns |
| Context | Inline only | Can reference external docs |
| Composition | Limited | Highly composable |
| Discovery | Manual | AI-matched to task |

#### Skill Structure

```
.claude/skills/
└── deploy/
    ├── SKILL.md           # Main skill definition
    └── references/
        ├── rollback.md    # Referenced if rollback needed
        ├── monitoring.md  # Referenced if monitoring needed
        └── checklist.md   # Referenced for verification
```

```markdown
<!-- .claude/skills/deploy/SKILL.md -->
---
name: production-deploy
description: Use when deploying to production, releasing a version, or shipping to users. Handles pre-deploy checks, deployment, and post-deploy verification.
---

# Production Deployment Skill

## Pre-Deploy Checklist
- [ ] All tests passing: `npm test`
- [ ] No linting errors: `npm run lint`
- [ ] Environment variables verified
- [ ] Database migrations ready

## Deploy
```bash
npm run build
npm run deploy:prod
```

## Post-Deploy Verification
See @references/monitoring.md for health check procedures.

If deploy fails, see @references/rollback.md.
```

#### Writing Effective Skill Descriptions

The `description:` field is critical — it's how Claude decides when to invoke the skill automatically.

```markdown
# BAD — too vague
description: Helps with deployment

# BAD — describes what it does, not when to use it
description: Runs build, tests, and deploys to production

# GOOD — describes triggering conditions
description: Use when the user wants to deploy, release, ship to production,
             push a new version, or go live. Also triggers for rollback
             requests and deployment troubleshooting.
```

#### Progressive Disclosure Pattern

Keep the main SKILL.md concise. Use `@references/` for depth:

```markdown
# Main skill — stays under 50 lines
Core workflow here.

For advanced rollback procedures: @references/rollback.md
For monitoring setup: @references/monitoring.md
For multi-region deploys: @references/multi-region.md
```

Claude only reads referenced files when actually needed, preserving context.

---

### 6. Hooks

Hooks are shell commands that Claude Code executes automatically at specific lifecycle events. They help enforce consistent behavior.

#### Hook Events

| Event | When It Fires | Common Uses |
|---|---|---|
| `PreToolUse` | Before any tool call | Validation, logging, rate limiting |
| `PostToolUse` | After any tool call | Audit logging, notifications |
| `Stop` | When Claude finishes a turn | Summaries, notifications, cleanup |
| `SubagentStop` | When a subagent finishes | Collect results, log output |
| `Notification` | On system notifications | Alert routing |

#### Hook Configuration

```json
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo '[HOOK] Bash command: ' && cat"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/post-edit.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/session-summary.sh"
          }
        ]
      }
    ]
  }
}
```

#### Real Hook Examples

**Auto-run tests after file edits:**
```bash
#!/bin/bash
# ~/.claude/hooks/post-edit.sh
# Runs relevant tests after Claude edits a file

FILE=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty')
if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
  echo "Running tests for $FILE..."
  npx jest --findRelatedTests "$FILE" --passWithNoTests 2>&1 | tail -20
fi
```

**Block dangerous git operations:**
```bash
#!/bin/bash
# ~/.claude/hooks/pre-bash.sh
COMMAND=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.command // empty')

# Block force push to main
if echo "$COMMAND" | grep -q "git push.*--force.*main\|git push.*main.*--force"; then
  echo "BLOCKED: Force push to main is not allowed"
  exit 2  # exit 2 = block the tool call
fi

# Block rm -rf
if echo "$COMMAND" | grep -qE "rm\s+-rf\s+/"; then
  echo "BLOCKED: Dangerous rm -rf command"
  exit 2
fi
```

**Slack notification on task completion:**
```bash
#!/bin/bash
# ~/.claude/hooks/notify-slack.sh
WEBHOOK_URL="$SLACK_WEBHOOK_URL"
MESSAGE="Claude Code task completed in $(pwd)"

curl -s -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"$MESSAGE\"}" \
  "$WEBHOOK_URL"
```

**Auto-format after edit:**
```bash
#!/bin/bash
# ~/.claude/hooks/post-edit-format.sh
FILE=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty')

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx)
    npx prettier --write "$FILE" 2>/dev/null
    ;;
  *.py)
    black "$FILE" 2>/dev/null
    ;;
  *.go)
    gofmt -w "$FILE" 2>/dev/null
    ;;
esac
```

#### Hook Exit Codes

```
exit 0  → Success, continue normally
exit 1  → Warning/error, but continue
exit 2  → BLOCK the tool call entirely (PreToolUse only)
```

---

### 7. MCP Servers

MCP (Model Context Protocol) servers extend Claude Code with external tool capabilities — databases, APIs, cloud services, and more.

#### Built-in MCP Integrations

```json
// .claude/settings.json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/project"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL}"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    }
  }
}
```

#### Popular MCP Servers

| Server | What It Enables |
|---|---|
| `@mcp/server-github` | PR/issue management, code search |
| `@mcp/server-postgres` | Direct database queries |
| `@mcp/server-filesystem` | Expanded file system access |
| `@mcp/server-brave-search` | Web search during tasks |
| `@mcp/server-slack` | Send Slack messages from Claude |
| `@mcp/server-linear` | Ticket management |
| `@mcp/server-sentry` | Error monitoring integration |
| `@mcp/server-datadog` | Metrics and logs |

#### Building a Custom MCP Server

```typescript
// custom-mcp-server.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "my-internal-tools",
  version: "1.0.0"
}, {
  capabilities: { tools: {} }
});

// Register a tool
server.setRequestHandler("tools/list", async () => ({
  tools: [{
    name: "get_deployment_status",
    description: "Check deployment status for a service",
    inputSchema: {
      type: "object",
      properties: {
        service: { type: "string", description: "Service name" }
      },
      required: ["service"]
    }
  }]
}));

server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "get_deployment_status") {
    const { service } = request.params.arguments;
    // Your internal API call here
    const status = await getDeploymentStatus(service);
    return { content: [{ type: "text", text: JSON.stringify(status) }] };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

---

### 8. Memory System

Claude Code's memory system lets it retain information across sessions, building up project-specific knowledge over time.

#### Memory Types

| Type | What to Store | Lifespan |
|---|---|---|
| `user` | Developer preferences, expertise level | Long-term |
| `feedback` | What worked/didn't, style preferences | Long-term |
| `project` | Goals, deadlines, architecture decisions | Medium-term |
| `reference` | External system locations, credentials | Long-term |

#### Memory File Structure

```
~/.claude/projects/<project-slug>/memory/
├── MEMORY.md          ← Index (always loaded)
├── user_profile.md    ← Who the developer is
├── feedback_*.md      ← Style and approach preferences
├── project_*.md       ← Current project context
└── reference_*.md     ← Where things live
```

#### Memory Best Practices

```markdown
# Good memory content (non-obvious facts)
- user prefers explicit error messages over silent failures
- this project uses pessimistic locking for the inventory system
- the CI pipeline takes 12 minutes — don't wait for it before continuing

# Bad memory content (obvious from code)
- project uses React (visible in package.json)
- uses TypeScript (visible in tsconfig.json)
- has a users table (visible in schema)
```

#### Triggering Memory Saves

```
"Remember that I prefer Jest over Vitest for this project"
"Save this: the payment service uses idempotency keys, always check before retrying"
"Note that the staging DB has stale data after 3pm — refresh with dump script"
```

---

### 9. Settings & Permissions

The `settings.json` file is the control plane for Claude Code's behavior. Master it.

#### Settings Hierarchy

```
~/.claude/settings.json          ← Global (all projects)
~/.claude/settings.local.json    ← Global local overrides
.claude/settings.json            ← Project (committed to git)
.claude/settings.local.json      ← Project local (gitignored)
```

Later files override earlier ones. Use project settings for team-shared config, local settings for personal preferences.

#### Full Settings Reference

```json
{
  // Model selection
  "model": "claude-opus-4-7",       // for planning
  // or
  "model": "claude-sonnet-4-6",     // for coding (faster/cheaper)

  // Output style
  "outputStyle": "explanatory",     // verbose explanations
  // or
  "outputStyle": "concise",         // brief responses

  // Permission mode
  "permissionMode": "auto",         // no prompts (careful!)
  // or
  "permissionMode": "default",      // prompt for risky ops
  // or
  "permissionMode": "strict",       // prompt for everything

  // Allowed tools (bypass permission prompts)
  "allowedTools": [
    "Read",
    "Bash(git status)",
    "Bash(git diff*)",
    "Bash(npm test*)",
    "Bash(npm run lint*)"
  ],

  // Blocked tools
  "blockedTools": [
    "Bash(rm -rf*)",
    "Bash(git push --force*)"
  ],

  // Environment variables passed to Claude
  "env": {
    "NODE_ENV": "development"
  },

  // MCP server configurations
  "mcpServers": { ... },

  // Hooks
  "hooks": { ... }
}
```

#### Smart Permission Strategies

```json
// For read-only analysis sessions
{
  "allowedTools": ["Read", "Bash(find*)", "Bash(grep*)", "Bash(cat*)", "Bash(ls*)"],
  "blockedTools": ["Edit", "Write", "Bash(git commit*)", "Bash(npm*)", "Bash(rm*)"]
}

// For test-driven development
{
  "allowedTools": [
    "Read", "Edit", "Write",
    "Bash(npm test*)", "Bash(npx jest*)", "Bash(npm run*)"
  ]
}

// For deployment scripts
{
  "allowedTools": ["Read", "Bash(*)"],
  "blockedTools": ["Bash(rm -rf*)", "Bash(git push --force*)"]
}
```

---

## ⚡ Advanced Patterns

### Multi-Agent Teams

Run multiple Claude Code instances in parallel using tmux + git worktrees for maximum throughput.

```bash
# Setup: create worktrees for parallel development
git worktree add ../feature-auth -b feature/auth
git worktree add ../feature-payments -b feature/payments
git worktree add ../feature-notifications -b feature/notifications

# Launch agents in parallel tmux panes
tmux new-session -d -s claude-team
tmux split-window -h
tmux split-window -v

# Pane 1: Auth agent
tmux send-keys -t 0 "cd ../feature-auth && claude 'implement OAuth2 login'" Enter

# Pane 2: Payments agent
tmux send-keys -t 1 "cd ../feature-payments && claude 'implement Stripe checkout'" Enter

# Pane 3: Notifications agent
tmux send-keys -t 2 "cd ../feature-notifications && claude 'implement email notifications'" Enter
```

For detailed patterns, see [advanced/multi-agent-teams.md](advanced/multi-agent-teams.md).

---

### Cross-Model Routing

Route different tasks to the right model for cost/quality optimization.

```json
// .claude/settings.json — model per task type
{
  "profiles": {
    "planning": {
      "model": "claude-opus-4-7",
      "outputStyle": "explanatory"
    },
    "coding": {
      "model": "claude-sonnet-4-6",
      "outputStyle": "concise"
    },
    "review": {
      "model": "claude-opus-4-7",
      "outputStyle": "explanatory"
    }
  }
}
```

Use `/model claude-opus-4-7` when you need deep reasoning, `/model claude-sonnet-4-6` for fast coding tasks.

For routing to external models (DeepSeek, Gemini, Ollama), see [advanced/cross-model-routing.md](advanced/cross-model-routing.md).

---

### Automated Pipelines

Use Claude Code's scheduling capabilities to create automated development workflows.

```bash
# Daily code quality check
claude schedule "every day at 9am: run /audit and post results to #eng-alerts Slack channel"

# Weekly dependency updates
claude schedule "every monday: check for outdated npm packages and create a PR with safe updates"

# Pre-commit pipeline
# In .git/hooks/pre-commit:
claude --non-interactive "review staged changes for security vulnerabilities, output PASS or FAIL"
```

For full pipeline patterns, see [advanced/automated-pipelines.md](advanced/automated-pipelines.md).

---

### Security Patterns

Claude Code has broad filesystem and shell access. Lock it down properly.

```json
// Principle of least privilege
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/security-check.sh"
      }]
    }]
  },
  "blockedTools": [
    "Bash(curl * | bash*)",
    "Bash(wget * | sh*)",
    "Bash(eval*)",
    "Bash(rm -rf /*)"
  ]
}
```

For full security hardening guide, see [advanced/security-patterns.md](advanced/security-patterns.md).

---

### Enterprise Patterns

Scaling Claude Code across engineering teams requires governance and standardization.

```
enterprise-setup/
├── .claude/
│   ├── settings.json          # Team-wide permissions
│   ├── commands/              # Shared slash commands
│   └── skills/                # Shared skill library
├── onboarding/
│   ├── CLAUDE.md.template     # New project template
│   └── setup.sh               # Auto-setup script
└── governance/
    ├── approved-mcps.json     # Vetted MCP servers
    └── security-policy.json  # Security constraints
```

For full enterprise deployment guide, see [advanced/enterprise-patterns.md](advanced/enterprise-patterns.md).

---

## 🔄 Development Workflows

### Boris Cherny Creator Workflow

Boris Cherny (Claude Code creator at Anthropic) runs **5 local + 5–10 cloud sessions simultaneously** using git worktrees. His single most impactful tip:

> **"Enable verification loops. Testing improves final output quality by 2–3x."**

See [development-workflows/boris-creator-workflow.md](development-workflows/boris-creator-workflow.md) for his full workflow including model selection, voice coding, `/loop` automation, and the `--bare` startup flag.

---

### Verification Loops — The #1 Quality Multiplier

Set up PostToolUse hooks so tests run automatically after every file edit. Claude sees the results and self-corrects before you see it.

```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{"type": "command", "command": ".claude/hooks/verification-loop.sh"}]
    }]
  }
}
```

See [development-workflows/verification-loop.md](development-workflows/verification-loop.md) for the full implementation.

---

### Real-World Team Patterns

Production workflows from teams that have shipped with Claude Code:

| Team/Workflow | Stars | Core Pattern |
|---|---|---|
| **Superpowers** | 188k★ | Brainstorm → Worktree → Plan → Subagent Impl → Review → Merge |
| **BMAD Method** | Community | Brief → PRD → Architecture → Epics → Sprint → TDD → Retro |
| **gstack** | 95k★ | 14-stage: Spec → Plan → Code → Self-Review → QA → Security → Deploy → Metrics |
| **Spec Kit** | 97k★ | Constitution → Specify → Clarify → Plan → Tasks → Implement → Verify-Spec |
| **Debugging War Room** | Field-tested | Incident → Triage → Investigate → Fix → Verify → Post-mortem |

Full details: [development-workflows/real-world-teams.md](development-workflows/real-world-teams.md)

---

### Babysit PRs — Automated PR Management

```bash
# Run every 5 minutes: check PRs, fix CI failures, address review comments, merge when ready
/loop 5m /babysit-prs
```

See [development-workflows/babysit-prs.md](development-workflows/babysit-prs.md) for the full command definition and safety guards.

---

### Batch Migrations

Distribute large code migrations (50-200+ files) across parallel worktree agents:

```bash
# Split 100 files into 5 batches, run 5 agents in parallel
./scripts/batch-migrate.sh "convert from CommonJS require() to ESM import syntax"
```

See [development-workflows/batch-migration.md](development-workflows/batch-migration.md) for the full script.

---

### The RIPE Workflow (Research → Iterate → Polish → Execute)

Best for features with unknown territory.

```
Phase 1: RESEARCH
  └─ Subagent: explore codebase, find relevant patterns
  └─ Ask questions, gather requirements

Phase 2: ITERATE (Plan Mode)
  └─ Draft implementation plan
  └─ Review with stakeholders
  └─ Refine until confident

Phase 3: POLISH
  └─ Implement with frequent test runs
  └─ Review diffs at each step

Phase 4: EXECUTE
  └─ Run full test suite
  └─ Create PR with full context
  └─ Deploy
```

See [development-workflows/ripe-workflow.md](development-workflows/ripe-workflow.md) for full details.

---

### The TDD Spiral

```
/tdd <feature> triggers:
1. Write failing test
2. Implement minimum to pass
3. Refactor
4. Repeat until feature complete
5. Final review
6. Ship
```

See [development-workflows/tdd-spiral.md](development-workflows/tdd-spiral.md).

---

### The Spec-First Method

```
1. /spec "describe the feature in plain English"
2. Claude generates: user stories, acceptance criteria, edge cases
3. Review and approve spec
4. /implement-spec — Claude codes to the spec
5. /verify-spec — Claude checks implementation against spec
```

See [development-workflows/spec-first.md](development-workflows/spec-first.md).

---

### The Worktree Sprint

For teams shipping features in parallel:

```bash
# Sprint setup
git worktree add ../sprint-auth     -b sprint/auth
git worktree add ../sprint-api      -b sprint/api
git worktree add ../sprint-frontend -b sprint/frontend

# Assign agents
claude -p ../sprint-auth     /sprint "auth feature"
claude -p ../sprint-api      /sprint "API endpoints"
claude -p ../sprint-frontend /sprint "frontend components"

# Merge sprint
git merge sprint/auth sprint/api sprint/frontend
```

See [development-workflows/worktree-sprint.md](development-workflows/worktree-sprint.md).

---

## 🎭 Orchestration Patterns

### Research → Plan → Execute → Review → Ship

The gold-standard 5-phase workflow for any significant feature.

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ RESEARCH │───▶│   PLAN   │───▶│ EXECUTE  │───▶│  REVIEW  │───▶│   SHIP   │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
  Explore         Plan mode       Implement        Self-review      PR + deploy
  codebase        + approval      + tests          + security       + notify
```

### Command → Agent → Skill Flow

```
User types: /feature "add dark mode"
                │
                ▼
        Command: feature.md
        Reads context, spawns agents
                │
         ┌──────┴──────┐
         ▼             ▼
    Research Agent   Planning Agent
    (explores repo)  (designs approach)
         │             │
         └──────┬──────┘
                ▼
          Coding Agent
          (implements)
                │
                ▼
          Review Agent
          (verifies)
                │
                ▼
          Ship Command
          (PR + deploy)
```

See [orchestration-workflow/](orchestration-workflow/) for all patterns.

---

## 🧠 From the Creators — Boris & Thariq Tips

**Boris Cherny** (Claude Code creator) and **Thariq** (Anthropic Claude Code team) shared 70+ specific, production-tested tips. The top 10 most impactful:

1. **Verification loops** — auto-run tests after every edit (Boris: "2–3x quality improvement")
2. **Rewind over correct** — jump back before the mistake, don't pile corrections (Thariq)
3. **CLAUDE.md = living document** — update it after every mistake (Boris)
4. **Plan mode first** — always, for non-trivial tasks (Boris)
5. **Session-per-phase** — research / planning / execution in separate sessions (Thariq)
6. **Commit slash commands** — encode any repeated workflow (Boris)
7. **Subagents for research** — keep main context clean (Thariq)
8. **Model for the task** — Opus for decisions, Sonnet for grinding (Boris)
9. **Skill Gotchas section** — encode every real failure into the skill (Thariq)
10. **Compact with hints** — `/compact "keep: X, drop: Y"` not just `/compact` (Thariq)

**Context rot** — Thariq's key insight: quality degrades around 300–400k tokens even before the window is full. "Just because you haven't run out of context doesn't mean you shouldn't start a new session."

Full 70-tip list: [tips/boris-and-thariq-tips.md](tips/boris-and-thariq-tips.md)

Thariq's 9 skill types framework: [best-practice/11-thariq-skill-types.md](best-practice/11-thariq-skill-types.md)

Context rot prevention guide: [best-practice/12-context-rot.md](best-practice/12-context-rot.md)

---

## 💡 Tips & Tricks (190+)

### Prompting

1. **State the WHY, not just the WHAT** — "Refactor this for readability because new engineers are struggling to understand it" beats "Refactor this"
2. **Give negative constraints** — "Don't use any libraries, this needs to be zero-dependency"
3. **Set the bar explicitly** — "This code will be reviewed by a senior engineer, make it production quality"
4. **Reference existing patterns** — "Follow the same pattern as `src/auth/middleware.ts`"
5. **Use role priming** — "You are a security engineer reviewing this for vulnerabilities"
6. **Specify output format** — "Output a bulleted list of changes, each with file:line reference"
7. **Batch related questions** — Ask everything about a topic in one message instead of follow-ups
8. **Use numbered lists for multi-step instructions** — Claude follows numbered steps more reliably
9. **Explicitly say what NOT to change** — "Don't touch the tests, only modify the implementation"
10. **Ask for a plan before execution** — "Before making any changes, tell me your plan"

### Context Management

11. **Read only what you need** — "Read just the function signature, not the whole file"
12. **Use `/compact` before switching topics** — Compress history when changing focus
13. **Start fresh for unrelated tasks** — Don't drag prior context into new problems
14. **Name your sessions** — `/rename sprint-auth` for easy `/resume`
15. **Rewind don't apologize** — Hit ESC and rewind instead of asking Claude to undo mistakes
16. **Monitor context bar** — Keep below 40%, watch for yellow/red warnings
17. **Limit tool outputs** — `| head -50` after bash commands to avoid context bloat
18. **Summarize long files before editing** — "Summarize auth.ts, then tell me what to change"
19. **Use subagents for research** — Keep exploration context isolated
20. **Clear after major milestones** — `/clear` between logical phases of work

### Planning

21. **Plan at the right granularity** — Not too abstract, not too detailed
22. **Include rollback steps** — "How do we undo this if it breaks?"
23. **List affected files upfront** — Know the blast radius before starting
24. **Identify irreversible steps** — Flag database migrations, schema changes
25. **Break into vertical slices** — Ship a thin but complete feature, not horizontal layers
26. **Review the plan out loud** — Read it back in your own words before approving
27. **Ask "what could go wrong?"** — Get Claude to identify failure modes
28. **Separate design from implementation** — Don't let planning and coding mix
29. **Set checkpoints** — "After each step, show me the diff before continuing"
30. **Plan tests alongside code** — Not as an afterthought

### Session Management

31. **Use `/rename` immediately** for important sessions
32. **`/resume` to restore context** after a break
33. **Don't exceed 200 messages per session** — quality degrades
34. **Use `/model` to switch mid-session** — Opus for hard decisions, Sonnet for grinding
35. **Screenshot terminal state** before long operations
36. **Keep a parallel notepad** — Copy key decisions from session to notes
37. **`/fast` mode for routine tasks** — Faster output, same quality for simple work
38. **Break long sessions with `/compact`** — Every 50-60 messages
39. **Fresh sessions for separate concerns** — Auth work ≠ UI work ≠ infra work
40. **Use multiple terminal panes** — Different sessions for different layers

### Debugging

41. **Share the actual error, not a description** — Paste the stack trace
42. **Include context around the error** — What did you change? What were you doing?
43. **Ask for hypothesis list first** — "List 5 possible causes before fixing"
44. **Binary search with Claude** — "What's the simplest thing we could test to narrow this down?"
45. **Use rubber duck mode** — "I'm going to explain my understanding, tell me where I'm wrong"
46. **Ask for regression tests** — "Write a test that would have caught this bug"
47. **Check assumptions explicitly** — "What assumptions is this code making about input?"
48. **Compare to working version** — "Here's the working code and broken code, what changed?"
49. **Use `/debug` command** for systematic investigation
50. **Ask about edge cases** — "What inputs would make this fail?"

### Code Quality

51. **Ask for code review before and after** — Get critique, not just implementation
52. **Request explicit tradeoffs** — "What are the pros and cons of this approach?"
53. **Ask about alternatives** — "Show me 3 ways to do this and recommend one"
54. **Request complexity analysis** — "What's the time/space complexity?"
55. **Check for security issues explicitly** — "Are there any injection or auth vulnerabilities?"
56. **Ask about observability** — "What would be hard to debug about this in production?"
57. **Request idiomatic style** — "Is this idiomatic Go/Python/TypeScript?"
58. **Ask about testability** — "How would I write a unit test for this?"
59. **Check for error handling gaps** — "What errors aren't being handled?"
60. **Ask about scalability** — "What breaks when this gets 100x traffic?"

### Subagents

61. **Give subagents complete context** — They don't see the main conversation
62. **Define clear output formats** — So orchestrator can parse results
63. **Set explicit boundaries** — "Read-only, do not modify files"
64. **Parallelize independent work** — Research and analysis can run simultaneously
65. **Keep subagent prompts focused** — One job per agent
66. **Return structured data** — JSON output is easier to process than prose
67. **Use Explore subagent for search** — Faster and cheaper than general-purpose
68. **Chain specialist agents** — Architect → Coder → Reviewer → Tester
69. **Debrief in main context** — Synthesize subagent results yourself
70. **Don't nest subagents deeply** — Max 2-3 levels of nesting

### Hooks

71. **Start with logging hooks** — Before automation, log what's happening
72. **Use `exit 2` sparingly** — Only block when truly necessary
73. **Test hooks independently** — Run hook scripts manually before wiring up
74. **Keep hooks idempotent** — Safe to run multiple times
75. **Use hooks for policy, not logic** — Complex logic belongs in commands/skills
76. **Log hook execution** — Hard to debug otherwise
77. **Rate limit expensive hooks** — Add cooldowns to avoid runaway costs
78. **Scope hooks to project** — Use `.claude/settings.json` not global settings
79. **Test exit codes** — Verify your hook returns the right codes
80. **Document hook purpose** — Future you will thank you

### CLAUDE.md

81. **Keep it under 200 lines** — Longer files get ignored
82. **Put most important rules first** — Top of file gets most attention
83. **Use `<important if="...">` tags** — Conditional instructions reduce noise
84. **Update it as patterns evolve** — Stale CLAUDE.md is worse than none
85. **Split into rules/ directory** — For monorepos with different contexts
86. **Test instructions work** — Ask Claude what rules apply to verify loading
87. **Prefer imperative style** — "Always use TypeScript strict mode" not "TypeScript strict mode is preferred"
88. **Include architecture decisions** — Why things are the way they are
89. **List banned patterns explicitly** — "Never use any-type casts"
90. **Include test commands** — Exact commands to run tests, lint, build

### MCP & Integrations

91. **Start with official MCP servers** — Before building custom ones
92. **Scope MCP permissions carefully** — Least privilege principle
93. **Use environment variables for secrets** — Never hardcode in settings.json
94. **Test MCP servers independently** — Before wiring into Claude Code
95. **Document custom MCP tools** — Others won't know what they do
96. **Version pin MCP packages** — Avoid unexpected breaking changes
97. **Monitor MCP token usage** — Some servers can inflate context quickly
98. **Use MCP for stable integrations** — Flaky APIs make bad MCP servers

### Advanced

99. **Use thinking mode for hard problems** — Enable extended thinking for architecture decisions
100. **Combine fast mode + subagents** — Fast responses + isolated context = efficient throughput
101. **Build a personal command library** — Invest in reusable commands upfront
102. **Version control your `.claude/` directory** — Share improvements with your team
103. **Write skills for your domain** — Generic skills are fine, domain-specific are better
104. **Profile before optimizing** — Know what's actually slow before addressing it
105. **Use UltraReview for critical PRs** — Multi-agent review catches more issues
106. **Scheduled tasks for routine work** — Dependency updates, audit checks, reports
107. **Treat CLAUDE.md as living documentation** — Update it when patterns change
108. **Build a team command playbook** — Standard commands everyone uses
109. **Retrospect on Claude sessions** — What prompting patterns worked? Document them.
110. **Invest in onboarding templates** — New team members should be productive day 1

### Model Selection

111. **Opus for architecture decisions** — Don't cheap out on design
112. **Sonnet for implementation grind** — Fast and capable for well-defined work
113. **Haiku for simple lookups** — Symbol search, format checks
114. **Upgrade mid-session when stuck** — `/model opus` when Sonnet is struggling
115. **Factor in cost** — Opus is ~5x more expensive than Sonnet per token
116. **Use fast mode for iterations** — Speed matters when you're iterating
117. **Match model to stakes** — Production security review = Opus, test rename = Sonnet
118. **Don't over-specify the model** — Let the task guide you, not habit

### Mindset

119. **You're the architect, Claude is the builder** — Own the design decisions
120. **Invest 10 minutes in context setup** — Saves an hour of back-and-forth
121. **Treat bad output as a prompt problem** — Rephrase before giving up
122. **Document what works** — Build a personal playbook
123. **Pair Claude with your expertise** — It's amplification, not replacement

---

## 📄 CLAUDE.md Mastery

CLAUDE.md is the foundation of every good Claude Code setup. Here's a production-ready template:

```markdown
# Project: [Your Project Name]

## Overview
[2-3 sentences describing what this project does]

## Architecture
- **Frontend**: [tech stack]
- **Backend**: [tech stack]
- **Database**: [type + ORM]
- **Auth**: [approach]
- **Deploy**: [platform]

## Development Setup
```bash
npm install
npm run dev
```

## Testing
```bash
npm test              # unit tests
npm run test:e2e      # end-to-end tests
npm run test:coverage # with coverage
```

## Code Standards
- TypeScript strict mode always
- No `any` types — use `unknown` and narrow
- All async functions return explicit types
- ESLint + Prettier enforced by CI

## Patterns to Follow
- Auth: see `src/auth/middleware.ts` for the pattern
- API routes: see `src/api/users.ts` for the pattern
- Database queries: see `src/db/users.ts` for the pattern

## NEVER
- Never commit secrets or API keys
- Never skip TypeScript types with `// @ts-ignore`
- Never merge with failing tests
- Never edit migrations after they've been applied

## Important Files
- `src/config.ts` — all configuration
- `src/types/index.ts` — global type definitions
- `prisma/schema.prisma` — database schema
```

---

## 🤖 Model Selection Strategy

```
Task Complexity × Risk = Model Choice

                   LOW RISK          HIGH RISK
                 ┌────────────────┬────────────────┐
  SIMPLE TASK    │     Haiku      │    Sonnet      │
                 ├────────────────┼────────────────┤
  COMPLEX TASK   │    Sonnet      │    Opus        │
                 └────────────────┴────────────────┘

Examples:
• Find a symbol in code           → Haiku
• Implement a CRUD endpoint       → Sonnet
• Design auth architecture        → Opus
• Write a unit test               → Sonnet
• Review PR for security issues   → Opus
• Fix a typo in README            → Haiku
```

---

## 🔐 Security Best Practices

### Protecting Secrets

```bash
# .gitignore — always include
.claude/settings.local.json
.env
.env.*

# Use environment variables in settings.json
{
  "env": {
    "API_KEY": "${MY_API_KEY}"  # reads from shell env
  }
}
```

### Least Privilege Configuration

```json
// For a frontend-only project
{
  "allowedTools": ["Read", "Edit", "Write", "Bash(npm*)"],
  "blockedTools": ["Bash(rm*)", "Bash(curl*)", "Bash(wget*)"]
}
```

### Audit Logging Hook

```bash
#!/bin/bash
# Log all Claude tool calls to audit file
echo "$(date) TOOL=$CLAUDE_TOOL_NAME INPUT=$(echo $CLAUDE_TOOL_INPUT | jq -c .)" \
  >> ~/.claude/audit.log
```

---

## 👥 Team & Enterprise Usage

### Shared Configuration

```
team-repo/
└── .claude/
    ├── settings.json      # committed — shared rules
    ├── commands/          # committed — shared workflows
    └── skills/            # committed — shared skills

# Each developer has locally:
.claude/settings.local.json  # personal preferences, gitignored
```

### Onboarding Template

```bash
#!/bin/bash
# scripts/claude-setup.sh
echo "Setting up Claude Code for this project..."

# Install required MCP servers
npx -y @modelcontextprotocol/server-github > /dev/null 2>&1
npx -y @modelcontextprotocol/server-postgres > /dev/null 2>&1

# Copy hooks
mkdir -p ~/.claude/hooks
cp .claude/hooks-templates/* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*

echo "✓ Claude Code ready. Run 'claude /help' to get started."
```

---

## 📁 Directory Structure

```
claude-best-practice/
├── README.md                          ← You are here
├── .claude/
│   ├── settings.json                  ← Example project settings
│   ├── commands/                      ← Reusable slash commands
│   │   ├── plan.md
│   │   ├── ship.md
│   │   ├── review.md
│   │   ├── debug.md
│   │   ├── audit.md
│   │   └── ...
│   ├── agents/                        ← Subagent definitions
│   │   ├── architect.md
│   │   ├── reviewer.md
│   │   └── ...
│   └── skills/                        ← Skill templates
│       ├── deploy/
│       ├── test/
│       └── ...
├── best-practice/                     ← Deep-dive guides
│   ├── 01-context-management.md
│   ├── 02-plan-mode.md
│   ├── 03-subagents.md
│   ├── 04-commands.md
│   ├── 05-skills.md
│   ├── 06-hooks.md
│   ├── 07-mcp-servers.md
│   ├── 08-memory-system.md
│   ├── 09-settings.md
│   └── 10-claudemd-guide.md
├── advanced/                          ← Advanced patterns
│   ├── multi-agent-teams.md
│   ├── cross-model-routing.md
│   ├── automated-pipelines.md
│   ├── security-patterns.md
│   └── enterprise-patterns.md
├── implementation/                    ← Working code examples
│   ├── hooks/                         ← Copy-paste hook scripts
│   ├── mcp/                           ← MCP server examples
│   └── workflows/                     ← Workflow automation
├── orchestration-workflow/            ← Architecture patterns
│   ├── research-plan-execute.md
│   ├── tdd-workflow.md
│   ├── spec-first.md
│   └── command-agent-skill-flow.md
├── development-workflows/             ← Full methodologies
│   ├── ripe-workflow.md
│   ├── tdd-spiral.md
│   ├── spec-first.md
│   ├── worktree-sprint.md
│   └── solo-vs-team.md
├── tips/                              ← Curated tip collections
│   ├── prompting-tips.md
│   ├── context-tips.md
│   ├── session-tips.md
│   ├── debugging-tips.md
│   └── advanced-tips.md
└── reports/                           ← Deep-dive reports
    ├── memory-deep-dive.md
    ├── hooks-deep-dive.md
    ├── mcp-ecosystem.md
    └── agent-teams-report.md
```

---

## 🤝 Contributing

This repository is a living document. Contributions welcome.

1. Fork the repo
2. Create a branch: `git checkout -b add/my-pattern`
3. Add your content following the existing structure
4. Submit a PR with a description of what you're adding and why it's useful

**What to contribute:**
- Real-world workflows that worked on production projects
- Hook scripts that solved actual problems
- Advanced patterns not covered here
- Corrections to outdated information

---

<div align="center">

**If this helped you ship faster, give it a ⭐**

</div>
