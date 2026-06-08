# /review — Deep Code Review

Perform a thorough code review of: $ARGUMENTS

If no arguments provided, review all staged/uncommitted changes.

## Review Dimensions

### 1. Correctness
- Does the code do what it's supposed to do?
- Are edge cases handled?
- Are error conditions caught and handled?

### 2. Security
- Input validation at system boundaries
- SQL injection, XSS, CSRF risks
- Authentication and authorization checks
- Secrets or credentials exposed?
- Dependency vulnerabilities

### 3. Performance
- Unnecessary database queries (N+1 problems)
- Unoptimized loops or algorithms
- Missing indexes on queried columns
- Memory leaks or unbounded caches

### 4. Maintainability
- Is the code readable and self-explanatory?
- Are functions doing too many things?
- Is there duplication that should be extracted?
- Are names clear and consistent with the codebase?

### 5. Test Coverage
- Are there tests for the new functionality?
- Do tests cover failure paths?
- Are tests testing behavior, not implementation?

### 6. Architecture
- Does the change fit the existing patterns?
- Is the abstraction level appropriate?
- Does it create problematic coupling?

## Output Format

For each issue found, report:
```
SEVERITY: [Critical / High / Medium / Low / Nit]
FILE: path/to/file.ts:line
ISSUE: description of the problem
SUGGESTION: how to fix it
```

End with:
- **Overall assessment**: Approve / Request Changes / Needs Major Work
- **Top 3 must-fix items** (if any)
