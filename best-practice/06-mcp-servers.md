# MCP Servers — Extending Claude with External Tools

MCP (Model Context Protocol) is the open standard that lets Claude Code integrate with databases, APIs, cloud services, and custom internal tools. MCP servers are the plugins that make Claude aware of systems beyond the local filesystem.

---

## How MCP Works

```
Claude Code ←→ MCP Client ←→ MCP Server ←→ External System
              (built-in)      (you config)    (DB, API, etc.)
```

When you configure an MCP server, Claude can:
- **Call tools** exposed by the server (query a DB, create a GitHub issue)
- **Read resources** the server provides (structured data, documents)
- **Receive prompts** the server defines (templated interactions)

The communication is local by default (stdio) or over SSE for remote servers.

---

## Configuration

```json
// .claude/settings.json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-name", "...args"],
      "env": {
        "API_KEY": "${ENV_VAR}"  // read from shell environment
      }
    }
  }
}
```

Keys are the server name Claude uses. Values define how to launch the server.

---

## Official MCP Servers

### GitHub
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

Enables: search code, list PRs/issues, create issues, comment on PRs, get file contents from any repo.

### PostgreSQL
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL}"]
    }
  }
}
```

Enables: run SQL queries, inspect schema, explore data directly during debugging.

**Warning**: Give Claude a read-only database user unless you explicitly need write access.

### Filesystem (Extended)
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y", "@modelcontextprotocol/server-filesystem",
        "/Users/username/projects",
        "/Users/username/docs"
      ]
    }
  }
}
```

Enables access to directories outside the current working directory.

### Brave Search
```json
{
  "mcpServers": {
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

Enables web search during coding tasks — "find the latest React Router v7 migration guide."

---

## Building a Custom MCP Server

When your team has internal tools, APIs, or databases that Claude should access.

### Minimal TypeScript MCP Server

```typescript
// internal-tools-server.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  { name: "internal-tools", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

// Define available tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "get_feature_flag",
      description: "Get the current value of a feature flag",
      inputSchema: {
        type: "object",
        properties: {
          flag_name: {
            type: "string",
            description: "The feature flag name"
          },
          environment: {
            type: "string",
            enum: ["development", "staging", "production"],
            description: "The environment to check"
          }
        },
        required: ["flag_name"]
      }
    },
    {
      name: "get_error_rate",
      description: "Get error rate for a service in the last N minutes",
      inputSchema: {
        type: "object",
        properties: {
          service: { type: "string" },
          minutes: { type: "number", default: 60 }
        },
        required: ["service"]
      }
    }
  ]
}));

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "get_feature_flag": {
      const result = await fetchFeatureFlag(args.flag_name, args.environment);
      return {
        content: [{ type: "text", text: JSON.stringify(result, null, 2) }]
      };
    }

    case "get_error_rate": {
      const rate = await fetchErrorRate(args.service, args.minutes ?? 60);
      return {
        content: [{ type: "text", text: `Error rate: ${rate}%` }]
      };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
```

### Register It

```json
{
  "mcpServers": {
    "internal": {
      "command": "npx",
      "args": ["tsx", "/path/to/internal-tools-server.ts"]
    }
  }
}
```

---

## MCP Security Best Practices

### Principle of Least Privilege
```json
// Read-only DB user for MCP
{
  "mcpServers": {
    "postgres": {
      "command": "...",
      "args": ["postgresql://readonly_user:pass@host/db"]
    }
  }
}
```

### Secrets Management
```bash
# Never hardcode in settings.json
# Bad:
"API_KEY": "sk-abc123..."

# Good:
"API_KEY": "${MY_API_KEY}"  // reads from environment
```

```bash
# Set in your shell profile
export MY_API_KEY="sk-abc123..."
```

### Scope Servers to Projects
Use project-level `.claude/settings.json` for project-specific servers, not global config. This prevents accidentally exposing production credentials in personal projects.

---

## Debugging MCP Servers

```bash
# Run the MCP server manually to test it
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | \
  npx -y @modelcontextprotocol/server-github

# Check Claude Code sees your servers
# In Claude Code session:
"What MCP tools do you have available?"
```

If a server isn't working, check:
1. Is the `command` in the PATH?
2. Are the environment variables set in the shell that launched Claude Code?
3. Is the server version compatible with Claude Code's MCP client version?
