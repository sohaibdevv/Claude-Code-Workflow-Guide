# /debug — Systematic Debugging Workflow

Debug the following issue: $ARGUMENTS

## Debugging Protocol

### Phase 1: Understand the Problem
1. Restate the bug in precise terms
2. What is the expected behavior?
3. What is the actual behavior?
4. When did it start happening? (recent change? always been there?)

### Phase 2: Gather Evidence
```bash
# Get relevant logs
# Get the stack trace
# Read the failing test output
```

Read the relevant files — focus on the code path from input to the failure point.

### Phase 3: Form Hypotheses
List 3-5 possible root causes, ordered by likelihood. For each:
- What evidence supports it?
- What evidence would disprove it?

### Phase 4: Test Hypotheses
For each hypothesis (most likely first):
1. What's the cheapest test to confirm/deny it?
2. Run that test
3. Update hypothesis list based on result

### Phase 5: Fix
Once root cause is identified:
1. Make the minimal change to fix it
2. Do not fix other things you notice while here (separate PR)
3. Run tests to confirm fix works
4. Add a regression test

### Phase 6: Post-Mortem
- What was the root cause?
- Why wasn't it caught by tests?
- What test should we add?
- Is this pattern repeated elsewhere in the codebase?

Report findings at each phase before proceeding to the next.
