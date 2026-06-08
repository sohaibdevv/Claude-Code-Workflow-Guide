# /spec — Generate Feature Specification

Generate a complete spec for: $ARGUMENTS

## Output Structure

### 1. Feature Summary
One paragraph describing the feature from the user's perspective.

### 2. User Stories
```
As a [user type],
I want to [action],
So that [benefit].
```
Write 3-7 user stories covering the main scenarios.

### 3. Acceptance Criteria
For each user story, list specific, testable conditions:
- [ ] When X happens, Y should occur
- [ ] The system must reject Z with error message "..."
- [ ] Performance: operation completes in under N ms

### 4. Edge Cases
List non-obvious edge cases that must be handled:
- Empty inputs
- Maximum/minimum values
- Concurrent operations
- Network failures
- Invalid state transitions

### 5. Out of Scope
Explicitly list what is NOT included in this feature.

### 6. Technical Notes
Implementation constraints or considerations:
- Database schema changes needed
- API changes (breaking vs. non-breaking)
- Dependencies or blockers

### 7. Test Plan
High-level test scenarios (unit, integration, E2E).

---

Once spec is approved, run `/implement-spec` to begin coding to these requirements.
