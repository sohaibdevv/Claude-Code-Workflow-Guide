# TDD Workflow — Test-Driven Development with Claude Code

Using Claude Code for TDD produces significantly better code than asking it to implement features directly. The test-first constraint forces precise specification and prevents over-engineering.

---

## The TDD Spiral

```
          ┌─────────────────────────────┐
          │                             │
          ▼                             │
     Write failing test                 │
          │                             │
          ▼                             │
     Confirm it fails                   │
          │                             │
          ▼                             │
     Write minimum code to pass    ─────┘ (repeat)
          │
          ▼
     Refactor (optional)
          │
          ▼
     All tests pass?
          │
          ▼
     Feature complete → Ship
```

---

## Phase 1: Specify with Tests

Instead of "implement X", say "write a failing test for X".

**Prompt**:
```
Write a failing test for: [feature description]

Before writing the test, ask me:
1. What are the inputs?
2. What is the expected output?
3. What errors should it handle?
4. Are there any edge cases I care about?

Then write the test. Do not implement the feature yet.
```

The clarifying questions often reveal requirements that weren't fully specified.

**Good test characteristics**:
```typescript
// Tests behavior, not implementation
describe('calculateOrderTotal', () => {
  it('applies percentage discount to subtotal', () => {
    const order = { items: [{ price: 100 }], discountPercent: 10 };
    expect(calculateOrderTotal(order)).toBe(90);
  });

  it('applies maximum discount cap of 50%', () => {
    const order = { items: [{ price: 100 }], discountPercent: 60 };
    expect(calculateOrderTotal(order)).toBe(50); // capped at 50%
  });

  it('handles empty items array', () => {
    const order = { items: [], discountPercent: 10 };
    expect(calculateOrderTotal(order)).toBe(0);
  });
});
```

---

## Phase 2: Confirm the Test Fails

```bash
npm test -- --testPathPattern="calculateOrderTotal"
# Expected: FAIL (1 suite, 3 failed)
```

If it passes before implementation, the test is wrong. Fix it first.

---

## Phase 3: Minimum Implementation

**Prompt**:
```
The test is confirmed failing. Now write the minimum implementation to make 
ALL tests pass. 

Rules:
- Write only what's needed to pass the tests
- Do not add features not tested
- Do not optimize prematurely
- Hardcoding is OK at this stage if it makes tests pass (we'll refactor)
```

Then run the tests:
```bash
npm test -- --testPathPattern="calculateOrderTotal"
# Expected: PASS (1 suite, 3 passed)
```

---

## Phase 4: Refactor (Optional)

Only if the implementation is messy. Keep tests green throughout.

```
The tests are passing. The implementation is correct but [reason for refactor].
Refactor it [goal: readability / performance / extracting shared logic].
After each change, re-run the tests to confirm they still pass.
```

---

## Phase 5: Integration Tests

After unit tests pass, add integration tests that test the full flow:

```
Unit tests pass for calculateOrderTotal. 
Now write an integration test that:
1. Creates a real order in the test database
2. Calls the full checkout endpoint
3. Verifies the correct total is returned
4. Verifies the discount is recorded in the database
```

---

## TDD for Bug Fixes

TDD is especially valuable for bug fixes — it prevents regressions.

```
Bug report: calculateOrderTotal returns negative values when discountPercent > 100.

Before fixing:
1. Write a failing test that reproduces the bug
2. Confirm the test fails with the current code
3. Fix the bug
4. Confirm the test passes
5. The test will prevent this regression in the future
```

---

## When TDD Slows You Down

TDD isn't always the right tool:

**Skip TDD for**:
- Pure UI layout changes
- Config file changes
- Migrations (test at integration level instead)
- Spike/prototype code (write tests when making it permanent)

**Always use TDD for**:
- Business logic
- Data transformations
- Validation logic
- Error handling
- Anything that handles money
