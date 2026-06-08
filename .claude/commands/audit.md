# /audit — Security & Quality Audit

Run a comprehensive audit of: $ARGUMENTS

If no argument, audit all files changed since last commit.

## Security Audit

### Secrets & Credentials
Search for hardcoded:
- API keys, tokens, passwords
- Database connection strings
- Private keys or certificates
- Internal URLs or IP addresses

```bash
grep -rn "password\|secret\|token\|api_key\|apikey\|private_key" --include="*.ts" --include="*.js" --include="*.py" .
```

### Injection Vulnerabilities
- SQL queries built with string concatenation
- Shell commands built from user input
- Template injection risks

### Authentication & Authorization
- Are all sensitive routes protected?
- Is authorization checked (not just authentication)?
- Are JWT secrets properly managed?
- Are session tokens properly invalidated?

### Dependencies
```bash
npm audit
```
Report any HIGH or CRITICAL vulnerabilities.

### OWASP Top 10 Checklist
- [ ] A01: Broken Access Control
- [ ] A02: Cryptographic Failures
- [ ] A03: Injection
- [ ] A04: Insecure Design
- [ ] A05: Security Misconfiguration
- [ ] A06: Vulnerable Components
- [ ] A07: Auth Failures
- [ ] A08: Software Integrity Failures
- [ ] A09: Logging Failures
- [ ] A10: SSRF

## Quality Audit

### Code Complexity
Find functions with high cyclomatic complexity (many branches).

### Dead Code
Find exports/functions that are defined but never imported/called.

### Test Coverage Gaps
Find files with no corresponding test files.

## Output
Report all findings grouped by severity: Critical → High → Medium → Low → Info
