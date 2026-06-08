# Spec-First Development

Spec-first means writing a precise specification before writing any code. The specification becomes the contract that the implementation must satisfy — and Claude can both write the spec and verify the implementation against it.

---

## Why Spec-First

The most common source of rework: implementing the wrong thing correctly. You build exactly what was asked for, then discover the requirements were underspecified. Spec-first forces requirements to be explicit before any code is written.

Benefits:
- Bugs caught at spec time cost 1x. Bugs caught in code review cost 10x. Bugs caught in production cost 100x.
- The spec becomes documentation
- The spec enables better tests
- The spec makes PR reviews faster

---

## Phase 1: Generate the Spec

**Command**: `/spec "feature description"`

Or use this prompt:
```
Generate a complete spec for: [feature]

Before writing the spec, ask me these questions:
1. Who are the users and what problem does this solve?
2. What are the explicit success conditions?
3. What is out of scope?
4. Are there performance or scale requirements?
5. What error states need to be handled?

After my answers, write the full spec.
```

**Spec structure**:
```markdown
# Spec: [Feature Name]

## Status: Draft | Approved | Implemented

## Problem Statement
[1-2 sentences on what problem this solves and for whom]

## Success Criteria
The implementation is complete when:
- [ ] [Specific, testable condition 1]
- [ ] [Specific, testable condition 2]

## User Stories
As a [user type], I want [action] so that [benefit].

## Functional Requirements
### Must Have (P0)
- [requirement 1]
- [requirement 2]

### Should Have (P1)
- [requirement]

### Won't Have (explicitly out of scope)
- [excluded item]

## Edge Cases
| Scenario | Expected Behavior |
|---|---|
| [edge case 1] | [what should happen] |
| [edge case 2] | [what should happen] |

## Error States
| Error | User-Facing Message | System Behavior |
|---|---|---|
| [error type] | [message] | [what the system does] |

## API Contracts (if applicable)
### Request
```json
{ "field": "type description" }
```

### Response
```json
{ "field": "type description" }
```

### Error Responses
- 400: [when/what]
- 401: [when/what]
- 500: [when/what]

## Non-Functional Requirements
- Performance: [operation] must complete in under [N]ms for [N] users
- Security: [specific security requirements]
- Reliability: [uptime/availability requirements]

## Open Questions
- [Question that needs an answer before implementation]
```

---

## Phase 2: Review and Approve

Before proceeding to implementation:

1. Read every success criterion — can you test each one?
2. Read every edge case — does the expected behavior make sense?
3. Read the out-of-scope section — is anything important missing?
4. Identify open questions that must be answered first

Common spec review questions:
- "What if a user does X while Y is happening?" (concurrency)
- "What's the behavior when we have 0 items? 1 item? 10,000 items?" (edge cases)
- "What happens when the downstream service is unavailable?" (failure modes)
- "Does this need to be backwards compatible?" (versioning)

---

## Phase 3: Implement to Spec

**Prompt**:
```
The spec has been approved. Implement it.

At each step, explicitly map your implementation to the spec's success criteria.
When you complete a success criterion, mark it: ✓ [criterion]
If you discover the spec is ambiguous during implementation, stop and ask for clarification — don't make assumptions.
```

Mapping implementation to spec criteria keeps the work honest and makes review easier.

---

## Phase 4: Verify Against Spec

**Prompt**:
```
Implementation complete. Verify it against the spec.

For each success criterion, confirm:
- Is it satisfied?
- What test verifies it?
- If not satisfied, what's missing?

For each edge case, confirm:
- Is it handled?
- How?
```

This verification step catches "technically implemented but spec-noncompliant" issues that code review often misses.

---

## Spec Maintenance

Specs rot when the code changes without updating them. Treat spec updates as mandatory alongside code changes:

```bash
# Before merging:
# .claude/commands/verify-spec.md
Verify that all changes in this PR are reflected in the spec.
Are there any spec sections that are now outdated?
Are there any new behaviors that aren't documented in the spec?
```
