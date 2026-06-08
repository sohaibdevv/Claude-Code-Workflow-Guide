# Session Management Tips — Working Smarter with Context

---

## Starting Sessions

**1. Name important sessions immediately**
`/rename auth-refactor-2026` — makes them easy to find and resume.

**2. Load your CLAUDE.md context check**
At the start of complex tasks: "What rules from our CLAUDE.md apply to this task?" Confirms Claude loaded it correctly.

**3. Orient before coding**
"What's the current state of this branch? What changed recently?" Sets a clean starting point.

**4. Set explicit goals for the session**
"Today's goal: complete the user profile feature through to PR creation." Keeps the session focused.

**5. Start plan mode for complex tasks**
Shift+Tab or `/plan` immediately for anything spanning multiple files.

---

## During Sessions

**6. Monitor context utilization**
Check the status bar. Act at yellow (40%), don't wait for red (80%+).

**7. Batch related questions**
Three small questions in one message > three separate messages. Saves context.

**8. Commit at stable points**
Every time you have working code, commit. Frequent commits = cheap checkpoints you can return to.

**9. Use `/rewind` aggressively**
When output is wrong: ESC → `/rewind` → re-prompt with better instructions. Never pile corrections on mistakes.

**10. Keep bash output bounded**
Append `| tail -20` or `| head -30` to long-running commands. Test output especially can be thousands of lines.

---

## Context Management

**11. Compact before switching topics**
`/compact "keep: the schema design decisions, the file list we identified"` when transitioning phases.

**12. Fresh session for unrelated tasks**
Auth work context ≠ UI work context. Mixing them degrades both. New task = new session.

**13. Save decisions to temp file**
Long sessions: write key decisions to a file. Read it at the start of the next session.

**14. Use git commits as checkpoints**
Commit message = context summary. "Step 3/7: added UserSession type with refresh token field"

**15. Limit file reads**
"Read only the function, not the whole file." Every token matters.

---

## Resuming Sessions

**16. `/resume` to restore a named session**
`/resume auth-refactor-2026` — comes back with full context.

**17. Orient the resumed session**
After resuming: "Where were we? What's left to do?" Recaps before diving back in.

**18. Don't resume stale sessions**
Sessions from more than a few days ago usually have context that's no longer accurate. Start fresh and provide current state.

**19. Use git log to recap**
In a fresh session: "Read the last 5 commit messages and tell me what was accomplished." Fast context loading.

**20. Carry forward only what's needed**
When starting fresh: write a brief handoff note. "Last session accomplished: X. Next steps: Y. Key decisions: Z."

---

## Multi-Session Strategies

**21. Separate sessions for separate concerns**
Research session → commit notes to file. Planning session → commit plan to file. Execution session → reads from both.

**22. Use CLAUDE.md as cross-session memory**
Update CLAUDE.md with architectural decisions as they're made. It persists across sessions.

**23. Session-per-phase for big features**
Research phase in session 1. Planning in session 2. Implementation in session 3. Review in session 4.

**24. Daily standup pattern**
Start each day: fresh session + "Read the last 10 commits and tell me where we are in the feature."

**25. Keep implementation sessions focused**
One session = one feature = one PR. Avoid multi-feature sessions.

---

## Parallel Sessions

**26. Separate terminals for separate layers**
Terminal 1: frontend work. Terminal 2: backend work. Never mix in one session.

**27. One session per worktree**
Each git worktree gets its own Claude Code session. They're independent contexts.

**28. Coordinate before touching shared code**
Two parallel sessions both need to modify the same shared type → stop, coordinate, do it in one session.

**29. Use tmux for session management**
tmux windows for different features. tmux panes for agent/review split.

**30. Tag parallel session work in git**
`[auth-session]` and `[payments-session]` prefixes in commit messages make it easy to see which session produced which changes.

---

## Session Health Indicators

Signs your session is healthy:
- Context bar is green
- Responses are specific and accurate
- Claude references earlier decisions correctly
- Code style is consistent

Signs your session needs attention:
- Claude contradicts earlier decisions
- Responses become generic/vague
- Claude asks questions it already answered
- Code style inconsistencies appear
- Context bar is yellow or orange

Action: `/compact` or start fresh immediately.
