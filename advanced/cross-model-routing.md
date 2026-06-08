# Cross-Model Routing — Using Multiple AI Providers

Claude Code can route tasks to different AI models — both other Claude models and third-party providers — giving you flexibility to optimize for cost, capability, or specific task requirements.

---

## Native Model Switching

The simplest routing: switching between Claude models within the same session.

```bash
# Permanent switch for the session
/model claude-opus-4-7

# Per-task switching pattern
# High-stakes decisions → Opus
/model claude-opus-4-7
"Design the database sharding strategy for handling 10M users"

# Return to Sonnet for implementation
/model claude-sonnet-4-6
"Implement the sharding key selection logic from the design above"
```

---

## OpenRouter Integration

OpenRouter acts as a proxy to 100+ models. Use it to route tasks to DeepSeek, Gemini, Llama, or others.

```json
// .claude/settings.json
{
  "mcpServers": {
    "openrouter": {
      "command": "npx",
      "args": ["-y", "mcp-openrouter"],
      "env": {
        "OPENROUTER_API_KEY": "${OPENROUTER_API_KEY}"
      }
    }
  }
}
```

Or configure the API endpoint to route through OpenRouter:

```bash
# Set OpenRouter as the API base
export ANTHROPIC_BASE_URL="https://openrouter.ai/api/v1"
export ANTHROPIC_API_KEY="${OPENROUTER_API_KEY}"

# Now Claude Code routes through OpenRouter
# Specify the model via OpenRouter's model IDs
```

---

## Local Model Routing (Ollama)

Route to local models for offline work, cost reduction, or privacy-sensitive tasks.

```bash
# Install Ollama and a model
brew install ollama
ollama pull codestral
ollama pull llama3.2

# Configure Claude Code to use local model via proxy
export ANTHROPIC_BASE_URL="http://localhost:11434/v1"
```

**Practical use for local models:**
- Initial exploration of unfamiliar codebases (cheap/offline)
- Simple refactoring tasks
- Generating boilerplate
- When you're offline

Switch back to Claude for complex reasoning or security-sensitive work.

---

## Task-Based Routing Strategy

```markdown
## Routing Decision Tree

Is this task security/auth related?
  → YES: Always Claude Opus (no routing to third-party models)

Is this task coding a well-defined feature?
  → YES: Claude Sonnet (good quality, reasonable cost)

Is this task a complex architectural decision?
  → YES: Claude Opus

Is this task repetitive boilerplate generation?
  → YES: Consider local model or Haiku

Is this task searching/exploring code?
  → YES: Claude Haiku (or Explore subagent)

Is the data sensitive (user PII, credentials, business secrets)?
  → YES: Stay on Claude (Anthropic's privacy terms apply)
  → NO: Consider OpenRouter/local for cost savings
```

---

## Routing via Slash Commands

Create commands that specify the model for specific workflows:

```markdown
<!-- .claude/commands/deep-review.md -->
# Deep Review

Switch to Opus and conduct a thorough security + architecture review of: $ARGUMENTS

/model claude-opus-4-7

Review for:
1. Security vulnerabilities (OWASP Top 10)
2. Architectural anti-patterns
3. Performance issues
4. Correctness problems

Be thorough. This is a high-stakes review.
```

```markdown
<!-- .claude/commands/quick-grep.md -->
# Quick Search

Switch to Haiku and find: $ARGUMENTS

/model claude-haiku-4-5-20251001

Search the codebase for $ARGUMENTS. 
Return: file paths and line numbers only. 
No explanations needed.
```

---

## Multi-Model Subagent Pattern

Spawn subagents on different models based on their task:

```javascript
// In an orchestration command/skill:

// Cheap model for research
Agent({
  model: "haiku",
  description: "Find relevant files",
  prompt: "Search for all files related to authentication. Return paths only."
})

// Expensive model for decisions
Agent({
  model: "opus",
  description: "Architecture design",
  prompt: "Design the OAuth2 integration based on these findings: [findings]"
})

// Standard model for implementation
Agent({
  model: "sonnet",
  description: "Implementation",
  prompt: "Implement the design: [design]"
})
```

---

## Cost Optimization Framework

Example: 1000-token task, run 100 times/month

| Model | Cost per task | Monthly cost |
|---|---|---|
| Opus | ~$0.075 | $7.50 |
| Sonnet | ~$0.015 | $1.50 |
| Haiku | ~$0.001 | $0.10 |

**Rule**: Route to the cheapest model that meets the quality bar for the task. Don't over-spend on model quality any more than you'd over-spend on compute.

---

## Privacy Routing Rules

Always define which tasks can leave Claude's API:

```markdown
## Data Classification for Routing

NEVER route to third-party providers (stay on Anthropic):
- Code containing user PII
- Authentication or secrets code
- Business-sensitive algorithms
- Database schemas with personal data

OK to route to third-party providers:
- Public open-source code
- Generic algorithm implementations  
- Infrastructure boilerplate
- Test data generation
```
