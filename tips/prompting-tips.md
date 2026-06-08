# Prompting Tips — 40 Ways to Get Better Output

---

## Clarity Tips

**1. State the outcome, not the method**
"Give me a function that validates email format" → "Give me a function that returns true for valid RFC 5321 email addresses and false otherwise, using only the standard library"

**2. Use "before and after" framing**
"Here's the current behavior: [A]. Here's what I need: [B]. What's the minimum change to get there?"

**3. Quantify vague terms**
"Make it faster" → "Reduce P99 latency from 800ms to under 200ms"
"Make it simpler" → "Reduce cyclomatic complexity below 10"
"Make it cleaner" → "Extract the repeated validation logic into one shared function"

**4. Specify the audience for explanations**
"Explain this like I'm a senior backend engineer who's never touched mobile"
"Explain this assuming I understand Redux but not MobX"

**5. State what you've already tried**
"I tried X and got error Y. I tried Z and got error W. Now help me figure out what's wrong."

---

## Constraint Tips

**6. Give explicit negative constraints**
"Do not add any new npm dependencies"
"Do not change the public API signature"
"Do not touch the test files — I'll update those separately"
"Do not use TypeScript generics — keep it simple for junior engineers"

**7. Scope the blast radius**
"Changes should be limited to src/auth/"
"This should touch at most 3 files"
"Keep the diff under 50 lines"

**8. Specify irreversibility**
"This modifies the database schema. Be very careful and give me a rollback plan."
"These files are auto-generated — don't edit them."

**9. Set quality bar explicitly**
"Write this as if it's going into a production codebase that will be maintained for 5 years"
"This is a quick prototype — readability over elegance"
"A junior engineer will maintain this — comment non-obvious parts"

**10. Reference examples to follow**
"Follow the exact same pattern as the GET /users endpoint in src/routes/users.ts:42"
"Match the error handling style in src/middleware/error.ts"

---

## Structure Tips

**11. Number multi-step instructions**
Claude follows numbered lists more reliably than prose instructions.

**12. Use headers for complex prompts**
```
## Context
[background]

## Task
[what to do]

## Constraints
[what not to do]

## Output Format
[how to respond]
```

**13. Put the most important constraint last**
The last thing you say before Claude responds gets the most weight.

**14. Separate analysis from action**
"First, analyze X. Then, after I confirm, implement Y."
Never analyze AND implement in one shot for complex tasks.

**15. Use bullet points for options, numbered lists for steps**
Options: bullets (unordered). Steps: numbers (ordered). This matches how Claude processes them.

---

## Investigation Tips

**16. Ask for hypotheses first**
"Before looking at any code, give me your top 5 hypotheses for why this is broken"

**17. Ask Claude to prove it wrong**
"Now argue against your top hypothesis. What evidence would disprove it?"

**18. Binary search framing**
"What's the single simplest thing we could test to cut the problem space in half?"

**19. Ask for failure modes**
"What are the 3 most likely ways this implementation will fail in production?"

**20. Request the rubber duck**
"I'm going to explain my understanding of how this works. Tell me where I'm wrong."

---

## Output Control Tips

**21. Specify exact output format**
"Output as: [SEVERITY] file:line — issue — fix"
"Output as a markdown table"
"Output as a numbered action plan, each step under 1 sentence"

**22. Ask for a summary first**
"Give me a 3-bullet summary first, then the full details below"

**23. Set response length**
"Keep your response under 200 words"
"Give me the full implementation — don't abbreviate"

**24. Request structured data**
"Return JSON, not prose: { findings: [], recommendation: '' }"

**25. Ask for alternatives**
"Show me 3 ways to solve this. Recommend one with a single sentence explanation."

---

## Context Building Tips

**26. Give historical context**
"This worked fine until last Tuesday's deploy. Here's what changed: [diff]"

**27. Explain business constraints**
"We can't add a database column without a zero-downtime migration strategy"
"This service handles PCI data — every change needs an audit trail"

**28. Share your mental model**
"I think the bug is in the cache invalidation logic. Is that right?"
Even if wrong, giving Claude your hypothesis focuses the investigation.

**29. Provide the error message verbatim**
Not "there's an auth error" but the actual stack trace and response.

**30. Give the full reproduction steps**
Step-by-step from a clean state. Assumes nothing. Claude can't test it — you have to be complete.

---

## Iteration Tips

**31. Targeted corrections**
"Only fix the null pointer issue. Leave the logging changes for now."
"The logic is right. The naming is wrong. Rename only."

**32. Confirm what's right first**
"The approach is right. The implementation has one issue: [specific issue]. Fix just that."

**33. Give positive feedback on what worked**
"The error handling is perfect. Keep that. The retry logic needs work."

**34. Ask for alternatives when output is wrong**
"That didn't work. Show me 2 different approaches."

**35. Ask Claude to critique its own output**
"Review what you just wrote. What's the weakest part? How would you improve it?"

---

## Advanced Tips

**36. Chain prompts deliberately**
Each prompt builds on the previous. The order matters. Research → Plan → Implement.

**37. Use role priming for different perspectives**
"As a security engineer..." / "As a new user of this API..." / "As the on-call engineer at 3am..."

**38. Ask for the opposite**
"Show me how NOT to do this. What would the bad implementation look like?"

**39. Ask for the edge case test**
"Write a test that would catch the exact class of bug that just happened"

**40. End with a clarifying question**
"After seeing the implementation — is there anything I should know that I didn't ask about?"
