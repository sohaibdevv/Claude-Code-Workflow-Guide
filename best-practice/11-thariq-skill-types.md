# Thariq's 9 Skill Types — The Complete Framework

Thariq from Anthropic's Claude Code team identified that skills cluster into **9 distinct categories**, each with different design patterns. This is the most systematic framework for building skills that actually work.

---

## Why This Matters

Most developers build skills ad-hoc — they think "I repeat this task, I'll make a skill for it." This produces a scattered skill library that's hard to maintain and often triggers incorrectly.

Thariq's framework gives you a mental model: **identify which type of skill you're building first, then apply the patterns for that type.**

---

## The 9 Skill Types

### Type 1: Library & API Reference

**What it is**: Skills that give Claude access to documentation, API specs, or library knowledge that isn't in its training data.

**When to build it**: Your team uses an internal SDK, a niche library, or an API version newer than Claude's training cutoff.

**Design pattern**:
```markdown
---
name: internal-sdk-reference
description: Use when working with our internal payment SDK, calling PaymentService methods, or integrating with our billing system.
---

# Internal Payment SDK Reference

## Available Methods
[list methods with signatures]

## Common Patterns
[code examples for the 3-4 most common operations]

## Gotchas
[known issues and how to avoid them]
```

**Key insight**: Don't paste the full docs. Claude knows general patterns. Give it only the **delta** — what's different from standard patterns, what's non-obvious, what trips people up.

---

### Type 2: Product Verification

**What it is**: Skills for verifying that a feature works correctly from a user perspective — not just that tests pass, but that the product behavior is right.

**When to build it**: You have specific user flows that must work end-to-end. Manual QA is slow.

**Design pattern**:
```markdown
---
name: checkout-verification
description: Use when verifying the checkout flow works, testing the payment page, or checking order confirmation.
---

# Checkout Flow Verification

## Happy Path
1. Add item to cart
2. Navigate to /checkout
3. Verify: price shows correctly
4. Verify: address form validates properly
5. Verify: submit creates an order in the DB
6. Verify: confirmation email queued

## Edge Cases
- Cart with 0 items → should redirect to /cart
- Logged-out user → should redirect to /login with return URL
- Invalid card → should show specific error, not generic failure
```

---

### Type 3: Data Fetching & Analysis

**What it is**: Skills that let Claude query data sources and analyze results.

**When to build it**: Engineers regularly need to query the database, BigQuery, or analytics platforms to understand the system.

**Design pattern**:
```markdown
---
name: query-user-metrics
description: Use when analyzing user behavior, checking signup rates, investigating user activity patterns, or debugging user-specific issues.
---

# User Metrics Queries

## Environment Setup
```bash
export DB_URL="${STAGING_DB_URL}"  # use staging by default
```

## Common Queries

### Active users in last 30 days
```sql
SELECT COUNT(DISTINCT user_id) 
FROM events 
WHERE created_at > NOW() - INTERVAL '30 days'
  AND event_type = 'session_start';
```

### User funnel
[funnel query here]

## Gotchas
- Always use staging DB unless explicitly asked for production
- The `events` table is partitioned by month — always include date filter
```

---

### Type 4: Business Process Automation

**What it is**: Skills that automate multi-step business processes — things that involve multiple tools, systems, and decision points.

**When to build it**: Recurring workflows that involve code + external systems (Slack, GitHub, Jira, email).

**Design pattern**:
```markdown
---
name: onboard-new-engineer
description: Use when onboarding a new team member, setting up a new engineer's access, or creating a new developer account.
---

# New Engineer Onboarding

## Steps
1. Create GitHub org invite: `gh api orgs/myorg/invitations --method POST`
2. Add to Linear team: [use Linear MCP tool]
3. Create Slack channel invite
4. Send welcome message with: [template]
5. Create starter issue for their first task
6. Set up their branch permissions

## Required Info
- Name, email, GitHub username, role (eng/design/PM)
```

---

### Type 5: Code Scaffolding

**What it is**: Skills that generate boilerplate for new features following your team's exact patterns.

**When to build it**: You find yourself explaining "follow the same pattern as X" repeatedly. That explanation should be a skill.

**Design pattern**:
```markdown
---
name: new-api-endpoint
description: Use when creating a new REST endpoint, adding a new route, or building a new API method.
---

# New API Endpoint Scaffold

Follow this exact pattern. Reference src/routes/users.ts as the template.

## Files to Create
1. `src/routes/$NAME.ts` — route definition
2. `src/services/$NAME.ts` — business logic
3. `src/repositories/$NAME.ts` — DB access
4. `tests/unit/services/$NAME.test.ts` — unit tests
5. `tests/integration/$NAME.test.ts` — integration tests

## Pattern Reference
See @references/route-pattern.ts for the full template.
See @references/service-pattern.ts for service pattern.
```

---

### Type 6: Code Quality Review

**What it is**: Skills for systematic code review along specific dimensions.

**When to build it**: Your team has specific quality standards that aren't caught by linters. New engineers often miss the same patterns.

**Design pattern**:
```markdown
---
name: security-review
description: Use when reviewing code for security issues, checking auth changes, or auditing a feature before shipping.
---

# Security Review Checklist

## Authentication & Authorization
- All new routes have the auth middleware applied
- Role checks are at the route level AND service level
- No auth decisions in the repository layer

## Input Validation
- All user inputs validated at the API boundary
- No raw SQL with string interpolation
- File uploads validated (size, type, content)

## Data Exposure
- API responses don't include internal fields
- Error messages don't leak system details
- Logs don't contain PII

## Gotchas (from past incidents)
- The `user.role` field is not trustworthy after serialization — always re-fetch from DB
- Never pass req.body directly to a DB method — always destructure what you need
```

---

### Type 7: CI/CD & Deployment

**What it is**: Skills for deployment workflows, release management, and CI/CD operations.

**When to build it**: Your deployment process has specific steps that aren't captured in scripts. Or the steps require judgment calls.

**Design pattern**:
```markdown
---
name: deploy-hotfix
description: Use when deploying an urgent fix to production, doing an emergency release, or patching a production issue.
---

# Hotfix Deployment

## When to Use This
Only for P0/P1 production issues. For planned releases, use /deploy.

## Steps
1. Create hotfix branch from production tag: `git checkout -b hotfix/$ISSUE v$PROD_VERSION`
2. Apply the fix (minimal change only)
3. Run: `npm test && npm run test:e2e`
4. Create PR against main AND production branch
5. Get approval from on-call + team lead
6. Deploy to staging first, verify
7. Deploy to production
8. Monitor for 30 minutes
9. Merge hotfix to main

## Rollback
See @references/rollback.md
```

---

### Type 8: Runbooks

**What it is**: Skills for incident response, operational tasks, and "break glass" scenarios.

**When to build it**: You have recurring operational issues. Or your team has written runbooks that should be actionable rather than just readable.

**Design pattern**:
```markdown
---
name: investigate-high-error-rate
description: Use when error rate is elevated, investigating a spike in 5xx errors, or responding to an alert about API failures.
---

# High Error Rate Investigation Runbook

## Triage (first 5 minutes)
1. Check Datadog: service:api env:prod status:error | count
2. Identify: is it all endpoints or specific ones?
3. Check deploy history: did a recent deploy coincide?
4. Check downstream services: database, cache, third-party APIs

## Common Causes and Fixes
### Database connection exhaustion
- Symptom: errors spike after deploy, DB CPU normal
- Check: `SELECT count(*) FROM pg_stat_activity WHERE state = 'idle'`
- Fix: restart the connection pool / scale the service

### Memory leak
- Symptom: gradual error rate increase over hours
- Check: container memory metrics in Datadog
- Fix: rolling restart, then investigate leak

## Escalation
If not resolved in 30 minutes: page the on-call lead
```

---

### Type 9: Infrastructure Operations

**What it is**: Skills for infrastructure management — scaling, provisioning, database operations.

**When to build it**: Engineers occasionally need to do infra tasks but aren't infrastructure specialists. Skills provide safe guardrails.

**Design pattern**:
```markdown
---
name: scale-service
description: Use when scaling a service up or down, adjusting replica count, or responding to load increases.
---

# Scale Service

## Before Scaling
1. Confirm the service supports horizontal scaling (stateless?)
2. Check current resource utilization: `kubectl top pods -n production`
3. Identify the bottleneck (CPU? Memory? DB connections?)

## Scale Up
```bash
kubectl scale deployment/$SERVICE_NAME -n production --replicas=$COUNT
```

## Verify
- Watch rollout: `kubectl rollout status deployment/$SERVICE_NAME -n production`
- Confirm new replicas healthy: `kubectl get pods -n production -l app=$SERVICE_NAME`
- Check error rate after scaling

## Gotchas
- Scaling above 10 replicas requires DB connection limit check first
- The worker service is NOT stateless — do NOT scale horizontally
```

---

## Thariq's Skill Design Principles

### 1. Don't Duplicate Claude's Knowledge
```
BAD: "JWT tokens are cryptographically signed..."
     (Claude already knows this)

GOOD: "Our JWTs include a non-standard 'tenant_id' claim.
      Always validate it matches the URL parameter."
     (Claude doesn't know this about your system)
```

### 2. Document the Gotchas Section
Every skill should have a **Gotchas** section — the failure modes that Claude repeatedly hits without it.

```markdown
## Gotchas
- The `created_at` field is stored in UTC but the UI displays in user's timezone — never compare raw timestamps
- This API returns 200 even on errors — check the `success` field in the response body
- The cache key includes the user ID — always invalidate by user, not by resource
```

These come from real failures. When Claude gets something wrong, add the gotcha. The skill gets smarter over time.

### 3. Skills Are Folders, Not Files

```
.claude/skills/
└── deploy-production/        ← folder, not file
    ├── SKILL.md              ← main (concise)
    └── references/
        ├── rollback.md       ← loaded only if needed
        ├── monitoring.md     ← loaded only if needed
        └── checklist.md      ← loaded only if needed
```

The main SKILL.md stays under 50 lines. References are loaded on demand. This prevents context bloat.

### 4. Goals Over Steps

```
BAD: "1. Run npm install. 2. Run npm run build. 3. Copy dist/ to..."
     (Rigid — breaks if any step changes)

GOOD: "Goal: deploy the built artifact to production with zero downtime.
      Constraint: must verify health checks pass before shifting traffic."
     (Flexible — Claude adapts to your actual environment)
```

### 5. Measure Skill Effectiveness

Use the audit logger hook to track which skills trigger:

```bash
# Add to your audit-logger.sh:
if [ "${CLAUDE_TOOL_NAME}" = "Skill" ]; then
  SKILL=$(echo "$TOOL_INPUT" | jq -r '.skill // empty')
  echo "$(date) SKILL_TRIGGERED=$SKILL" >> ~/.claude/skill-usage.log
fi
```

Skills that never trigger → wrong description or unused workflow
Skills that trigger often → your most valuable automations
Skills that trigger incorrectly → description needs refinement
