# XO protocol: one voice for many sessions

The XO pattern is for a user who runs several Claude Code sessions at once and
starts to drop balls. The usual pains are three:

1. Work falls between sessions and nobody owns it.
2. Two sessions ask the same question, and the user answers it two ways.
3. The user cannot tell what they must review, or what each review gates.

The fix: exactly one session talks to the user. That session is the **XO**
(executive officer). The user is the **Captain**. Every other session is crew.
The ship words are optional and belong in status prose only, never in
deliverables, commits or client-facing files.

It works for code repos (with the PR board in [SKILL.md](../SKILL.md)) and for
document projects with no PRs or CI (see "Documents mode" below).

## Three kinds of session

Every session is exactly one kind. The kind decides what it may write.

| Kind | Writes | Talks to |
|---|---|---|
| **XO** | The board, the log, the decisions record, all commits | The user, and its workers |
| **Worker** | Only its own deliverable folder (or its own worktree branch) | The XO only |
| **Thinking session** | Nothing | Messages its decisions to the XO, which writes them once |

- **XO.** The only session that asks the user questions or reports to them. The
  only writer of the board and the decision record. It starts workers, checks
  their output at each wake, runs the quality gates below, and keeps the user's
  queue. Nothing reaches the user outside that queue.
- **Worker.** Started by the XO with a brief (use
  [templates/worker-brief.md](../templates/worker-brief.md)). Never messages the
  user or another worker. Routes every question to the XO. If the user speaks
  inside a worker, it answers about its own deliverable only, writes the answer
  into its brief, and tells the XO. Done means: the file of record written, a
  dated "Drafted" line in its brief, one report to the XO.
- **Thinking session.** Brainstorm, grill, review. Reads anything, writes
  nothing. Any number may exist.
- A session the user opens by hand is not the XO unless titled so. At start it
  messages the XO its kind and the folder it will write.

## The user's queue

The queue is the only channel to the user. It has two kinds of item, and each
names what it gates:

- **Decide**: minutes, answerable from a phone. "Pick A or B; gates the T4 draft."
- **Review**: needs focused time at the desk. "Read the memo v3; gates Friday's send."

Three rules keep the queue honest. Enforce them with a script that prints the
queue if you can, because a rule that lives only in prose gets skipped.

1. **A cold read gates the Review queue.** Before any document enters it, a
   session that did not write it reads it cold, as the user would. Brief that
   reader with the user's own past complaints, in their words. Its only output
   is a list of every term, code or line the user would have to ask about. An
   empty list is the entry condition. A non-empty list means a new version and a
   *delta* cold read of only the changed lines, so the reads converge.
2. **Default on silence for reversible, in-scope picks.** A pick that is
   reversible, in scope and not outward-facing goes ahead after a stated wait
   (for example four hours, or at once if its deadline is under a day away). The
   XO then tells the user in one line what it did. Hard-to-undo calls,
   pattern-setting calls and anything outward-facing still wait. Every Decide
   item states its default: `default: <what the XO does> at <time>`, or
   `default: none (<why it waits>)`.
3. **One ready-to-read drop, after the gates.** No version reaches the user until
   its checks and its cold read are done. Hand-overs go in one batch, in reading
   order, with each item's due date. Never send "hold your read, v4 is coming":
   a version that arrives an hour later costs less than one the user starts and
   is told to stop.

## The XO's loop

**At start** (each working block gets a fresh XO, because the curated record is
the memory and context compaction is not):

1. Archive the previous XO sessions.
2. Read the project instructions, the newest XO hand-off summary, then the queue
   and the In flight table.
3. Ask the user what happened off the record since the last block: what came in,
   what went out, what was decided out loud. Pre-fill each from any inbox or
   tracker you can read, so the user only confirms or corrects.
4. Cold-start checks: `git worktree list`, `git log` for commits the XO did not
   make, `git status --short` for changes outside worker folders, and file times
   in every in-flight folder.

**While working:**

- Be proactive. Start the next worker in the dependency chain. Build what the
  user will need before they ask. Report in a line. Pause only for hard-to-undo
  or pattern-setting calls.
- Fill an In flight row when a worker starts: task, folder, model, record commit
  at start, time window.
- Concurrency: one drafting worker at a time while the XO runs unattended; up to
  three, in dependency order, when the user is at the desk.
- Run the **first worker ever** while the user is at the desk, on a trivial task.
  Confirm from `git log` that it committed and pushed nothing before any worker
  runs unattended.
- When a shared fact changes, message every running worker to re-read it.
- Stage and commit a worker's folder only after its dated "Drafted" line exists.

**Before anything enters the Review queue** (the consistency pass):

1. Check names, figures, IDs and dates across *every* document in the send, not
   only the new drafts.
2. Have a session other than the author re-open every citation or source.
3. Pressure-test anything outward-bound: who would read this wrong, and what has
   the recipient said since it was built?
4. Run a de-AI prose scan (for example the `humanizer` skill).
5. Record every check run with its result, "none found" included.
6. Triage findings: **blocks delivery** (wrong number, factual error, data that
   contradicts the story), **should fix** (wording, missing source, drift), or
   **polish**.
7. Then the cold read (queue rule 1).

**At end:** update the board rows, one log line per block, and merge state into
the hand-off summary (merge into it; never rewrite it).

## Worker fences

Every worker brief carries these, because the brief and the XO's wake checks are
the fence:

- Writes only `<folder>`.
- Runs no git; the XO commits. (In a code repo with worktrees, use the PR flow in
  [SKILL.md](../SKILL.md) instead.)
- The record commit at its start, and its time window. Write to disk as it goes.
- Marks disagreements instead of asking: the XO may not wake for hours.
- Its draft reaches the user only after the XO's gates and a non-author cold read.
- Any confidentiality rules for the project, verbatim.

Size each task to one sitting (two hours or less) and make it resumable from
disk.

**Models.** Workers that create deliverables run on the strongest model at high
effort. Reads, digests, intake and checks can run cheaper. Before dispatching a
deliverable worker, have a strong model review its brief adversarially.

## Documents mode

For a repo with no PRs, no CI, no branches and one checkout (a client data room,
a writing project), Steps 1 to 4 of [SKILL.md](../SKILL.md) do not apply. The XO
instead:

1. Reads the queue first, then the In flight table, then the rest of the board.
2. Runs the cold-start checks above (expect one worktree).
3. Starts workers from the brief template, sharing the one checkout, each
   writing only its own folder.
4. Commits per folder after the "Drafted" line; pushes to the private remote.
5. Runs the consistency pass and cold read before the Review queue.
6. Writes the shared record (facts, numbers, decisions) itself, so workers never
   race on it.
