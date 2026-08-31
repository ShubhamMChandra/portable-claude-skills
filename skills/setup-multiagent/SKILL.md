---
name: setup-multiagent
description: Use when a repo (new or existing) needs guardrails for safe concurrent multi-session Claude work — the user starts a new project, says "set this repo up for multi-agent work", or wants parallel sessions on a repo that has none of the conventions yet.
---

# Setup multi-agent — make a repo safe for parallel sessions

Goal: a repo where several Claude sessions can work different workstreams without
losing each other's work, without racing at the merge point, and without the user
holding the coordination in their head. Pair with `coordinate` (the runtime half);
this skill is the one-time setup half.

Do every step yourself; ask only where a decision is genuinely the user's (repo
visibility, the stack, anything outward-facing).

## Step 0 — Read the ground truth

- `git rev-parse --show-toplevel` (is it a repo yet?), `git remote -v`, `gh repo view`
  (or the host's equivalent).
- Existing CI config (`.github/workflows/`, `.gitlab-ci.yml`, …), merge-automation
  config, `CLAUDE.md`, test runner, lockfiles.
- **Never overwrite an existing CI or merge-automation config** — read it, then extend it.
- Note the constraints of this host: company GitHub Enterprise, GitLab, and personal
  GitHub Free all offer different merge machinery (Step 3 branches on this).

## Step 1 — Repo exists, on the remote, private by default

`git init` + initial commit if needed; `gh repo create <name> --private --source=. --remote=origin --push`
(or the host's equivalent). Private is the default; confirm before creating anything
public. Set `--gitignore`/`--license` only if asked.

## Step 2 — CI, because "green" needs a referee

Without CI nothing gates a merge and the whole discipline is decorative. Detect the
stack from lockfiles/manifests (never guess): pytest / vitest / jest / go test / cargo test.
If the stack isn't established yet, say so and set CI up the moment it is — do not
invent a passing no-op job that fakes a green signal.

Every workflow gets a concurrency group. This is the cheapest fix for the CI-cost
blowup that N parallel sessions cause (GitHub Actions syntax shown; other CI systems
have equivalents):

```yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

`cancel-in-progress` must be **false for deploy jobs** — deploys queue, never cancel,
or concurrent merges race each other to production.

## Step 3 — The merge point, in order of preference

The failure this step exists to catch: two PRs that are each green in isolation but
break in combination — the top measured multi-agent failure, invisible to per-PR CI.
The fix is anything that re-validates a PR against the *actual* current main before
it lands. Pick the first tier available on this host; don't assume — check.

1. **Native merge queue** (GitHub org repos with branch protection — standard on
   Enterprise Cloud and available on public/org repos): enable it in branch
   protection, require the CI check. Best option where it exists; no third party.
2. **Branch protection + required checks + auto-merge** (GitHub Pro/Team/Enterprise,
   or free public repos; GitLab equivalents exist): require branches to be up to
   date before merging. Weaker than a queue (PRs need manual update clicks) but
   catches the stale-base class.
3. **Mergify free tier** (personal private repos on GitHub Free, ≤5 contributors) —
   a real queue where GitHub sells none. **Skip on company remotes**: third-party
   apps with write access usually violate policy; don't propose it there.
4. **Coordinator-serialized merges** — the zero-dependency fallback that works
   everywhere: the `coordinate` session merges one PR at a time, waits for main CI,
   and has every open branch re-verify against the new head before the next merge.
   Slower, but catches the same failure class with no installs and no permissions.

Whatever the tier, keep merging an explicit act (a label, a command to the
coordinator) — never merge-on-green by default.

## Step 4 — Project CLAUDE.md

Append a "Multi-session work" section stating: one worktree per session (never develop
in the main checkout while peers are active); this repo's **overlap zones** (auth,
migrations, config, API contracts, pinned prompts, routing/registry files) which force
human review; any **shared counters** (numbered migrations, codegen indexes) and the
rule that a session announces its claimed number to peers; and the CI cancellation
behavior. Keep the repo-specific facts here — the universal rules live in
`multiagent-conventions`.

## Step 5 — Guard the shared counters in CI

If the repo has a numbered sequence (migrations especially), add a test that fails on
duplicate numbers. Concurrent branches each take "the next" number, both PRs stay green
in isolation, and the collision only appears on main. Grandfather any already-shipped
duplicate in a frozen allowlist — never renumber a migration that has run in prod.

## Step 6 — Prove it, then hand it over

Open one throwaway PR (or use the setup PR itself) and confirm: CI runs, the merge
gate from Step 3 actually engages, and the merge path works end to end. A setup you
asserted but never exercised is not a setup.

Report back in this shape:
- what's live now (CI, merge gate, conventions)
- what's still on the user (any app installs or admin toggles, stack decision)
- the one-line workflow they now use, plus `coordinate` when several sessions run.
