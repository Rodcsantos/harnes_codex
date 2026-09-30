---
name: flow-review
description: "Independent review of the current diff by reviewer and, when relevant, security_reviewer. Use after verify passes and before commit or PR."
---

# Flow: Review

1. Compute the base (`git merge-base HEAD origin/main` or the branch base) and give reviewers the diff range, not the whole repo.
2. Run `reviewer` always. Run `security_reviewer` too when the diff touches auth, input handling, secrets, dependencies, SQL, file access or infrastructure. They run in parallel with clean context.
3. MUST-FIX items go back to the owning specialist, then re-run `flow-verify` and re-review only the changed hunks.
4. Loop at most 2 rounds; then present the remaining findings to the user.

Output: verdict per reviewer plus the MUST-FIX list. Ignore style noise handled by formatters.
