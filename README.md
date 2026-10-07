# Portable Claude Skills

One place for the Claude Code skills, agents and slash commands I want in every
project — on my laptop and in cloud sessions. `install.sh` puts all of it into
the user-level Claude Code directories, plus the pinned third-party skills the
agents rely on. No secrets, no personal data, no references to private
infrastructure — safe to use on a work machine.

## Install

### Cloud sessions (claude.ai/code, Claude app)

Cloud sessions start on a fresh machine, so nothing from your laptop's `~/.claude`
is there. Add this to your cloud environment's **Setup script** (environment
menu in the session title bar → Edit → Setup script) and every new session in
that environment gets everything below, whatever repo it opens:

```bash
git clone --depth 1 https://github.com/ShubhamMChandra/portable-claude-skills /tmp/pcs && bash /tmp/pcs/install.sh
```

It takes about five seconds.

### Your own machine

```bash
git clone https://github.com/ShubhamMChandra/portable-claude-skills.git
bash portable-claude-skills/install.sh
```

Re-run it after pulling to pick up changes. Set `PCS_SKIP_LIBRARY=1` to skip
the large reference library and its slash commands.

### What `install.sh` writes

| Where | What |
|---|---|
| `~/.claude/skills/` | This repo's skills, plus 14 skills from [mattpocock/skills](https://github.com/mattpocock/skills) |
| `~/.claude/agents/` | This repo's agents |
| `~/.claude/commands/` | 21 slash commands from [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) |
| `~/.claude-skills/` | The alirezarezvani/claude-skills reference library (~300 skills, read on demand, not auto-loaded) |

It only replaces the entries it installs; everything else under `~/.claude` is
left alone. An existing `~/.claude-skills` that this script didn't create is
moved aside to `~/.claude-skills.bak-<timestamp>` rather than deleted.

## What's inside

### Skills

| Skill | Use it when |
|---|---|
| [`coordinate`](skills/coordinate/SKILL.md) | Several Claude Code sessions work one repo and you want one session to hold the board — sessions, branches, PRs, CI, merge order — and babysit what's in flight. Run once or on a loop (`/loop 10m /coordinate`). Includes [cockpit operations](skills/coordinate/references/cockpit-operations.md) for fully delegated multi-session builds. |
| [`setup-multiagent`](skills/setup-multiagent/SKILL.md) | One-time bootstrap of a repo for safe parallel sessions: CI with concurrency groups, a merge gate matched to your git host, worktree conventions, counter guards. Ships copyable [templates](skills/setup-multiagent/templates/). |
| [`multiagent-conventions`](skills/multiagent-conventions/SKILL.md) | The universal rules every session follows: trunk-based git, worktree-per-session, overlap zones, shared-counter claims, re-verify after merge, concurrency cap. |
| [`teach-me`](skills/teach-me/SKILL.md) | Explaining complex topics so the user learns them, not just approves them — short-sentence style (loosely ASD-STE100) plus the four practices that actually teach. |
| [`prompt-optimizer`](skills/prompt-optimizer/SKILL.md) | Improving prompts that live in code: agent, system and developer prompts and reusable templates; eval-first and model-family-aware. |
| [`prompt-architect`](skills/prompt-architect/SKILL.md) | Structuring a prompt with one of 31 named frameworks (CO-STAR, RISEN, chain-of-verification, …) chosen by intent. |
| [`prompt-improver`](skills/prompt-improver/SKILL.md) | A quick first-principles rewrite of a vague prompt. |

### Agents

Generalist specialists you can hand work to from any repo. Each reads the
project's CLAUDE.md/README first and adapts to its stack.

| Area | Agents |
|---|---|
| Vision & design | `visionary` (Jony Ive / Rick Rubin-style clarity on what a product should feel like), `visionary-architect` (breakthrough, first-principles reimagining), `design-excellence-auditor`, `design-quality`, `ux-designer`, `mobile-responsive-fixer` |
| Engineering | `architect`, `developer`, `quick-flow-dev`, `code-reviewer`, `qa-engineer`, `playwright`, `performance`, `security`, `devops`, `incident-response`, `data-engineer`, `email-builder` |
| Product & delivery | `product-manager`, `analyst`, `scrum-master`, `tech-writer`, `bmad-master` (routes work across the other agents) |
| Business | `c-level-advisor`, `growth`, `marketing`, `compliance` |
| Learning & prompts | `instructor` (framework-first, Socratic tutor; pairs with `teach-me`), `prompt-engineer` |

### Third-party skills and commands

Installed from pinned commits, so an upstream change never reaches your
sessions until you bump the SHA in `install.sh` on purpose.

| Source | Pinned | What's installed |
|---|---|---|
| [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) | `6fd9479` | `grilling`, `grill-me`, `codebase-design`, `domain-modeling`, `diagnosing-bugs`, `tdd`, `writing-for-agents`, `setup-pre-commit`, `migrate-to-shoehorn`, and the user-invoked `/triage`, `/to-spec`, `/to-tickets`, `/improve-codebase-architecture`, `/setup-matt-pocock-skills` |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) (MIT) | `19392f7` | The reference library in `~/.claude-skills/`, and the commands `/a11y-audit`, `/changelog`, `/code-to-prd`, `/competitive-matrix`, `/financial-health`, `/focused-fix`, `/google-workspace`, `/okr`, `/persona`, `/pipeline`, `/plugin-audit`, `/prd`, `/project-health`, `/retro`, `/rice`, `/saas-health`, `/seo-auditor`, `/sprint-health`, `/sprint-plan`, `/tech-debt`, `/user-story` |

The three prompt skills are vendored in this repo with their upstream licenses:
`prompt-optimizer` from [getsentry/skills](https://github.com/getsentry/skills)
(Apache-2.0, current as of `d18b7aa`), `prompt-architect` from
[ckelsoe/prompt-architect](https://github.com/ckelsoe/prompt-architect) (MIT,
v3.5.1 `6c7a2c7`), and `prompt-improver` from
[ndpvt-web/prompt-improver](https://github.com/ndpvt-web/prompt-improver) (MIT, `9ad11d7`).

Some Matt Pocock skills are user-invoked only (`/grill-me`, `/triage`,
`/to-spec`, `/to-tickets`, `/improve-codebase-architecture`): Claude can't start
them itself, so agents recommend the command to you instead. `/to-spec`,
`/to-tickets` and `/triage` expect a one-time `/setup-matt-pocock-skills` per repo.

## Notes for corporate environments

- `install.sh` copies files and clones the two pinned public repos above; it
  installs no apps, hooks or services.
- `setup-multiagent` prefers your host's native merge machinery (GitHub merge
  queue, branch protection). Mergify appears only as an option for personal
  private repos on GitHub Free and is explicitly skipped for company remotes.
- `coordinate`'s reference file cites only public sources (docs, papers, blog
  posts); see [skills/coordinate/references/research-2026-08.md](skills/coordinate/references/research-2026-08.md).

## License

MIT — see [LICENSE](LICENSE). Vendored and installed third-party skills keep
their own licenses.
