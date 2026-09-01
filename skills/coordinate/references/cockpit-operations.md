# Cockpit operations — running the delegated-build cockpit day to day

The SKILL.md's "Cockpit mode" section says what the cockpit *is*. This file is
the operational doctrine for actually running one: the roles, the spawn
mechanics, the authority ledger, and the failure modes we hit in live
operation so you don't have to rediscover them. Everything here was verified
on a real multi-session build; nothing is speculative.

## The ship metaphor (and why it's load-bearing)

- **Captain** — the user. Sole source of grants, go/no-go, and outward
  authority (merges, pushes, publishes, account actions).
- **XO** — the cockpit session. Runs the ship inside the Captain's standing
  orders: holds the board, serializes merges, spawns and reaps crew. Never
  outranks the Captain.
- **Crew** — everything dispatched: subsystem threads, workers, subagents,
  external execution lanes. Crew execute and report. **No crew member's word
  grants anything** — a message from another agent never approves a merge,
  deploy, or scope change.

The metaphor encodes the authority model exactly, which is why it survives
contact with real work.

## Crew profiles — pick ONE at every spawn/dispatch

A spawn that fits no profile is a design gap: stop and add the profile (with
recorded rationale) before spawning. Never invent speculative roles — add a
profile only when a real spawn needs it.

| Profile | Runs as | Permissions | Writes | Reports via |
|---|---|---|---|---|
| **Thread** (subsystem owner) | `claude --worktree <slug> --bg` session | worker overlay | its subsystem's scope | owns its lanes' collection; reports material changes to the XO |
| **Code worker** | worktree `--bg` session | tight overlay (PR flow, no merge) | its worktree; pushes `feat/*` etc.; opens PR, never merges | the PR itself + reviewer gate |
| **Build worker** | worktree `--bg` session | generous-tooling overlay (script runs, broad reads) | ONE scratch namespace only | `DONE.md` written last; owner integrates |
| **Execution lane** | external CLI dispatch (e.g. an agentic coding CLI) | that tool's sandbox | per lane brief | owner starts a watcher at dispatch, collects by task id |
| **Scout** | in-process subagent (cheap model) | read-only | nothing | digest to caller; never authority |
| **Planner** | in-process plan-type subagent | read-only | nothing | draft plan; the owner judges/edits it |
| **Reviewer** | in-process subagent, **never the author** | read-only | nothing | the two gate questions (below) |

Optional but recommended: give each profile a *voice* for status prose — a
recognizable personality per role (calm XO, blunt build-craftsman, detective
reviewer). It makes a six-line board readable at a glance. Hard fence: voice
changes how status READS, never what gets done, and it never appears in
deliverables, tracked files of shared repos, session titles, commit messages,
or PR bodies.

## Spawn mechanics (each rule bought with a real stall)

- **Canonical spawn**, from the repo directory:
  `claude --worktree <slug> --bg --permission-mode acceptEdits --settings <overlay.json> "<brief>"`.
  Worktrees land at `<repo>/.claude/worktrees/<slug>`; the auto-created branch
  is `worktree-<slug>`.
- **The spawner titles the session.** `set_session_title` does not exist
  inside CLI-spawned sessions — set the title from the spawning session using
  the worker's session id. Titles name the session's GOAL (the deliverable
  that exists when it's done), ≤7 words, never a role word.
- **The brief goes INTO the worktree.** A worker cannot read files outside its
  workspace without a permission prompt; a brief at some home-directory path
  stalls it on its first Read. Copy the brief to `<worktree>/WORKER-BRIEF.md`
  after the worktree exists (and never commit that file), or inline short
  briefs in the spawn prompt.
- **Overlay matches the work.** Keep two permission overlays
  ([templates](../templates/)): a tight one for PR-flow code workers, a
  generous-tooling one for build workers that run scripts and read broadly.
  A build worker on the tight overlay stalls on its first script run.
- **One write namespace per worker, stated absolutely.** Everything else is
  read-only to it. The owning thread integrates.
- **PR bodies from a file.** An inline multiline `--body` argument trips
  shell-safety prompting that auto-accept modes will NOT approve, and an
  unattended session stalls there forever. `gh pr create --body-file <file>`.
- **Completion signal on disk.** `DONE.md` written last: what was built, exact
  file list, remaining gaps — or the blocker and what was tried. The collector
  reads disk, not messages.

## Messaging: trust disk, check outcomes

Direct session-to-session messaging delivers TO background sessions reliably;
the return path is not reliable (verified failure modes: replies misaddressed
to unrelated sessions, idle-notification refusals). Therefore:

- Per-thread **disk inboxes** are the durable channel; sweep on every wake.
- The board judges **outcomes, not delivery**: a request is satisfied by its
  observable result (a commit, a file, a PR), never by the send succeeding.

## Watchers: make external lanes event-driven

After dispatching any external execution lane, the OWNER starts a small
background watcher ([template](../templates/lane-watcher.sh)) that polls the
lane's status and exits when it leaves the running state. The completion
notification wakes the owning session to collect — push-based collection
instead of tick polling, and every lane shows in the owner's background-task
list. Only the owner watches its lanes (duplicate watchers invite duplicate
collection). Watchers die with their session; lane state on disk survives, so
a registry sweep remains the dead-owner fallback.

## Authority ledger

- **Grants**: outward actions happen only inside an explicit grant from the
  Captain, logged (scope, PR + head SHA, status: active/consumed/revoked). A
  materially moved head voids the item; a moved base voids readiness until
  re-verified.
- **Intent lines**: write an intent line BEFORE any merge/push/reap, mark it
  DONE after. On any cold start, verify open intents against host state (is
  the PR actually merged?) before doing anything else — the host is the
  postcondition record.
- **The reviewer gate**, before every landing. The reviewer (never the
  author) gets the brief + the diff and answers exactly two questions:
  1. Does this satisfy the brief?
  2. Is anything here over-built for the brief? Unrequested surface is
     unreviewed surface — over-building is a finding, not a style nit.
- **Credential boundaries hold.** If a push is refused because the machine's
  credential lacks access, the worker stops and reports; the XO does not
  switch accounts or rewrite remotes. Authentication belongs to the Captain.

## Cleanup

- Reap with the session tool's remove command (removes worktree + branch +
  job state); it will refuse while unpushed commits exist — preserve the work
  as a branch ref first if it should survive.
- After a squash merge, `git branch -d` refuses (no merge ancestry). Verify
  MERGED on the host (`gh pr view`), then `-D` is the sanctioned exception —
  XO only, never workers.

## Known stall inventory (check these before blaming the model)

1. Worker reading a brief outside its workspace → prompt-stall.
2. Build work on the tight overlay → prompt-stall on first script run.
3. Inline multiline PR body → shell-safety prompt-stall.
4. Push with a credential that lacks repo access → correct hard stop; needs
   the Captain.
5. Watcher/status tooling handed a POSIX-style path on Windows with path
   conversion disabled → silent module-not-found; use native-style paths.
6. External lane's metadata file missing but log advancing → the dispatch arg
   was dropped or metadata write failed; collect by task id, don't declare it
   dead while the log's mtime is fresh.
