# Lab Z organization standards

This public special repository is the canonical home for Lab Z's shared
engineering standards, community health files, organization profile, and
reusable CI workflows. Changes here affect how the organization presents and
governs its repositories, so they should receive the same review as production
code.

## Canonical standards

- [Engineering standards](docs/engineering-standards.md) defines the required
  quality gates and the evidence expected from them.
- [CI runner policy](docs/ci-runner-policy.md) defines where and how CI runs.
- [Working agreements](docs/working-agreements.md) defines day-to-day
  engineering and issue-triage practices.
- [Contributing](CONTRIBUTING.md), [security](SECURITY.md),
  [support](SUPPORT.md), and the [code of conduct](CODE_OF_CONDUCT.md) provide
  organization defaults.
- [Reusable workflows](.github/workflows) provide one-job Node and Python
  quality pipelines.
- [Workflow templates](workflow-templates) create caller workflows with the
  required concurrency behavior.

When a repository intentionally differs from these standards, its local
documentation must state the exception, owner, reason, compensating controls,
and review date.

## Working principles

- Automation and prevention are generally cheaper than regressions and repair.
- Bug fixes should include regression tests when practical.
- Use plain, concise language and make small, focused changes.
- State the evidence for conclusions and identify material uncertainty.
- Treat CI as evidence, not a substitute for engineering judgment.

Operational guidance is in [working agreements](docs/working-agreements.md).

## What GitHub inherits

For public repositories in the organization, GitHub can use this repository's
community health files when the target repository does not define its own
equivalent:

- `CONTRIBUTING.md`
- `SECURITY.md`
- `CODE_OF_CONDUCT.md`
- `SUPPORT.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/ISSUE_TEMPLATE/*`

The organization profile is rendered from `profile/README.md`. A file in an
individual repository takes precedence over an inherited community file.

## What is not inherited automatically

Repositories still need local caller files and settings:

1. Add a workflow under `.github/workflows/` by selecting a template from the
   GitHub Actions UI or copying a file from `workflow-templates/`. Reusable
   workflows do not run merely because they exist here.
2. Configure the commands passed to the reusable workflow so every applicable
   format, lint, typecheck, test, dead-code, and build gate is blocking.
3. Keep caller-level `concurrency` cancellation and event/branch filters in the
   local workflow. It is intentionally not declared in the reusable workflows.
4. Add repository-specific Dependabot ecosystems. This repository's
   Dependabot configuration updates only this repository's GitHub Actions.
5. Configure branch protection or organization rulesets, required checks,
   required reviews, merge methods, environments, secret scanning, code
   scanning, and private vulnerability reporting in GitHub settings.
6. Add repository-specific ownership, deployment, support, security, and
   exception details where the inherited defaults are insufficient.

This repository cannot itself enforce organization rulesets or administrative
settings. Organization owners must configure those controls and ensure the
required-check names match each caller workflow.

## Using the reusable workflows

Call one of these workflows from a repository workflow:

```yaml
jobs:
  quality:
    uses: lab-zee/.github/.github/workflows/node-quality.yml@main
    with:
      lint_command: npm run lint
      typecheck_command: npm run typecheck
      test_command: npm test
      build_command: npm run build
```

Use the workflow templates for complete Node and Python callers, including
read-only permissions and cancellation of superseded runs. Before enabling a
template, replace its conventional script names and dependency paths with the
repository's real blocking commands; do not use `--if-present` to make a
required gate pass when its script is missing.

Pinning to `main` automatically receives reviewed standards updates; critical
repositories may instead pin a release tag or full commit SHA and update it
deliberately.

## Synchronizing Cursor guidance

Canonical Cursor rules and skills live under [`templates/cursor`](templates/cursor).
Applications can copy the synchronization script to
`scripts/sync-org-standards.sh`, then use `--write` to install managed
`labz-`-prefixed files or `--check` to detect drift. Repository-specific
`AGENTS.md`, rules, skills, and other local guidance are not overwritten.

Bootstrap without piping remote code into a shell:

```bash
mkdir -p scripts
curl --fail --show-error --silent --location \
  https://raw.githubusercontent.com/lab-zee/.github/main/scripts/sync-repository-standards.sh \
  --output scripts/sync-org-standards.sh
chmod +x scripts/sync-org-standards.sh
# Review the downloaded script before running it.
./scripts/sync-org-standards.sh --write
```

See [working agreements](docs/working-agreements.md#synchronizing-cursor-guidance)
for pinning and CI usage.
