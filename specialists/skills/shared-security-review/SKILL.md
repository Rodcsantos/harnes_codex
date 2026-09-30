---
name: shared-security-review
description: "Perform a threat-focused security review of code, design or configuration: trust boundaries, authz, input handling, secrets and dependencies. Use when reviewing a feature for security, auditing an area, or triaging a vulnerability report."
---

# Application Security Review

## Use when
- New auth or data-access paths, handling of untrusted input, file/URL/command sinks, secrets handling, third-party integrations, or a reported vulnerability.

## Diagnose first
- Map assets, actors and trust boundaries: what data matters, who can call what, where untrusted input enters.
- Trace each input to its sinks (query, command, template, filesystem, HTTP fetch, deserializer, log).
- Tooling as a starting point, not a verdict: dependency audit (`npm audit`, `pip-audit`, `composer audit`), secret scanning (gitleaks), SAST (Semgrep, Bandit, language linters).
- Review authentication, session/token handling, and authorization checks at the object level for every entry point.

## Decision rules
- Authentication is not authorization: verify ownership/tenant/role on each object and function; look for IDOR and mass assignment.
- Injection classes: SQL/NoSQL, command, template, header, path traversal, SSRF, XXE, unsafe deserialization: parameterize, allowlist, avoid the sink.
- Output encoding by context; CSRF protections for cookie-based auth; CORS and cookie flags set deliberately.
- Secrets never in code, logs, URLs or client bundles; rotate on exposure; least-privilege credentials.
- Report only findings with a plausible exploit path here: severity, location, steps or conditions, impact, minimal fix; mark theoretical items as such.
- Consider abuse cases: rate limits, enumeration, replay, resource exhaustion.
- Supply chain: new dependencies, install scripts, pinned versions, provenance.

## Anti-patterns
- Reporting scanner output unverified; "add validation" without naming the sink; security by obscurity; treating client-side checks as controls.

## Safety
Test only in authorized environments; never exfiltrate real data or run exploits on production; treat found secrets as compromised and escalate to the owner.

## Verify
- A test or proof of concept in a safe environment demonstrates each finding and shows it fixed; scanners rerun clean or triaged; remaining risk stated.
