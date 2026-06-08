#!/bin/bash
# Worktree Sprint Script
# Launches parallel Claude Code agents across git worktrees
#
# Usage: ./worktree-sprint.sh "task1 description" "task2 description" "task3 description"
# Example: ./worktree-sprint.sh "implement auth" "implement payments" "implement notifications"

set -e

MAIN_BRANCH=$(git rev-parse --abbrev-ref HEAD)
MAIN_DIR=$(git rev-parse --show-toplevel)
BASE_DIR=$(dirname "$MAIN_DIR")
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 'task 1' 'task 2' 'task 3' ..."
  exit 1
fi

echo "=== Worktree Sprint Setup ==="
echo "Main branch: $MAIN_BRANCH"
echo "Tasks: $#"
echo ""

# Create worktrees and start agents
WORKTREES=()
for i in "$@"; do
  TASK_INDEX=$((${#WORKTREES[@]} + 1))
  BRANCH_NAME="sprint/$TIMESTAMP/task-$TASK_INDEX"
  WORKTREE_PATH="$BASE_DIR/sprint-$TIMESTAMP-task-$TASK_INDEX"

  echo "Creating worktree for task $TASK_INDEX: $i"
  git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"
  WORKTREES+=("$WORKTREE_PATH")

  # Copy .claude directory to worktree (settings, commands, skills)
  if [ -d "$MAIN_DIR/.claude" ]; then
    cp -r "$MAIN_DIR/.claude" "$WORKTREE_PATH/.claude"
  fi

  echo "Worktree ready: $WORKTREE_PATH (branch: $BRANCH_NAME)"
done

echo ""
echo "=== Launching Agents ==="

# Check if tmux is available
if command -v tmux &>/dev/null; then
  SESSION="sprint-$TIMESTAMP"
  tmux new-session -d -s "$SESSION" -x 220 -y 50

  for i in "${!WORKTREES[@]}"; do
    TASK_NUM=$((i + 1))
    WORKTREE="${WORKTREES[$i]}"
    TASK_DESC="${@:$TASK_NUM:1}"

    if [ $i -eq 0 ]; then
      tmux send-keys -t "$SESSION:0" "cd '$WORKTREE' && echo 'Agent $TASK_NUM: $TASK_DESC' && claude '$TASK_DESC; when complete, commit all changes with a descriptive message'" Enter
    else
      tmux new-window -t "$SESSION" -n "agent-$TASK_NUM"
      tmux send-keys -t "$SESSION:$((i))" "cd '$WORKTREE' && echo 'Agent $TASK_NUM: $TASK_DESC' && claude '$TASK_DESC; when complete, commit all changes with a descriptive message'" Enter
    fi
  done

  echo "tmux session '$SESSION' started with ${#WORKTREES[@]} agents"
  echo "Attach with: tmux attach -t $SESSION"
else
  echo "tmux not found. Starting agents in background processes..."
  for i in "${!WORKTREES[@]}"; do
    TASK_NUM=$((i + 1))
    WORKTREE="${WORKTREES[$i]}"
    TASK_DESC="${@:$TASK_NUM:1}"

    echo "Starting agent $TASK_NUM in background..."
    (cd "$WORKTREE" && claude --non-interactive "$TASK_DESC; when complete, commit all changes") \
      > "$WORKTREE/../agent-$TASK_NUM.log" 2>&1 &
    echo "PID: $!"
  done
  echo ""
  echo "Agents running in background. Check logs in: $BASE_DIR/agent-*.log"
fi

echo ""
echo "=== Sprint Started ==="
echo "Worktrees:"
for WORKTREE in "${WORKTREES[@]}"; do
  echo "  $WORKTREE"
done
echo ""
echo "When agents complete:"
echo "  cd $MAIN_DIR"
echo "  git fetch --all"
echo "  git log --oneline --all | grep sprint/$TIMESTAMP"
