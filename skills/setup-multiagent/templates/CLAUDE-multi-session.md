<!-- Template: append these sections to the project's CLAUDE.md (Step 4 of
     setup-multiagent). Fill the placeholders; delete what doesn't apply. -->

## Multi-session work

Several Claude sessions may work this repo at once, on different workstreams:

- **One worktree per session.** Never develop in the main checkout while peers are
  active — uncommitted shared-tree state is the top documented cause of lost work.
  Prefer `claude --worktree <slug>`; otherwise
  `git worktree add ../<repo>-worktrees/<slug> -b <type>/claude/<slug> origin/main`.
- **Merging goes through the gate.** <!-- Pick the line matching your Step-3 tier: -->
  Add the `queue` label to a green PR; the merge queue re-tests it against current
  `main` before landing. <!-- OR --> The coordinator session merges PRs one at a
  time, waiting for main CI between merges. Direct merges bypass the stale-base
  re-test and should be the exception.
- **After main moves, re-verify — don't assume.** A branch validated against an older
  main was tested against a codebase that no longer exists. Re-cut from
  `origin/main` and cherry-pick.
- **Overlap zones** — <!-- list them; start with: --> auth, config, API contracts,
  routing/registry files, and any numbered sequence (migrations, codegen indexes)
  force human review before merge, and a session claims a counter number out loud
  to peers before cutting the file.

Run `coordinate` in one session when several are active — it holds the board so the
user doesn't have to.

## As this repo grows

Add these when the codebase earns them, not before:

- **`docs/AGENT_INDEX.md`** — a map from "what I need to change" to "which file",
  written for someone with no context. It is the single highest-leverage doc for
  agent work; a session that has to grep for orientation wastes half its context.
- **Overlap zones**, filled into the section above, the moment a file exists that two
  workstreams would both want to edit.
- **A shared-counter gate in CI** if a numbered sequence appears (migrations most
  commonly): concurrent branches each take "the next" number, both PRs stay green in
  isolation, and the collision only lands on main.
