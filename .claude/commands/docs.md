# /docs — Generate Documentation

Generate documentation for: $ARGUMENTS

If no argument, document recent changes or the whole module.

## Documentation Targets

### For Functions / Methods
Generate JSDoc / docstring format:
```typescript
/**
 * [One-line summary]
 *
 * [Optional longer description if behavior is non-obvious]
 *
 * @param paramName - Description
 * @returns Description of return value
 * @throws ErrorType - When this occurs
 * @example
 * const result = myFunction(input);
 */
```

### For Modules / Files
Generate a header comment explaining:
- What this module does
- What it does NOT do (boundaries)
- Key dependencies
- Usage example

### For APIs
Generate OpenAPI-style documentation:
- Endpoint path and method
- Request body schema
- Response schema
- Error responses
- Example request/response

### For Architecture Decisions
Generate an ADR (Architecture Decision Record):
```markdown
# ADR-NNN: [Title]

## Status: [Proposed / Accepted / Deprecated]

## Context
What situation led to this decision?

## Decision
What was decided?

## Consequences
What are the trade-offs?
```

## Style Rules
- Explain WHY, not WHAT (the code explains what)
- Keep it short — a confused reader is not helped by more words
- Include examples for non-obvious usage
- Update, don't duplicate the README
