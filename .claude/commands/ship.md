# /ship — Prepare and Ship Current Feature

Prepare the current branch for review and deployment.

## Pre-Ship Checklist

Run each step in order. Stop and report if any step fails.

### 1. Code Quality
```bash
npm run lint
npm run typecheck
```

### 2. Tests
```bash
npm test
```
Report: test count, pass/fail, coverage if available.

### 3. Self-Review
Review the diff of all changes since branching from main:
```bash
git diff main...HEAD
```

Check for:
- [ ] No debug/console.log statements left in
- [ ] No hardcoded secrets or API keys
- [ ] No TODO/FIXME comments that should be resolved before ship
- [ ] No commented-out code blocks
- [ ] No `any` type casts in TypeScript
- [ ] All new functions have appropriate error handling

### 4. Security Check
Scan changed files for:
- Exposed credentials or secrets
- SQL injection vulnerabilities
- XSS vectors
- Insecure dependencies (if package files changed)

### 5. Generate PR Description
Create a PR description with:
- **Summary**: What does this change do? (2-3 sentences)
- **Why**: What problem does it solve?
- **How**: High-level approach
- **Testing**: How was this tested?
- **Screenshots**: (if UI changes)
- **Checklist**: Items reviewer should verify

### 6. Create PR
```bash
gh pr create --title "[descriptive title]" --body "[generated description]"
```

Report the PR URL when done.
