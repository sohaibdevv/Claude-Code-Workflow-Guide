# Tips from the Claude Code Team

These tips come directly from Boris Cherny (Claude Code creator) and Thariq (Anthropic Claude Code team), compiled from their public posts in 2026.

---

## Boris Cherny — Creator Tips

### On Parallelism
1. Run 5 local worktree sessions + 5–10 cloud sessions simultaneously for maximum throughput
2. Each worktree is an independent context — no contamination between workstreams
3. Parallelism isn't about running the same task faster — it's about running different tasks simultaneously
4. Use tmux to manage multiple local sessions without losing track
5. Don't parallelize tasks with shared state — sequence those instead

### On Model Selection
6. Use Opus with extended thinking for coding tasks, even though it's slower per response
7. The metric is task completion speed, not token speed — fewer correction turns = faster overall
8. Opus requires less steering and excels at tool use, making it net faster for complex tasks
9. Switch to Sonnet for well-defined implementation grind — no reasoning needed for boilerplate
10. Switch mid-session: `/model opus` when stuck, `/model sonnet` for grinding

### On Verification
11. Verification loops are the single most impactful improvement you can make
12. 2–3x quality improvement from automated test running after every edit
13. Claude with test feedback > Claude without test feedback by a massive margin
14. Set up PostToolUse hooks to auto-run tests — don't ask Claude to run them manually
15. The verification loop should close automatically, not require a separate prompt

### On CLAUDE.md
16. After every session where Claude makes a mistake, add a rule to CLAUDE.md
17. A shared CLAUDE.md in version control ensures the whole team benefits from every lesson
18. CLAUDE.md should get better with every session — it's a living document, not a one-time setup
19. Short and focused beats long and comprehensive — Claude processes top of file most attentively
20. Test your CLAUDE.md by asking Claude what rules apply — if it can't answer, fix the file

### On Automation
21. If you've typed a workflow more than twice, make it a slash command
22. `/loop 5m /babysit-prs` handles PR queue management without manual attention
23. Automated bug fixing (Claude watching failing tests and fixing them) works well for isolated test failures
24. Use `--bare` flag for scripted/automated Claude invocations — up to 10x startup speed
25. Lifecycle hooks (`SessionStart`, `PreToolUse`) enable consistent context loading per project

### On Voice
26. Primary coding via voice produces better prompts than typing
27. Spoken prompts naturally include more context (you'd feel odd speaking just "fix auth")
28. Voice reduces the friction of writing detailed prompts
29. Better prompts = fewer correction turns = better final output
30. Try `/voice` for complex prompting tasks, even if you type for implementation

### On Mobile and Cross-Device
31. iOS/Android app lets you review PRs and approve plans without your laptop
32. `/teleport` and `/remote-control` sync sessions across devices
33. Long-running research tasks run on cloud sessions while you're mobile
34. Start something before a meeting, check on it from your phone
35. Async plan approval: Claude proposes, you approve from phone, Claude continues

---

## Thariq (Anthropic) — Platform Tips

### On Context Management
36. Context rot starts around 300–400k tokens — don't wait until you're out of context to act
37. "Just because you haven't run out of context doesn't mean you shouldn't start fresh"
38. Rewind over correcting: jump back before the mistake, re-prompt with lessons learned
39. `/compact` maintains momentum; `/clear` gives you control — know which you need
40. Subagents garbage-collect exploration noise — use them whenever research would pollute main context

### On the 5 Decision Points
41. After every turn: choose consciously between Continue / Rewind / Compact / Clear / Subagent
42. Most engineers default to Continue when they should Rewind — breaks the habit
43. The cost of re-establishing context (2-3 min) < cost of degraded context (rest of session)
44. When in doubt: clear and start fresh. You lose less than you think.
45. The decision point mindset makes you a better Claude Code user than any single tip

### On Skills
46. Don't include info Claude already knows — focus on your system's specific behavior
47. The Gotchas section is the most valuable part of any skill — built from real failures
48. Skills are folders with progressive disclosure, not monolithic markdown files
49. Give Claude goals and constraints, not rigid steps — goals survive environment changes
50. Measure skill effectiveness via usage logs — undertriggering = wrong description

### On the 9 Skill Types
51. Library & API Reference skills fill the gap between training cutoff and your internal tools
52. Product Verification skills encode user flows that must work — not just tests
53. Data Fetching skills let Claude query your actual data during debugging
54. Business Process skills automate workflows involving multiple systems
55. Code Scaffolding skills encode your team's exact patterns — eliminate "follow the pattern in X"
56. Code Quality skills encode the standards linters can't catch
57. CI/CD skills handle deployment workflows with judgment calls
58. Runbook skills make incident response actionable (not just readable)
59. Infrastructure skills provide safe guardrails for engineers doing rare infra tasks

### On Session Strategy
60. Session-per-phase for large features — each phase gets fresh context
61. Use git commits as cheap context restoration points
62. Handoff notes between sessions prevent losing progress
63. New task + related concern = consider whether to continue or start fresh
64. The most common mistake: extending sessions too long and accepting degraded quality

### On Team Patterns
65. Skills that benefit the whole team belong in the repo — commit them
66. Usage logging identifies which skills are most valuable to your team
67. Organic curation: skills move to "official" status after demonstrating traction
68. Build team skills from real workflows, not theoretical ones
69. A skill that nobody uses is dead weight — prune regularly
70. The best skills are built from "we always explain this to new engineers" moments

---

## Synthesis: The Most Impactful 10

If you could only do 10 things from this list:

1. **Verification loops** — PostToolUse hook running tests automatically (Boris #1)
2. **Rewind over correct** — break the correction habit immediately (Thariq)
3. **CLAUDE.md → living document** — update after every mistake (Boris)
4. **Plan mode first** — every non-trivial task (Boris)
5. **Session-per-phase** — isolate research, planning, execution (Thariq)
6. **Commit slash commands** — automate any repeated workflow (Boris)
7. **Subagents for research** — keep main context clean (Thariq)
8. **Model for the task** — Opus for decisions, Sonnet for grinding (Boris)
9. **Skill Gotchas section** — encode every failure into the skill (Thariq)
10. **Compact with hints** — don't compact blindly, tell Claude what matters (Thariq)
