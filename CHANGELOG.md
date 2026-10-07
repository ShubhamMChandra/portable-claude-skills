# Changelog

## 2026-10

- Adds `install.sh`: one command installs this repo's skills and agents into
  `~/.claude`, plus pinned third-party skills from `mattpocock/skills` and the
  `alirezarezvani/claude-skills` library and slash commands. Works as a cloud
  environment setup script, so every cloud session gets the same toolkit.
- Consolidates skills and agents that lived in single project repos:
  - Skills: `prompt-optimizer`, `prompt-architect`, `prompt-improver`.
  - Agents: `visionary`, `visionary-architect`, `design-excellence-auditor`,
    `design-quality`, `mobile-responsive-fixer`, `ux-designer`, `architect`,
    `developer`, `quick-flow-dev`, `code-reviewer`, `qa-engineer`,
    `playwright`, `performance`, `security`, `devops`, `incident-response`,
    `data-engineer`, `email-builder`, `product-manager`, `analyst`,
    `scrum-master`, `tech-writer`, `bmad-master`, `c-level-advisor`, `growth`,
    `marketing`, `compliance`, `prompt-engineer`.
- Upgrades agents for portability and current upstream skills:
  - Skill references use names, not `~/.claude/skills/...` paths, and follow
    upstream renames (`grill-me` → `grilling`, `design-an-interface` →
    `codebase-design`, `ubiquitous-language` → `domain-modeling`,
    `triage-issue` → `diagnosing-bugs`, `write-a-prd` → `/to-spec`,
    `prd-to-plan`/`prd-to-issues` → `/to-tickets`, `request-refactor-plan` →
    `/improve-codebase-architecture`, `write-a-skill` → `writing-for-agents`).
    Retired skills (`edit-article`, `scaffold-exercises`) are dropped.
  - User-invoked skills are marked so agents recommend the command instead of
    trying to call it.
  - `~/.claude-skills` library paths follow its `<team>/skills/<name>` layout;
    every path an agent or command cites is checked to exist.
  - `visionary-architect` drops its project-specific context and stale memory
    path; long example blocks are moved out of agent descriptions.
- Upgrades `prompt-architect` to upstream v3.5.1 (31 frameworks, adds
  chain-of-verification, self-consistency, iterative compression).

## 2026-09

- Adds the `instructor` agent: a framework-first, Socratic tutor persona that
  teaches by context -> concept -> connection -> application, calibrates to the
  learner's level, and pressure-tests understanding. Its resources section is
  made portable (no paths outside this repo).

## 2026-08

- Ships four portable skills: `coordinate`, `setup-multiagent`,
  `multiagent-conventions`, and `teach-me`.
- `coordinate` adds a cockpit mode: when the user delegates a whole build, the
  coordinator session also spawns and drives worker sessions, keeping its own
  context reserved for orchestration.
- `setup-multiagent` ships copyable templates taken from a real scaffolded repo:
  CI workflow, merge-queue config, PR template, and a multi-session
  instructions section.
- `multiagent-conventions` documents the shared doctrine: trunk-based git,
  worktree-per-session, overlap zones, shared-counter claims, re-verify after
  merge, and a concurrency cap.
- `coordinate` includes a references file citing only public sources (docs,
  papers, blog posts).
