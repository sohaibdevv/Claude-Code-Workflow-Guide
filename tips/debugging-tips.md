# Debugging Tips — Systematic Bug Investigation

---

## Evidence Collection

**1. Share the full error, not a paraphrase**
Not "there's an auth error." The full stack trace, the exact error message, the HTTP response body.

**2. Include what changed**
"This worked yesterday. Here's the git diff since it last worked: [diff]"

**3. Specify the reproduction steps**
From a clean state: exactly what commands/actions produce the error every time.

**4. Include environment details**
Node version, OS, whether it's dev/staging/prod, how long ago it started.

**5. Share what you've already tried**
Saves Claude from suggesting things you've ruled out. Focuses the search.

---

## Hypothesis-Driven Debugging

**6. Get hypotheses before investigation**
"Before looking at any code, list 5 hypotheses ordered by likelihood"

**7. Assign probabilities**
"For each hypothesis, estimate the probability it's the root cause (must sum to 100%)"

**8. Design the cheapest test first**
"What's the cheapest test that would confirm or deny your top hypothesis?"

**9. Update hypotheses as evidence comes in**
After each test: "Cross off the disproven hypotheses. What's your updated top hypothesis?"

**10. Distinguish symptoms from causes**
"That's a symptom. What's causing it?" Repeat until you reach root cause.

---

## Code Reading Tips for Debugging

**11. Follow the data, not the code**
"Trace the path of the userId from request input to database query. Show me every transformation."

**12. Find where the invariant breaks**
"This value should always be positive. Find where in the call chain it becomes negative."

**13. Compare working vs. broken**
"Here's the working code and here's the broken version. What's the difference?"

**14. Check assumptions explicitly**
"What assumptions does this code make about its inputs? Are any of them wrong for our case?"

**15. Look for the silent error**
"Is there anywhere in this path where an error could be caught and ignored?"

---

## Common Bug Patterns to Check

**16. Off-by-one errors**
Arrays, loops, pagination — always check boundary conditions.

**17. Timezone issues**
"Is any date comparison or transformation assuming a specific timezone?"

**18. Race conditions**
"Could two concurrent requests cause this? What happens if two users trigger this at the same time?"

**19. Cache inconsistency**
"Is there a cache between the write and read? Could stale data explain the behavior?"

**20. Type coercion surprises**
In JavaScript: `0 == false`, `"" == false`, `null == undefined`. Ask explicitly.

**21. Async ordering**
"Could these two awaits complete in a different order under load?"

**22. Error swallowing**
`try { ... } catch(e) {}` — empty catch blocks, ignored promises, unhandled rejections.

**23. Environment mismatch**
"Does this behave differently in development vs. production? What's different between them?"

**24. Dependency version mismatch**
"Was a dependency recently updated? Could the behavior change explain this?"

**25. Permissions or auth**
"Is this a permissions issue masquerading as a data issue? What user/role is the request running as?"

---

## Regression Prevention

**26. Write a test that catches the bug first**
Before fixing: write a failing test that reproduces the exact bug. Then fix it. The test prevents recurrence.

**27. Find similar bugs in the codebase**
"Is this pattern repeated elsewhere? Run a search and find any other instances."

**28. Ask about the blast radius**
"How many other places in the codebase could have the same bug? Find them."

**29. Document the root cause**
In the commit message or PR: what was the root cause, not just what changed.

**30. Post-mortem the process**
"Why wasn't this caught by tests? What test should have existed?"

---

## Debugging Mindset

**31. Trust the error message**
Especially in TypeScript/Rust/Go — the compiler is usually right, your mental model is usually wrong.

**32. Reduce before investigating**
Can you reproduce the bug with less code? Simpler inputs? Minimum reproduction case.

**33. Print state at the key moment**
"Add a console.log at line 47 that prints all the relevant state just before the failure"

**34. Bisect with git**
`git bisect` to find exactly which commit introduced the bug. Claude can help run the bisect.

**35. Read the source, not the docs**
When a library behaves unexpectedly, read its source code. Documentation can be wrong or outdated.

---

## Claude-Specific Debugging Tips

**36. Give Claude the full context upfront**
Don't drip-feed information. One comprehensive prompt > five back-and-forth messages.

**37. Ask Claude to rubber duck**
"I'm going to explain this to you out loud. Tell me if you spot the bug."

**38. Ask for multiple approaches**
"What are 3 different ways we could isolate this bug?"

**39. Don't accept "try X" suggestions**
Ask WHY X would fix it. Understanding the root cause matters more than the fix.

**40. Verify the fix explains the symptoms**
"Does this fix explain ALL of the symptoms we observed? Or just some?"
