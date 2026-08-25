# Engineering standards

These standards are the default for every actively maintained Lab Z
repository. They apply to application code, libraries, infrastructure,
automation, generated deliverables, and documentation.

## Required blocking gates

Every pull request must run all checks applicable to the changed repository.
Failures block merge:

1. **Format:** verify committed files already match the configured formatter.
   CI must check formatting, not silently rewrite it.
2. **Lint:** enforce correctness and maintainability rules. New warnings are
   failures unless a reviewed baseline explicitly records existing debt.
3. **Typecheck:** run the strictest practical static analysis for typed code.
   Avoid broad exclusions, unchecked escape hatches, and blanket ignores.
4. **Test:** execute meaningful automated tests at the appropriate unit,
   integration, contract, and end-to-end boundaries.
5. **Build:** produce the same packages, sites, binaries, images, or generated
   outputs expected from the supported release path.

Checks should be deterministic, non-interactive, and reproducible locally.
Required status checks and review requirements must be enforced through
repository branch protection or organization rulesets.

## Meaningful test coverage

Coverage supports review; it is not the objective by itself.

- Tests must exercise observable behavior, important branches, failure modes,
  and integration boundaries.
- A test that only confirms a mock returned its configured value, snapshots
  unstable markup without intent, or imports a module without meaningful
  assertions does not establish coverage.
- Mock external boundaries only where isolation is necessary. Keep enough
  integration or contract coverage to prove wiring, serialization,
  authentication, and error handling.
- Coverage reports must reflect files that matter. Do not inflate results by
  excluding difficult production code, counting generated files selectively,
  or adding assertions with no behavioral value.
- Changed behavior requires changed tests unless the pull request explains why
  another form of verification is more reliable.

### Minimum thresholds

Each repository must set defensible line and branch thresholds based on risk,
language, and maturity. As an initial baseline, use at least **80% line
coverage and 70% branch coverage** for testable first-party code, and do not
allow coverage on changed code to regress.

These numbers are a floor for discussion, not a guarantee of quality. Security,
billing, authorization, data integrity, and similarly critical logic should
have materially stronger behavioral coverage. A lower threshold requires a
documented exception and a plan to improve; a higher threshold must not drive
shallow tests.

## Dead code and dependency hygiene

- Run an ecosystem-appropriate unused code, export, file, and dependency check
  (for example, Knip for Node projects) when one is available.
- Remove obsolete code, flags, scripts, assets, and dependencies instead of
  retaining them "just in case." Version control is the archive.
- Direct dependencies must be declared; unused direct dependencies must be
  removed. Lockfiles must be committed and installs in CI must be frozen.
- Keep runtime and development dependencies current through Dependabot or an
  equivalent reviewed update process.
- Do not merge a dependency update solely because CI is green. Review release
  notes, provenance, license, transitive impact, and runtime compatibility in
  proportion to risk.

## Package, crew, and artifact validation

Repositories that publish or assemble packages, crews, manifests, prompts,
images, archives, generated clients, or other artifacts must validate the
deliverable—not only its source files.

- Build or pack the artifact in CI and inspect its expected contents.
- Validate schemas, metadata, entry points, versioning, and references.
- Smoke-test installation or execution from the built artifact where practical.
- For crew definitions and other composed runtime configurations, validate that
  referenced agents, tasks, tools, prompts, and assets exist and can be loaded.
- Fail on stale generated output or uncommitted build-time changes when those
  outputs are versioned.
- Publish only from a reviewed commit through a separate least-privilege release
  workflow; pull-request quality workflows must remain read-only.

## Dependabot

Enable Dependabot for every package ecosystem and for GitHub Actions used by a
repository. Choose a cadence that results in prompt review without creating an
unmanageable queue, group compatible development updates where useful, and
never auto-merge changes that have not passed the same blocking gates and risk
review as human-authored changes.

Dependabot configuration is repository-local. The configuration in the
organization `.github` repository is not inherited by other repositories.

## Truthful documentation

Documentation is part of the product:

- README setup and commands must work from a clean checkout.
- Supported versions, public interfaces, environment variables, deployment
  behavior, examples, and architecture claims must match current code.
- Do not describe planned work as shipped or mark checks, migrations, or
  controls complete without evidence.
- Update or remove stale comments and generated documentation in the same
  change that invalidates them.
- Record operational prerequisites and ownership without committing secrets,
  credentials, internal tokens, or personal contact data.

## Exceptions

An exception must be explicit, narrow, temporary, and approved by the
repository's accountable maintainer. Record it in a visible repository
document or tracked issue with:

- the exact standard being waived;
- the technical or business reason;
- scope and affected risk;
- compensating controls;
- an owner;
- an expiration or review date; and
- a concrete exit plan.

Emergency changes may use an established break-glass process, but must be
auditable and followed promptly by missing tests, documentation, and review.
Convenience, CI cost alone, or inherited technical debt is not a permanent
exception.
