# Changelog

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
