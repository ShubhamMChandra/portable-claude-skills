# XO setup guide

How to set up the [XO protocol](references/xo-protocol.md) on a project: one
session (the XO) is your only voice, and every other session reports to it.
Part 1 is for you. Parts 2 and 3 are text you paste in for the agents.

Use it when you run three or more sessions on one project and you start
answering the same question twice, or losing track of what needs your review.
For one or two sessions, the plain `/coordinate` board is enough.

## Part 1 — Steps for you

1. **Install the skills.** Run `bash install.sh` from this repo (see the
   [README](../../README.md)). That puts `coordinate` in `~/.claude/skills/`.
2. **Add the block in Part 2 to your project's `CLAUDE.md`.** Every session
   reads `CLAUDE.md` at start, so this is how workers learn the fences. Fill
   the brackets.
3. **Create the record files** the block names: a board (`tracker.md`), a
   decisions log (`decisions.md`), and a hand-off folder (`notes/handoff/`).
   Empty files are fine; the XO fills them.
4. **Start one session and paste the prompt in Part 3.** Title it
   `[Project] XO <date>`. From now on, type only into this session.
5. **Run the first worker with you watching.** Ask the XO for a trivial task.
   Check `git log` afterwards: the worker should have committed nothing. Only
   then let workers run while you are away.
6. **Each new working block** (a day, or a trip): start a fresh XO with the same
   prompt. It archives the old one and resumes from the hand-off summary.

**What you should see.** The XO gives you one queue. *Decide* items take minutes
and can be answered from your phone. *Review* items need desk time. Each one says
what it unblocks and what the XO will do if you stay silent. Nothing else should
ask you anything. If a worker messages you directly, the fences are leaking:
tell the XO.

## Part 2 — Block for the project's `CLAUDE.md`

```markdown
## Sessions (XO protocol)

Every session is exactly one kind. Which one you are decides what you may write.

- **XO.** Title starts `[Project] XO`. The only session that asks the user
  questions or reports to them; the only writer of `tracker.md`,
  `decisions.md` and the log; the only session that commits. It keeps the
  user's queue (Decide and Review items, each naming what it gates) and nothing
  reaches the user outside it. It follows the `coordinate` skill, XO mode
  (`references/xo-protocol.md`).
- **Worker.** Started by the XO with a brief. Writes only its own folder
  [`<deliverables>/<task>/`, or its own worktree branch in a code repo]. Runs
  no git unless its brief says otherwise; the XO commits. Never messages the
  user or another worker; every question goes to the XO. Marks disagreements in
  its `brief.md` instead of asking. Done = file of record, a dated "Drafted"
  line in `brief.md`, one report to the XO.
- **Thinking session.** Brainstorm, grill, review. Reads anything, writes
  nothing, ends by messaging its decisions to the XO.
- A session the user opens by hand is not the XO unless titled so. At start it
  messages the XO its kind and the folder it will write.

**The user's queue.** (1) No document enters Review until a session that did
not write it reads it cold, as the user would, and finds nothing to ask about.
(2) A reversible, in-scope, not outward-facing pick goes ahead after
[4 hours] of silence; every Decide item states its default. (3) Hand-overs go
in one batch, in reading order, after the checks; never "hold your read".

**Read first:** this file, the newest `notes/handoff/*-xo-summary.md`, then
`tracker.md`.

[Project-specific fences: confidentiality, paths that are read-only, what must
never leave the machine.]
```

## Part 3 — Kickoff prompt for the XO

```text
You are the XO for this project. Load the coordinate skill and follow XO mode
(references/xo-protocol.md). Then:

1. Read CLAUDE.md, the newest notes/handoff/*-xo-summary.md (if any), and
   tracker.md.
2. Archive any older XO sessions.
3. Ask me, pre-filled from what you can read: what came in, what went out, and
   what I decided out loud since the last XO.
4. Show me the queue: Decide items first, then Review in reading order, each
   with what it gates and its default on silence.
5. Start the next worker in the dependency chain from
   templates/worker-brief.md. Report in one line.

Use the ship words (Captain, XO, crew) in status messages if you like, never in
deliverables or commits.
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Two sessions ask you the same thing | A worker is talking to you | Re-paste Part 2; tell the XO to re-brief it |
| A draft reaches you with jargon | The cold read was skipped or done by the author | Ask the XO for the cold-read line in that folder's `brief.md` |
| A worker committed or pushed | Brief missing "run no git" | Fix the brief template; check `git log` at each wake |
| The XO forgets yesterday | Old XO kept past its block | Start a fresh XO; make sure the hand-off summary was merged |
