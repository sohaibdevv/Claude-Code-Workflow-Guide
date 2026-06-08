# Multi-Agent Teams — Parallel Development at Scale

Multi-agent teams let you run several Claude Code instances simultaneously on independent workstreams, dramatically increasing throughput for large features.

---

## The Core Pattern: Git Worktrees + tmux

Git worktrees let multiple agents work on separate branches of the same repo simultaneously without interfering with each other. tmux lets you manage multiple terminal panes in one window.

```bash
# Setup a 3-agent team
git worktree add ../feature-auth     -b feature/auth
git worktree add ../feature-payments -b feature/payments
git worktree add ../feature-ui       -b feature/ui

# Launch tmux session
tmux new-session -s dev-team -d

# Create panes
tmux split-window -h -t dev-team
tmux split-window -v -t dev-team:0.0
tmux split-window -v -t dev-team:0.1

# Start agents in each pane
tmux send-keys -t dev-team:0.0 "cd ../feature-auth && claude 'implement OAuth2 login'" Enter
tmux send-keys -t dev-team:0.1 "cd ../feature-payments && claude 'implement Stripe checkout'" Enter
tmux send-keys -t dev-team:0.2 "cd ../feature-ui && claude 'implement the dashboard UI'" Enter
tmux send-keys -t dev-team:0.3 "cd . && echo 'Orchestrator pane ready'" Enter
```

---

## Team Roles

### The Orchestrator (you, in main worktree)
- Defines tasks for each agent
- Reviews outputs as they complete
- Resolves conflicts when agents touch shared files
- Merges branches and coordinates integration

### Feature Agents (parallel worktrees)
- Each has a well-defined scope
- Works independently until done
- Commits progress frequently
- Doesn't know about other agents

### Review Agent (after parallel work completes)
- Spawned in main worktree
- Reviews all feature branches before merge
- Checks integration points

---

## Task Assignment Rules

**Good candidates for parallel agents:**
- Features that touch completely separate modules
- Tests for different components
- Documentation updates
- Database migrations for different tables
- UI components for different pages

**Bad candidates (must serialize):**
- Changes to shared types or interfaces
- Changes to core utilities used everywhere
- Database migrations that depend on each other
- Features that share significant state

**Rule of thumb**: If two features would conflict if both were in a PR, they can't be safely parallelized without coordination.

---

## CLAUDE.md for Agent Teams

Create a shared CLAUDE.md that agents follow, plus agent-specific context:

```markdown
# Project: E-Commerce Platform
[standard project context]

## Multi-Agent Coordination
You are one of several agents working in parallel. Your assigned scope:
**DO NOT touch files outside your scope.**

If you discover you need to modify a shared file, STOP and report it.
The orchestrator will coordinate cross-agent changes.

Your scope: $AGENT_SCOPE
```

---

## Integration Pattern

After parallel agents complete:

```bash
# Review each agent's work
git -C ../feature-auth log --oneline main..HEAD
git -C ../feature-payments log --oneline main..HEAD
git -C ../feature-ui log --oneline main..HEAD

# Merge in order (least to most likely to conflict)
git merge feature/ui      # pure UI, least likely to conflict
git merge feature/auth    # auth changes backend
git merge feature/payments # might share types with auth

# If conflicts:
claude "resolve the merge conflicts in src/types/user.ts — 
both the auth and payments branches modified it. 
Auth change: [describe]. Payments change: [describe]."
```

---

## Advanced: Automated Agent Orchestration

Use a script to launch, monitor, and merge agents automatically:

```bash
#!/bin/bash
# scripts/agent-team.sh

TASKS=(
  "feature-auth:implement OAuth2 with Google and GitHub providers"
  "feature-notifications:implement email + push notification system"
  "feature-search:add Elasticsearch-powered product search"
)

# Create worktrees and launch agents
for task in "${TASKS[@]}"; do
  branch="${task%%:*}"
  prompt="${task#*:}"
  
  git worktree add "../$branch" -b "feature/$branch" 2>/dev/null || true
  
  tmux new-window -t dev-team -n "$branch"
  tmux send-keys -t "dev-team:$branch" \
    "cd ../$branch && claude '$prompt; when done, commit all changes and print DONE'" \
    Enter
done

echo "All agents launched. Monitor with: tmux attach -t dev-team"
```

---

## Cost and Context Considerations

Each agent has its own context window. Running 3 agents = 3x the context usage = 3x the cost. This is worthwhile when:
- The tasks are truly independent (no wasted work from conflicts)
- The time saved is significant (parallelizing a 3-hour task into 1 hour)
- The quality benefit of fresh contexts is needed

Not worthwhile for:
- Small tasks that finish in < 20 minutes
- Tasks with significant shared state
- When you need to review between each step anyway

---

## Monitoring Agent Progress

```bash
# Watch all agent git activity
watch -n 5 'for dir in ../feature-*; do 
  echo "=== $(basename $dir) ==="; 
  git -C "$dir" log --oneline -3; 
done'

# Check for any agent errors
tmux list-panes -a -F "#{pane_title}: #{pane_current_command}"
```
