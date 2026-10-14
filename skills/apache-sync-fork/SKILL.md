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

# Sync a GitHub fork with upstream

Diagnose fork-versus-upstream differences read-only, classify every branch, then fast-forward
push the default branch and release branches to the fork and propose deleting stale fork
branches — every push and delete only after explicit user approval. Never push to upstream.

## Configuration (defaults; override per invocation on request)

- `/apache-sync-fork` — default scope: default branch (ff-only) + all missing `branch-*` release branches.
- `/apache-sync-fork <branch>` or `/apache-sync-fork <glob>` (e.g. `branch-1.1*`) or natural
  language ("only 1.10 and 1.11") — sync ONLY the matching branches.
- Explicit args OVERRIDE the default sync-set classification (a branch the user names syncs
  even if it matches the exclude patterns), but the hard guardrails never relax. Apply the
  filter AFTER the read-only diagnosis: always show the full four-category list first, then
  execute the filtered scope.
- UPSTREAM remote: `upstream` (the project source, e.g. apache/kyuubi) — detect the source
  remote by URL (`github.com/apache/<project>` style), never by name alone; it may also be
  named `apache`.
- FORK remote: `origin` (the user's fork).
- Sync set: default branch + this repository's RELEASE branches, auto-detected by pattern:
  `branch-*` OR `*-[Rr]elease` OR `<N>.x`. When several patterns match or none does, list
  what was found and ask which set to sync. Default branch comes from
  `refs/remotes/<upstream>/HEAD`; if unset, resolve via the remote's HEAD or protected
  branches — if still ambiguous, ASK the user; never assume `master`. NEVER mirror all
  upstream branches blindly — upstream repos carry bot/AI/CI housekeeping branches that do
  not belong in the fork.
- Exclude patterns (skip and report only): `dependabot/*`, `renovate/*`,
  `infrastructure-ruleset-bot/*`, `agent/*`, `codex/*`, `stabilize-*`, `revert-*`,
  `gh-readonly-queue/*`, plus similar repo-specific junk branches. Anything on the fork
  that is NOT in the sync set is FORK-ONLY by definition — report only, never touch.

## Workflow

1. **Pre-flight (read-only).** Validate remotes and refresh tracking refs:

   ```bash
   git remote -v
   git fetch <upstream> --prune
   ```

   Require one source remote (UPSTREAM) and one fork remote (FORK); abort with an
   explanation if either is missing or if they are identical. The fetch updates local
   tracking refs only — allowed without approval.

2. **Diagnose (read-only).** Classify every branch on both sides four ways:
   - NEEDS-UPDATE — upstream ahead of the fork, or the branch missing from the fork, and
     the update fast-forwards → backfill/ff-only push candidate if it matches the sync set.
   - ALREADY-SYNCED — same tip on both sides → nothing to do.
   - FORK-ONLY — on the fork, not on upstream → report only, never touch.
   - EXCLUDED — matches an exclude pattern → skip and report only; one that sits stale on
     the fork (absent upstream) is a deletion candidate.

   A branch on both sides with different tips is DIVERGED, not needs-update: report only,
   never auto-merge or reset it.

3. **Plan + approval gate.** Present the full plan: branches to push (with commit ranges),
   ff-only updates, and proposed deletions of stale fork branches. If the repo keeps a plan
   doc (e.g. `docs/plan/`), record the plan there first. WAIT for an explicit approval
   card — every push and every delete sits behind one; approval may be granular (per
   branch / per action). Execute only the approved scope.

4. **Execute (approved scope only).** Push fast-forwards to the FORK only:

   ```bash
   git push <fork> refs/remotes/<upstream>/<branch>:refs/heads/<branch>
   ```

   Use the same command for the default branch; a non-ff push is rejected by git — do NOT
   use `--force`; report the divergence instead. Delete approved stale branches the same
   gated way:

   ```bash
   git push <fork> --delete <branch>
   ```

5. **Verify + report.** Confirm each touched branch; report any mismatch honestly:

   ```bash
   git ls-remote <fork> refs/heads/<branch>
   ```

## Guardrails

Hard limits — verify every item before any write; if a check fails, stop and report.

- [ ] NEVER push to the UPSTREAM remote; push/delete only ever target the FORK. Upstream is
      the shared project repository (e.g. apache/kyuubi) where all changes must go through
      pull requests.
- [ ] NEVER force-push (`--force`, `+refs/...`) and never rewrite fork history silently;
      divergence on a tracked branch = stop and report, never overwrite. A diverged fork
      master means someone committed to the fork directly — surface it, let the user decide.
- [ ] NEVER delete or modify FORK-ONLY branches — they are the user's own work branches.
- [ ] No push or delete without explicit approval in the current conversation.
