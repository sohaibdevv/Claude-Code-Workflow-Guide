# Prompting Mastery — Getting the Best from Claude Code

The quality of Claude Code's output is directly proportional to the quality of your prompts. This isn't about magic words or tricks — it's about clarity, context, and specificity.

---

## The Fundamental Rule

**Garbage in, garbage out.** Claude is not a mind reader. If your prompt is ambiguous, Claude will make assumptions — and those assumptions may be wrong. The time you spend sharpening a prompt saves multiples of that time in corrections.

---

## The Anatomy of a Great Prompt

```
1. ROLE/CONTEXT   — What situation are we in?
2. TASK           — What specifically do I need?
3. CONSTRAINTS    — What are the boundaries?
4. FORMAT         — How should the output look?
5. EXAMPLE        — What does good look like? (optional)
```

### Weak Prompt
```
"Fix the auth bug"
```

### Strong Prompt
```
We have a Node.js + JWT auth system. Users are being logged out after 15 minutes 
even though we set the token TTL to 24 hours.

Relevant file: src/auth/jwt.ts

The issue started after we deployed the timezone config change last Tuesday.

Find the root cause. Before making any fix, tell me your hypothesis and I'll confirm.
Don't touch any files outside of src/auth/.
```

The strong version: gives context, specifies what changed, points to the right file, asks for hypothesis before action, and sets scope boundaries.

---

## The WHY Principle

Always tell Claude *why* you need something. The why shapes the how.

```
# No WHY — Claude optimizes for... what?
"Refactor the UserService class"

# WITH WHY — Claude optimizes for the actual goal
"Refactor the UserService class for testability — it currently has 5 direct 
dependencies that can't be mocked. New engineers are struggling to write tests for it."

# Different WHY — different optimal solution
"Refactor the UserService class to reduce its size — it's 800 lines and a 
common source of merge conflicts for our 6-person team."
```

---

## Constraint-Driven Prompting

Constraints eliminate entire categories of wrong answers.

```markdown
## Positive constraints (do this):
- "Use the existing error handling pattern in src/errors/"
- "Match the code style in src/routes/users.ts"
- "All new state must go through the Redux store"

## Negative constraints (don't do this):
- "Do not add any new dependencies"
- "Do not modify any test files — I'll update those separately"
- "Do not change the public API of this function"
- "Do not use any TypeScript generics — keep it simple"

## Scope constraints (blast radius):
- "Only touch files in src/auth/"
- "This should be a 1-file change"
- "Limit changes to the database layer — no business logic changes"
```

---

## Reference-Driven Prompting

Point Claude to existing patterns you want followed.

```
"Add a new route for deleting users. Follow the exact same pattern as the 
PUT /users/:id route in src/routes/users.ts — same error handling, same 
response format, same middleware chain."
```

This is dramatically more effective than describing the pattern in words. Claude reads the reference and replicates it.

---

## Phased Prompting for Complex Tasks

Don't give Claude a 10-step task all at once. Break it into phases, review each output, then proceed.

```
Phase 1: "Read src/auth/ and describe the current architecture to me. Don't make any changes."
[Review Claude's understanding]

Phase 2: "Good. Now propose 3 approaches to adding OAuth2 support. Don't implement anything yet."
[Choose the approach]

Phase 3: "Go with approach 2. Before starting, list every file you'll need to modify."
[Verify scope]

Phase 4: "Proceed with implementation. After each file, pause and show me the diff."
[Execute with checkpoints]
```

Each phase is a chance to course-correct before the next one.

---

## The Hypothesis Prompt Pattern

For debugging and investigation, ask for hypotheses before actions:

```
"Here's the error: [stack trace]

Before looking at any files, give me your top 3 hypotheses for what's causing this, 
ordered by likelihood. For each, describe what evidence would confirm it."
```

This forces structured reasoning and gives you a chance to say "that's not it, because..." before Claude goes down the wrong path.

---

## Role Priming

Framing the task as a role shifts Claude's approach:

```
"As a security engineer, review this authentication code for vulnerabilities."
vs.
"Review this authentication code."

"As a performance engineer, look at this database query and tell me what's slow."
vs.
"Is this query efficient?"

"As a senior engineer doing code review, what feedback would you give on this PR?"
vs.
"Review this code."
```

Role priming activates domain-specific reasoning patterns.

---

## Output Format Control

Unspecified output format → Claude guesses. Specify it.

```
# Structured output
"List all issues as: [SEVERITY] file:line — description — suggested fix"

# Comparison tables
"Show me the trade-offs as a markdown table: approach vs complexity vs performance vs maintainability"

# Step-by-step
"Give me numbered steps. Each step should include: what to do, the exact command or code change, and how to verify it worked."

# Diff format
"Show me only the changes you'd make, in diff format (+/- lines)"

# Constrained length
"Summarize in under 5 bullet points"
```

---

## Iterative Refinement

First output is rarely perfect. The second usually is.

```
Turn 1: "Implement the caching layer for the user service"
[Output: correct but too generic]

Turn 2: "Good structure. Two things: 1) the cache key needs to include the tenant ID 
for multi-tenant isolation, 2) the TTL should be configurable via environment variable, 
not hardcoded. Update those two things only."
[Output: exactly right]
```

Targeted refinement is more efficient than starting over. Be specific about what's wrong and what the fix should address.

---

## Prompts That Don't Work

| Ineffective | Why | Better |
|---|---|---|
| "Fix all the bugs" | Too vague, undefined scope | "Fix the null pointer error in processOrder() at src/orders.ts:142" |
| "Make this better" | "Better" is undefined | "Reduce the cyclomatic complexity of this function — aim for under 10" |
| "Explain this code" | Doesn't specify what you need to understand | "Explain how the retry logic works — specifically what triggers a retry and what the backoff strategy is" |
| "Write tests" | No scope, no coverage goal | "Write unit tests for calculateDiscount() covering: zero items, maximum discount cap, and negative price inputs" |
| "Add error handling" | Which errors? What behavior? | "Add error handling for: network timeouts (retry 3x), auth failures (return 401), and unexpected errors (log + return 500)" |

---

## Saving Great Prompts

When you write a prompt that works really well for a recurring task, save it as a command or skill. Stop re-inventing it.

```bash
# Your great debug prompt → becomes /debug command
# Your great review prompt → becomes /review command
# Your great spec prompt → becomes /spec command
```

Build a library of prompts that work. Treat it as an asset.
