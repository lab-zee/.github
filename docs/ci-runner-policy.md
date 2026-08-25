# CI runner policy

This policy keeps quality feedback reliable while controlling private-repository
runner cost and avoiding unverified infrastructure assumptions.

## Public repositories

Use GitHub-hosted standard runners for public repositories. Eligible public
repository usage is free under GitHub's current Actions policy, and standard
runners avoid maintaining custom images or credentials.

- Default to `ubuntu-latest` unless the supported product requires another
  operating system.
- Keep permissions read-only for quality workflows.
- Use explicit timeouts and cancel superseded branch or pull-request runs.
- Do not introduce self-hosted, larger, or third-party runners without a
  measured requirement and an approved policy exception.

## Private repositories

Private repositories should use one consolidated, cached quality job:

- check out once and install dependencies once;
- restore only trustworthy ecosystem caches;
- run format, lint, typecheck, tests, dead-code checks, and build sequentially
  in that job;
- set a realistic `timeout-minutes`;
- declare caller-level `concurrency` with `cancel-in-progress: true`; and
- retain only useful logs and artifacts for a bounded period.

Consolidation trades some parallelism for less setup time and lower billed
runner usage. Split jobs only when measurements show a material reliability or
feedback benefit that justifies the additional setup and compute.

## Long private workflows

Move materially long private-repository workflows to CircleCI when CircleCI is
the approved provider for that repository. A sustained runtime above **five
minutes** is the default review threshold, not an absolute rule. Consider
queueing, cache hit rate, pull-request frequency, platform requirements,
failure feedback, migration overhead, and total cost before moving.

After migration, keep one authoritative provider for the same gate. Do not run
equivalent GitHub Actions and CircleCI pipelines indefinitely. A short,
time-boxed comparison during migration is acceptable when it has an owner and
removal date.

## Runner and provider decisions

- GitHub-hosted standard runners are the documented default.
- CircleCI is the documented alternative for materially long private
  workflows.
- Do not design around self-hosted runners, Blacksmith, larger runners, or
  special pricing until access, security review, runner compatibility, and
  economics are verified.
- Never send secrets to untrusted pull-request code or use privileged
  `pull_request_target` execution to run fork code.
- Pin third-party actions to a reviewed major, release, or commit according to
  repository risk, and keep them updated.

Record provider exceptions and material changes using the exception process in
[engineering standards](engineering-standards.md).

## Caller responsibility

Reusable workflows centralize steps, but caller workflows own event triggers,
branch filters, and concurrency. Every caller must include cancellation similar
to:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true
```

Concurrency is intentionally omitted from reusable workflows because GitHub's
caller/callee context and group behavior can cause one workflow to cancel
another. Repository rulesets or branch protection must separately make the
resulting quality job a required check.
