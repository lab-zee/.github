---
name: labz-deferred-bug-triage
description: Triage confirmed reproducible bugs deferred as separate work. Use when a bug is discovered but will not be fixed in the current change.
---

# Deferred bug triage

1. Confirm the behavior is reproducible and distinguish evidence from suspected
   cause.
2. Determine whether it is intentionally deferred. Do not create noise for
   speculation, duplicates, or a bug fixed immediately in the current change.
3. Search existing issues when repository access permits.
4. Prepare a record with:
   - concise searchable title;
   - reproduction steps and environment or version;
   - expected and actual behavior;
   - impact and known scope;
   - sanitized logs, tests, traces, or other evidence;
   - hypotheses explicitly labeled as unconfirmed; and
   - acceptance criteria, including regression verification.
5. Create or update an external issue only when the user or repository guidance
   authorizes that write. Otherwise return ready-to-file title and body content
   and say it was not submitted.
