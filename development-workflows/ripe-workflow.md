# The RIPE Workflow — Research, Iterate, Polish, Execute

RIPE is the recommended workflow for features with significant unknowns — where you're not sure exactly what the right approach is before you start.

---

## When to Use RIPE

- Features touching unfamiliar parts of the codebase
- Features with non-obvious architectural implications
- Anything with significant technical risk
- When you're new to a codebase or technology

---

## Phase R: Research

**Duration**: 20-30% of total time  
**Mode**: Read-only exploration

**Goal**: Build complete situational awareness before proposing any solution.

**Protocol**:
```
1. Spawn research subagent
2. Agent maps the relevant codebase area
3. Agent identifies: current patterns, integration points, risks
4. Agent returns structured research report
5. You read and internalize the report
6. Ask follow-up questions if needed
```

**Research subagent prompt**:
```markdown
Research [topic/feature area] in this codebase.

Return:
1. Relevant files with paths and brief descriptions
2. Current architecture for this area (2-3 paragraphs)
3. Key functions/classes with file:line references
4. Existing tests and how they're structured
5. Non-obvious dependencies or constraints
6. 2-3 recommended integration approaches with tradeoffs

Read-only. No modifications.
```

**Checklist before leaving research phase**:
- [ ] You understand the current approach
- [ ] You know which files are in scope
- [ ] You've identified the patterns to follow
- [ ] You've surfaced potential risks

---

## Phase I: Iterate

**Duration**: 15-25% of total time  
**Mode**: Plan mode

**Goal**: Design the solution iteratively until it's right.

**Key insight**: Iteration happens in the planning phase, not the coding phase. Changing direction in a plan costs nothing. Changing direction mid-implementation is expensive.

**Protocol**:
```
Round 1: Draft plan based on research
         → Review, identify weaknesses
         → Ask "what could go wrong?"

Round 2: Revised plan addressing weaknesses
         → Review with fresh eyes
         → Check: does this solve the original problem?

Round 3 (if needed): Final refinements
         → Approval gate
         → Lock the plan
```

**Questions that reveal plan weaknesses**:
- "What happens when the database is unavailable?"
- "How does this behave under concurrent requests?"
- "What's the migration strategy for existing data?"
- "How do we test this in isolation?"
- "What's the rollback procedure if this breaks production?"

---

## Phase P: Polish

**Duration**: 10-15% of total time  
**Mode**: Refinement before and during execution

**Goal**: Pre-execution cleanup to avoid mid-execution surprises.

**Activities**:
- Clarify any ambiguities in the plan
- Write the acceptance criteria
- Set up the test infrastructure before coding
- Identify what "done" looks like

**Acceptance criteria template**:
```markdown
## Acceptance Criteria for [Feature]

### Must Pass
- [ ] [specific test case 1]
- [ ] [specific test case 2]
- [ ] Performance: [operation] completes in under [N]ms

### Must Not Break
- [ ] Existing [related feature] still works
- [ ] No regression in [adjacent system]

### Code Quality
- [ ] Test coverage above [N]%
- [ ] No new security vulnerabilities
```

---

## Phase E: Execute

**Duration**: 50-60% of total time  
**Mode**: Implementation

**Goal**: Code to the approved plan with high quality.

**Execution protocol**:
```
Start from step 1 of the plan
  → Implement
  → Run tests
  → Review diff
  → Proceed if clean
  → Stop if unexpected problem (re-plan if needed)
```

**When to stop and re-RIPE**:
- Discovering the approach won't work (common and OK)
- Finding the scope is much larger than estimated
- Uncovering a hidden dependency that changes the design

Stopping and re-planning mid-execution is not failure. It's good engineering. The alternative — continuing with a known-bad approach — is actual failure.

---

## RIPE vs. Just Coding

| Approach | Typical outcome |
|---|---|
| Just code | Fast start, frequent backtracking, messy final state |
| RIPE | Slower start, rare backtracking, clean final state |

RIPE adds ~30-40% to the upfront time. It saves 2-3x that time in corrections, re-work, and debugging. For any non-trivial feature, RIPE is faster end-to-end.
