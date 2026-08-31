# Portable Claude Skills

Portable, sanitized versions of a personal Claude Code skill suite: multi-agent /
multi-session repo management, plus a teaching-oriented explanation style. No
secrets, no personal data, no references to private infrastructure — safe to use
on a work machine.

## What's inside

| Skill | Use it when |
|---|---|
| [`coordinate`](skills/coordinate/SKILL.md) | Several Claude Code sessions work one repo and you want one session to hold the board — sessions, branches, PRs, CI, merge order — and babysit what's in flight. Run once or on a loop (`/loop 10m /coordinate`). |
| [`setup-multiagent`](skills/setup-multiagent/SKILL.md) | One-time bootstrap of a repo for safe parallel sessions: CI with concurrency groups, a merge gate matched to what your git host actually offers, worktree conventions, counter guards. |
| [`multiagent-conventions`](skills/multiagent-conventions/SKILL.md) | The universal rules every session follows: trunk-based git, worktree-per-session, overlap zones, shared-counter claims, re-verify after merge, concurrency cap. |
| [`teach-me`](skills/teach-me/SKILL.md) | Explaining complex topics so the user learns them, not just approves them — short-sentence style (loosely ASD-STE100) plus the four practices that actually teach. |

`coordinate` and `setup-multiagent` are the runtime and setup halves of the same
system; `multiagent-conventions` is the doctrine both assume.

## Install

Copy the skills into your user-level Claude Code skills directory:

```bash
git clone https://github.com/ShubhamMChandra/portable-claude-skills.git
cp -r portable-claude-skills/skills/* ~/.claude/skills/
```

Or into a single project instead: `cp -r skills/* <repo>/.claude/skills/`.

Claude Code picks them up on the next session. Invoke by name (`/coordinate`) or
let Claude auto-select them from the descriptions.

## Notes for corporate environments

- Nothing here installs apps, hooks, or third-party integrations by itself; the
  skills are instructions only.
- `setup-multiagent` prefers your host's native merge machinery (GitHub merge
  queue, branch protection). Mergify appears only as an option for personal
  private repos on GitHub Free and is explicitly skipped for company remotes.
- `coordinate`'s reference file cites only public sources (docs, papers, blog
  posts); see [skills/coordinate/references/research-2026-08.md](skills/coordinate/references/research-2026-08.md).

## License

MIT — see [LICENSE](LICENSE).
