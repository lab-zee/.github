# Working agreements

These agreements turn the [engineering standards](engineering-standards.md)
into routine decisions. Repository-specific guidance may add constraints but
should document any exception to the organization standard.

## Change discipline

- Prefer prevention and automation when they cost less than repeated
  regressions, diagnosis, and repair.
- Keep changes small enough to understand, test, review, and revert. Separate
  unrelated cleanup from behavior changes.
- Use plain, concise language. Name the problem, decision, evidence, and next
  action without inflated claims.
- Distinguish observed facts from assumptions. State material uncertainty and
  identify the quickest safe way to reduce it.
- Add a regression test with a bug fix when practical. If a reliable automated
  test is not practical, explain why and record the alternative verification.
- Treat CI results as evidence. A green run does not prove correctness, and a
  reviewer remains responsible for reasoning about behavior, risk, and scope.

## Deferred bug issue policy

Create or update a searchable issue when all of the following are true:

1. The bug is confirmed and reproducible.
2. It will be intentionally deferred as separate work rather than fixed in the
   current change.
3. Tracking it gives a future maintainer enough evidence to act.

Search for an existing issue before proposing a new one. A useful issue
contains:

- minimal reproduction steps and environment or version;
- expected and actual behavior;
- user or system impact and known scope;
- logs, failing tests, screenshots, traces, or other sanitized evidence;
- suspected cause clearly labeled as hypothesis when unconfirmed; and
- acceptance criteria, including the regression coverage or verification
  needed to close it.

Do not create issue noise for speculation, unactionable observations,
duplicates, or a bug fixed immediately in the same change. Mention an
immediately fixed bug and its regression evidence in the pull request instead.

External issue creation is a write operation. Create an issue only when the
user or repository guidance authorizes it. Otherwise, produce ready-to-file
title and body content and state that it was not submitted.

## Pull request readiness

Before requesting review:

1. Re-read the request and inspect the complete diff.
2. Remove unrelated changes and generated noise.
3. Run applicable format, lint, typecheck, tests, dead-code, package/artifact,
   and build checks.
4. Confirm bug fixes have practical regression coverage.
5. Update truthful documentation and call out risk, rollout, and uncertainty.
6. Report exact validation performed; do not convert "not run" into a claim.

CI should repeat the repository's blocking checks in a clean environment.
Reviewers should still inspect behavior, security, failure modes, and whether
the tests prove the intended result.

## Synchronizing Cursor guidance

The canonical files under `templates/cursor` are installed into:

- `.cursor/rules/labz-*.mdc`
- `.cursor/skills/labz-*/SKILL.md`

The `labz-` prefix is reserved for organization-managed Cursor guidance. The
synchronizer does not modify `AGENTS.md`, non-prefixed rules or skills, or any
other repository-specific guidance.

### Bootstrap

Download the script as a file, inspect it, and then run it. Do not pipe remote
content directly to a shell.

```bash
mkdir -p scripts
curl --fail --show-error --silent --location \
  https://raw.githubusercontent.com/lab-zee/.github/main/scripts/sync-repository-standards.sh \
  --output scripts/sync-org-standards.sh
chmod +x scripts/sync-org-standards.sh
# Inspect scripts/sync-org-standards.sh before execution.
./scripts/sync-org-standards.sh --write
```

Use `--write` to install or update managed files:

```bash
./scripts/sync-org-standards.sh --write
```

Use `--check` in CI to fail when managed files are missing, stale, or changed:

```bash
./scripts/sync-org-standards.sh --check
```

The default source is the canonical repository's `main` branch. For controlled
rollouts, set `LABZ_STANDARDS_REF` to a reviewed tag or full commit SHA for both
`--write` and `--check`:

```bash
LABZ_STANDARDS_REF=<reviewed-tag-or-sha> \
  ./scripts/sync-org-standards.sh --check
```

Network and download failures are fatal. The script downloads only its explicit
managed manifest into a temporary directory, removes that directory on exit,
and changes only `labz-`-prefixed managed destinations.
