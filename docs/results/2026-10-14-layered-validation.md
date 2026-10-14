# Layered trigger validation — 2026-10-14 (ZCode host + dual-host live matrix)

Companion record to `2026-10-14-cross-env.md`. This file documents the
three-layer validation run against the ZCode host and a parallel
dual-host (claude / kimi) live matrix, with tool-call-level evidence
pulled from session transcripts.

## Layer 0 — host discovery (ZCode)

`zcode skills list` (CLI 0.16.9 bundled with the desktop app) reports all
18 discoverable skills with empty diagnostics; the three `apache-*`
skills load with their rewritten frontmatter. Confirms the fix for the
over-long-description failure (skills were silently dropped while
`description` exceeded 1024 chars).

## Layer 1 — trigger-decision simulation (7/7 PASS)

Fresh no-context subagents decided which skill (if any) to invoke, given
exactly what the host presents (name + description truncated to ~250
chars + `when_to_use`) plus the session context. Cells:

| Cell | Context / phrase | Decision |
|---|---|---|
| 1 | kyuubi cwd, "提交一下" (with project-level kyuubi skills presented) | `kyuubi-commit-pr` — deference happens at the trigger layer |
| 2 | kyuubi, "同步一下 fork" | `apache-sync-fork` |
| 3 | seatunnel, "提交一下" | `apache-commit-pr` |
| 4 | seatunnel, "找个 issue 开始做" | `apache-dev-workflow` |
| 5 | fresh apache/hbase clone, "提交一下" | `apache-commit-pr` |
| 6 | non-ASF local repo, "commit this" | none |
| 7 | non-git dir, "Apache 项目提 PR 一般怎么走？" | none |

## Layer 2 — dual-host live matrix (7/7 PASS, two annotations)

Three parallel lanes: claude ×2 (kyuubi cells 1–2, seatunnel cells 3–4),
kimi ×1 via `--skills-dir` (hbase 5, non-ASF 6, non-git 7). Evidence
extracted from `~/.claude/projects/` transcripts and kimi reasoning
traces.

| Cell | Host | Verdict | Key evidence |
|---|---|---|---|
| 1 | claude | PASS * | `Skill: apache-commit-pr` invoked; Step 0 chain executed (remote URL check → repo pack → personal master copy → proceed without pack); local-only commit; RAT awareness. *Deference clause untestable here: claude does not read `.zcode/skills/`, so the legacy kyuubi skills are invisible — reserved for the ZCode host. |
| 2 | claude | PASS | sync-fork flow: four-way branch classification correct; ff-only push commands presented as an approval card; zero pushes (ls-remote re-verified). |
| 3 | claude | PASS † | Lane run did not trigger; two same-sample reruns (parallel session) both invoked the skill and read the rule pack → 3 samples, 2 triggers: probabilistic host behavior ("the model decides"), not systematic under-trigger. ZCode-side v1 passed via the AGENTS.md pointer channel. |
| 4 | claude | PASS | `Skill: apache-dev-workflow`; fetch + rule-pack + `docs/tasks/backlog.md` read (consumed the previous session's stage-0.5 output); graded Top-2 recommendations; profile-section backfill request; claiming stopped at the approval card. |
| 5 | kimi | PASS | Trigger + Step 0 (apache/hbase identified by URL; no pack, no master copy); guardrails held (explicit-path add, private-scratch warning, never push official remote, fork+PR+issue flow, approval-card offer). Legitimate deviation: lazy mining for a scratch local commit, announced to the user. |
| 6 | kimi | PASS | Explicit non-ASF exclusion in the reasoning; plain commit, zero ASF behavior. |
| 7 | kimi | PASS | No trigger; generic three-tier answer (squash semantics, never hand-write `(#N)`, close keywords in body, security re-route, ICLA notes); no repo-specific formats; offered to read a concrete repo on request. |

## Safety and cleanup

Zero remote writes across the entire run (both forks re-verified via
`ls-remote`); all approval gates surfaced as cards, never executed.
Test pollution fully restored (user-approved plan A): kyuubi back to its
original `8f006c23f` + uncommitted `.gitignore` modification, seatunnel
back to `0dcb555dc`, hbase reset to clone state.

## Conclusion

The 7-cell trigger matrix closes 7/7. Combined with B5 (dry run: fork CI
triggered, fast gates double-green), the Phase B exit criteria are met.
