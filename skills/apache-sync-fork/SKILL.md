---
name: apache-sync-fork
description: >-
  Sync a GitHub fork's branches with its upstream repository. Use whenever the
  user asks to sync their fork, backfill or push missing branches to the fork,
  update the fork's master, align fork branches with upstream, or mentions the
  fork is behind upstream — even if they don't say "sync" explicitly. Accepts
  optional branch filter args (exact names, globs, or natural language) to
  limit the scope. Diagnoses differences read-only, classifies branches, then
  pushes the default branch (ff-only) and release branches to the fork, and
  proposes deleting stale fork branches — every push/delete only after
  explicit user approval. Never pushes to upstream.
---

# Sync GitHub fork with upstream

## Invocation (optional branch filter args)

- `/apache-sync-fork` — default scope: default branch (ff-only) + all missing
  `branch-*` release branches.
- `/apache-sync-fork <branch>` or `/apache-sync-fork <glob>` (e.g. `branch-1.1*`) or
  natural language ("only 1.10 and 1.11") — sync ONLY the matching branches.
- Explicit args OVERRIDE the default sync-set classification (a branch the
  user names syncs even if it matches the exclude patterns), but the hard
  guardrails below never relax. Apply the filter AFTER the read-only
  diagnosis: always show the full four-category list first, then execute the
  filtered scope.

## Configuration (defaults; override per invocation on request)

- UPSTREAM remote: `upstream` (the project source, e.g. apache/kyuubi) —
  detect the source remote by URL (`github.com/apache/<project>` style),
  never by name alone; it may also be named `apache`.
- FORK remote: `origin` (the user's fork)
- Sync set: default branch (from `refs/remotes/<upstream>/HEAD`; if unset,
  resolve via the remote's HEAD or protected branches — if still ambiguous,
  ASK the user; never assume `master`) + this repository's RELEASE branches,
  auto-detected by pattern: `branch-*` OR `*-[Rr]elease` OR `<N>.x`. When
  several patterns match or none does, list what was found and ask which set
  to sync. NEVER mirror all upstream branches blindly — upstream repos carry
  bot/AI/CI housekeeping branches that do not belong in the fork.
- Exclude patterns (skip and report only): `dependabot/*`, `renovate/*`,
  `infrastructure-ruleset-bot/*`, `agent/*`, `codex/*`, `stabilize-*`,
  `revert-*`, `gh-readonly-queue/*`, and similar housekeeping branches.
  Anything on the fork that is NOT in the sync set is FORK-ONLY by
  definition — report only, never touch.

## Workflow

1. **Pre-flight (read-only)**
   - `git remote -v`: require one source remote (UPSTREAM) and one fork remote
     (FORK); abort with an explanation if missing or identical.
   - `git fetch <upstream> --prune` (updates local tracking refs only —
     allowed without approval).
2. **Diagnose (read-only)** — classify every branch on both sides:
   - MISSING: on upstream, not on fork → backfill candidate if it matches the
     sync set
   - FORK-ONLY: on fork, not on upstream → report only, never touch
   - DIVERGED: on both, different tips → report only, never auto-merge/reset
   - STALE: on fork, matches exclude patterns, not on upstream → deletion
     candidate
3. **Plan + approval gate**
   - Present the full plan: branches to push (with commit ranges), ff-only
     updates, proposed deletions. If the repo keeps a plan doc
     (e.g. `docs/plan/`), record the plan there first.
   - WAIT for explicit user approval. Approval may be granular (per branch /
     per action). Execute only the approved scope.
4. **Execute (approved scope only)**
   - Backfill / update: `git push <fork> refs/remotes/<upstream>/<branch>:refs/heads/<branch>`
   - Default branch: same command; a non-ff push is rejected by git — do NOT
     use `--force`; report the divergence instead.
   - Delete stale: `git push <fork> --delete <branch>`
5. **Verify + report**
   - `git ls-remote <fork> refs/heads/<branch>` for each touched branch;
     report any mismatch honestly.

## Hard guardrails

- NEVER push to the UPSTREAM remote. Push/delete only ever target the FORK.
  Rationale: upstream is the shared project repository (e.g. apache/kyuubi)
  where all changes must go through pull requests.
- NEVER use `--force` or `+refs/...`; never rewrite fork history silently.
  A diverged fork master means someone committed to the fork directly —
  surface it, let the user decide.
- NEVER delete or modify FORK-ONLY branches — they are the user's own work
  branches.
- No push/delete without explicit approval in the current conversation.
