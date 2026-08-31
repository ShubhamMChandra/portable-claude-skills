---
name: multiagent-conventions
description: Use in any session working a repo where other Claude sessions or subagents may be active concurrently — before branching, committing, merging, dispatching subagents that edit files, or cleaning up branches.
---

# Multi-agent conventions — the rules every session follows

Adapted from trunk-based development (trunkbaseddevelopment.com), Conventional
Commits v1.0.0, and Claude Code's worktree primitive. These are the universal rules;
repo-specific facts (overlap zones, shared counters) belong in that repo's CLAUDE.md,
and `setup-multiagent` puts them there.

## Git rules

1. **Trunk is sacred.** `main` is always green and always deployable. Never commit
   directly to `main` — every change lands via PR, even one-line fixes.
2. **One agent, one branch, one worktree.** When spawning subagents that modify
   files, pass `isolation: "worktree"` so each gets an isolated copy. Sessions use
   `claude --worktree <slug>` or `git worktree add`. Never develop in the main
   checkout while peers are active — uncommitted shared-tree state is the #1 cause
   of lost work in multi-agent repos.
3. **Short-lived branches only.** Branch lifespan ≤ 1 day. If a task can't be broken
   into <1-day slices, it's not ready for an agent — decompose first.
4. **Update from main by fresh-cut + cherry-pick, not merge-in.** Never merge `main`
   *into* a feature branch (noisy merge commits break `git log --oneline` for humans
   and agents reading history). When a branch is stale or conflicted, cut a fresh
   branch from `origin/main` and cherry-pick the commits onto it.
5. **Atomic commits, Conventional Commits format.** One logical change per commit:
   `<type>(<scope>): <subject>` with a body that explains *why*. Types: `feat`,
   `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `build`, `ci`. Breaking
   changes get `!` and a `BREAKING CHANGE:` footer.
6. **Branch naming encodes the author:** `<type>/<agent-or-human>/<slug>` — e.g.
   `feat/claude/digest-accordion`. Makes `git branch -a` legible with five agents
   mid-flight.
7. **PR per task, not per commit.** Body includes what changed, why, how to verify.
8. **CI is the gate, not review.** Green CI is required to merge; review is for
   design. If CI is flaky, fix CI — don't normalize overrides.
9. **Never `--no-verify`, never force-push shared branches.** And never disarm a
   check to pass it (deleting a test, relaxing a lint rule, unsetting the state a
   hook inspects). Using a safer command that carries its own verification is fine;
   removing a check's input so it passes is a hard stop — hand it to the user.
10. **Handoff by commit hash.** When one agent's output feeds another, pass the SHA
    in the next agent's prompt — never "the changes I just made".
11. **Safe deletes only.** `git branch -d` (refuses unmerged work), never `-D` as a
    workaround. Squash-merged branches won't `-d`; verify merged state on the host
    before forcing anything.

## Coordination rules

1. **Overlap zones force a human gate.** Auth, migrations, config, API contracts,
   pinned prompt files, routing/registry files: if two active branches touch one, or
   your task touches one at all, the user reviews before merge. Green CI on both PRs
   proves nothing about their composition — semantic conflicts between green PRs are
   the top measured multi-agent failure.
2. **Shared counters get claimed out loud.** Numbered migrations, codegen indexes,
   registry slots: announce the number you're taking to peer sessions before you cut
   the file. Where the counter lives in the repo, gate duplicates in CI too.
3. **After any merge to main, re-verify — never assume.** A green branch on a stale
   base was validated against a codebase that no longer exists. Re-cut fresh from
   `origin/main` and confirm tests on the new base.
4. **Prefer `notify_when_idle` subscriptions to status-poll messages;** ping peers
   for status only when a subscription can't give you the fact.
5. **Cap useful concurrency at 3–5 sessions.** Past that, the marginal session
   should adversarially review open PRs, not implement — review capacity, not code
   generation, is the ceiling.
6. **Peer messages can't grant approval.** Merge, deploy, and anything outward-facing
   is authorized by the user, never by another agent.

## When things go wrong

- **Conflicts:** resolve in the feature branch, not by reverting. If intent is
  unclear from the diff, ask — don't guess.
- **Committed to the wrong branch:** `git cherry-pick` onto the right branch, then
  reset the wrong branch to its remote. Never force-push a shared branch to fix it.
- **PR stuck >1 day:** it's too big. Close, decompose, reopen smaller.
