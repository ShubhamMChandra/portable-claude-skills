# Multi-session agent orchestration — research sweep 2026-08-26

Method: Anthropic first-party docs, HN threads (Algolia API, comments read directly),
GitHub REST API for live repo health, one peer-reviewed dataset study. Compiled for the
/coordinate skill; load on demand, don't pre-read.

## Bottom line

1. **Anthropic shipped most of the coordinator layer first-party**: `claude agents`
   (agent view), agent teams, cross-session messaging, `/batch`, native `--worktree`.
2. **GitHub Free + personal private repo = no auto-merge, no branch protection, no
   rulesets, no merge queue** (queue needs org + Enterprise Cloud). Every "just use
   `gh pr merge --auto`" recommendation online is wrong for this constraint. Workarounds:
   Mergify free tier, or a client-side PR-driver loop.
3. **Review, not generation, is the bottleneck**; "parallel generation, serialized
   merge" is the only pattern with evidence behind it.

## First-party tooling verdicts

- **`claude agents` (agent view) — ADOPT.** One screen: every session grouped
  Needs-input / Working / Completed; per-row PR state (yellow=checks running,
  green=passing, purple=merged); `s:blocked` filter; `--json --all` for scripting;
  supervisor daemon survives terminal close. Background sessions auto-relocate to
  `.claude/worktrees/<id>/` before first edit and auto-commit/push/draft-PR on finish
  (never merge, never force-push). Research preview; 10 sessions ≈ 10× quota.
  https://code.claude.com/docs/en/agent-view
- **Native worktrees — ADOPT.** `claude --worktree <name>`; set
  `worktree.baseRef: "fresh"` (branches from origin/HEAD, refetched when stale — the
  frozen-base discipline for free); `.worktreeinclude` copies gitignored files (.env)
  into each worktree; `--worktree "#1234"` branches from a PR head; gitignore
  `.claude/worktrees/`. Isolation is enforced (four static checks), permission
  approvals shared across worktrees. https://code.claude.com/docs/en/worktrees
- **Cross-session messaging — ADOPT (in use).** Add `notify_when_idle: true`
  subscriptions (one-shot, free for the watched session, 12h expiry) instead of
  status-poll pings; set `crossSessionInbound: "accept"` on headless workers so held
  messages don't expire. Peer messages can't approve prompts or change config.
- **Agent teams — SKIP for cross-workstream coordination** (teammates are NOT
  worktree-isolated; one team per session; can't span independent sessions; heavy
  token burn — practitioner report: Max limits exhausted <1h). ADAPT for one bounded
  job: multi-lens review of a single PR. Shift+Tab locks a lead to coordination-only.
- **`/batch` — ADAPT.** 5–30 worktree-isolated subagents, one PR each, plan gate
  first. Right for mechanical fan-out (codemods); wrong for independent features; cap
  it — 30 PRs with no merge queue is a merge-order nightmare.
- **Channels (research preview) — ADAPT later.** MCP server pushing external events
  (CI webhook, error tracker) into a running session. The correct end-state for PR
  babysitting: event-driven instead of /loop polling. Requires Bun; experimental.

## Merge automation on GitHub Free + private (verified against GitHub docs)

| Feature | Free public | Free PRIVATE | Needs |
|---|---|---|---|
| Auto-merge | ✅ | ❌ | Pro+ |
| Branch protection / rulesets | ✅ | ❌ | Pro+ |
| Merge queue | ✅ (org repos) | ❌ | org + GHEC |

- **Mergify free tier — TOP RECOMMENDATION.** Free for private repos ≤5 active
  contributors, includes full Merge Queue + Merge Protections + CI Insights + Stacks.
  The only real merge queue at this tier; also substitutes for the branch protection
  GitHub won't sell. Cost: third-party app with write access; `.mergify.yml` per repo
  (templatable ~20 lines). https://mergify.com/pricing
- **Self-hosted PR driver — ADOPT as the coordinator's job.** /loop + gh: detect PR
  state → triage failures (`gh run view --log-failed`) → refresh stale branches →
  propose merge order. Converged safety rules (OpenAI ships a babysit-pr skill in
  codex itself): never force-push; rejected push = stop and ask; "ready to merge is a
  notification, not an action."
- **Actions-workflow-merges-via-API — weak fallback.** No rebase-and-retest, so it
  doesn't touch the semantic-conflict class.

## Failure modes, ranked by evidence

1. **Semantic conflicts between individually-green PRs** — nothing detects them;
   the composition silently drops behavior. Mitigation: overlap-zone review gates.
2. **arXiv 2607.04697** (33,596 agent PRs, 2,807 repos): 79.4% of agent PRs co-active;
   textual conflict rate 19.8% same-agent-family / 41.7% cross-family; ~42% of
   conflicts structural (the class agents resolve worst).
3. **Stale-base drift** — green PR validated against a base that no longer exists.
   Mitigations: `baseRef: "fresh"` at the start, merge queue (or re-verify) at the end.
4. **Shared-counter collisions** (migrations, codegen, registries) — single-owner
   convention or explicit number claiming; CI uniqueness gates where the counter lives.
5. **Lost work from shared trees** — worktree-per-session, now product-enforced.
6. **CI cost blowup** — concurrency groups: `cancel-in-progress: true` for PR runs,
   **false for deploys** (queue, don't skip — also the deploy-race mitigation).
7. **Token blowup** — multi-agent ≈ 15× chat tokens (Anthropic's own research system).
8. **Review capacity is the ceiling** — Simon Willison: "I can only focus on reviewing
   and landing one significant change at a time." The marginal agent should review,
   not implement. Cap 3–5 parallel sessions (Anthropic docs + Boris Cherny converge).

## Patterns worth stealing

- **Architect/Implementer split** (Jesse Vincent): one session designs+reviews, one
  implements; architect /clears between reviews. When feeding external review comments
  to an agent, frame them evaluatively ("which of these should actually be fixed?") so
  it judges instead of complying.
- **Writer/Reviewer with fresh context** (Anthropic best practices): the reviewer that
  didn't write the code reviews better.
- **Overlap-zone registry**: explicit list of high-blast-radius files (auth, migrations,
  config, API contracts, pinned prompts) where any touch forces human review.
- **ccpm conventions** (automazeio/ccpm, 8.3k★ MIT): GitHub Issues as task queue with
  `depends_on`/`parallel`/`conflicts_with` metadata; deterministic ops as bash scripts,
  not LLM calls. Steal the conventions, skip the dependency.
- **Atomic git-ref CAS as claim lock** (tasksmd/tasks.md spec — 7★, idea > project).

## OSS repo health (GitHub API, 2026-08-26) — key verdicts

- **Backlog.md** (MrLesk, 6.5k★, MIT, pushed same-day, low issue ratio) — healthiest
  candidate for a shared markdown task board; evaluate first.
- **claude-squad** (8.4k★, AGPL) — active but largely superseded by `claude agents`.
- **ccpm** (8.3k★, MIT) — conventions donor; 5 months stale but prompt-based, low rot.
- **Piebald-AI/claude-code-system-prompts** (12.5k★) — read Anthropic's own /batch
  orchestrator prompt before writing a coordinator.
- **SKIP:** vibe-kanban (27.9k★ but sponsor dead + 533 issues), 1Code (archived),
  Crystal (deprecated→paid), uzi (14mo dead), agent_farm (stale). Category verdict:
  demoware-saturated, high mortality — prefer first-party + conventions over wrappers.
- **container-use** (Dagger, 4k★) — only if isolation stronger than worktrees is ever
  needed (worktrees share the main `.git`; a malicious process could plant a hook).

## Deliberate non-adoptions

- No third-party orchestration wrapper (mortality rate; Anthropic shipping into the
  category directly).
- No stacked PRs across independent workstreams — stacking is for dependent parts of
  ONE task; bundling parallel output adds rebase cascades with no review benefit.
  (git-town, 3.4k★ MIT, is the free stack mechanics if ever needed within one task.)

Key sources: code.claude.com docs (worktrees, agent-view, agent-teams, cross-session-
messaging, channels, best-practices) · docs.github.com (auto-merge, protected branches)
· mergify.com/pricing · arxiv.org/abs/2607.04697 · simonwillison.net 2025-10-05 ·
blog.fsck.com 2025-10-05 · HN 47218318, 45489884, 46990733 · getautonoma.com blog ·
github.com/automazeio/ccpm · github.com/tasksmd/tasks.md
