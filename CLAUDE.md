# CLAUDE.md

Strict TDD with GitHub issue tracking. Use MCP tools exclusively. Bash is last resort.
Work through steps in order. Never skip steps.

Our github repo is: https://github.com/sjhorn/solitaire2

---

## MCP Servers

**server-git** (`mcp__server-git__*`) — local git: status, add, commit, branch, checkout, diff, log, show, reset.
**dart** (`mcp__dart__*`) — analyze, fix, format, test, pub operations.
**github** (`mcp__github__*`) — issues, PRs, repos, actions via GitHub API.

Key github tools used in workflow:
- `issue_write` — create/update issues (including checkbox updates)
- `create_pull_request` — open PRs
- `merge_pull_request`, `pull_request_read`, `update_pull_request`
- `push_files` — commits files via API (not a `git push` of local commits)

**Bash fallbacks** (no MCP equivalent): `git push`, `git pull`, `git fetch`, `flutter pub get`, `flutter pub publish`

---

## Rules

- Never use `git`, `gh`, `dart`, or `flutter` CLI — use MCP equivalents
- Never use shell operators: `>` `>>` `2>&1` `&&` `||` `$()` `|` — one simple command per Bash call
- Use Claude native tools (Read, Edit, Write, Glob, Grep) for file operations
- Never push to `main` directly
- Atomic commits — one logical change per commit
- Never mark a checkbox until the step is verified
- On errors, surface and ask the user before retrying

---

## Implementation Workflow

### 1. Issue First
Create via `mcp__github__issue_write` or accept existing issue number:
```
## Acceptance Criteria
- [ ] ...

## Tasks
- [ ] Branch created
- [ ] Failing test (RED)
- [ ] Tests confirmed failing
- [ ] Implementation (GREEN)
- [ ] All tests passing (90%+ coverage)
- [ ] Analysis clean
- [ ] PR created
```

### 2. Branch
`mcp__server-git__git_create_branch` → `feat/issue-<N>-<slug>` from `main`
`mcp__server-git__git_checkout` → switch to it
Check off *Branch created* via `mcp__github__issue_write`

### 3. RED — Failing Test
Write **minimal** failing test. Mirror paths: `lib/src/domain/foo.dart` → `test/domain/foo_test.dart`
Run via `mcp__dart__*`, confirm failure. Check off RED tasks.

### 4. GREEN — Make It Pass
Write **minimal** implementation. Run full suite via `mcp__dart__*`.
All green, no regressions. Check off GREEN tasks.

### 5. Commit & PR
`mcp__server-git__git_add` + `git_commit`: `feat: <description> (closes #<N>)`
Bash: `git push -u origin feat/issue-<N>-<slug>`
`mcp__github__create_pull_request` with body: `Closes #<N>`, summary, test plan.
Check off *PR created*. Report PR URL and stop.

---

## Domain-Driven Design

```
lib/src/
  domain/          # Entities, value objects, repo interfaces — zero dependencies, pure Dart
  application/     # Use cases — depends only on domain, single-responsibility call()
  infrastructure/  # Repo impls, adapters — implements domain interfaces
  presentation/    # Widgets, state — depends on application, thin trees
```

Entities: immutable, `final` fields, factory constructors.

---

## GitHub Actions Gates

PR merge requires all checks green (`.github/workflows/ci.yml`):
- `dart analyze` — zero issues
- `flutter test` — all pass
- Coverage >= 90%
- `pana` — pub.dev quality gate

Repo includes `.github/ISSUE_TEMPLATE/feature.yml` and `.github/pull_request_template.md`.

---

## Publish to pub.dev

All verification via `mcp__dart__*`. File edits via Claude Edit tool. Fix issues before proceeding.

- [ ] Analyze — zero issues
- [ ] Format — all formatted
- [ ] Test — all pass
- [ ] Coverage — 90%+ confirmed
- [ ] Pana — acceptable score (aim 140/160+)
- [ ] `pubspec.yaml` version bumped (semver)
- [ ] `CHANGELOG.md` updated with version and date
- [ ] `README.md` accurate with example usage
- [ ] `example/` directory has working example
- [ ] `LICENSE` file present
- [ ] Dry-run publish — no issues
- [ ] Publish (Bash fallback: `flutter pub publish`)
