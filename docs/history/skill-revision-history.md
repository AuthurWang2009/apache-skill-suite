# Skill revision history (provenance)

Dated provenance extracted from the skill bodies during the 2026-10-14
English restructure. Operational content lives in the skills; this file
keeps the historical record. Curated user-facing changes: CHANGELOG.md.

## apache-commit-pr

# Dropped historical items from apache-commit-pr SKILL.md rewrite (2026-10-14)

Historical framing removed from the skill body during the English restructure. All behavioral content was preserved in the rewritten body; only the dated/narrative framing below was dropped.

- 2026-10-13 — User adjudication establishing the anti-reinvention principle: only the three "very certain" tiers ([MECH]/[ASF]/[USER]) are hardcoded; all project facts are read at runtime from the cloned repo.
- 2026-10-13 — Arbitration (R1-12): approval gating made "literal full interception" (字面全拦), covering local commits, with the "这轮都批"/approve-all-for-this-round pressure valve.
- 2026-10-13 — User ruling: no upstream PR without an issue, zero exemptions (typo/doc/follow-up included).
- 2026-10-13 — User ruling: AI disclosure policy (voluntary `Assisted-by: <model:version>` line in PR body, never co-author).
- 2026-10-13 — R1 vote, 12 items all effective, including R1-3 (flaky downgraded wording), R1-7/R1-7A (limitations-section position right after guardrails), R1-8 (routing "unverified" marking), R1-2A (cross-session reminders unsupported), A3 (〔manual〕 summary-line protection in guardrails).
- 2026-10-13 — Honest-limitations residual risks formally accepted (documented in plans v2.5 / v2.13–v2.14 and the R1 vote); "not to be eliminated by further design."
- 2026-10-14 — Changelog entry `1.0-draft-2026-10-14`: initial draft (Phase A Wave2, A1 deliverable) composing the kernel; rule packs backfill `kernel-version:` with this number (constant now inlined in the Output section; Changelog section removed).
- 2026-10-14 — Honest-limitations section footer: "Verbatim from aux-docs, 8-item version synced 2026-10-14; position per R1-7A" (position behavior kept, provenance footer dropped).
- 2026-10-14 — "实战改进注记" field-test revisions (B3 seatunnel first collection + B4 dolphinscheduler closed-book exam merge): 8 mining-program improvements, folded into the Inline Mining Program section.
- 2026-10-14 — B5 dry-run revision 1: `git add` restricted to explicit paths after a live incident (untracked private files exposed on the add surface when gitignore enhancements were not yet upstreamed); folded into the commit procedure.
- 2026-10-14 — B5 dry-run revision 2: environment precheck added (JDK mismatch case: project source 11 vs local 8/21 — 8 fails to compile, 21 breaks old spotless javac internals); generalized in gate pre-runs.
- 2026-10-14 — B5 dry-run revision 3: CI artifacts must be read at the pinned upstream ref (`git show <upstream>/<branch>:<path>`) after a stale-matrix incident (matrix actually 11/17, stale pack recorded 8/11); folded into mining inputs.
- 2026-10-14 — B5 dry-run revision 4: "stage 0.5" preference-section empty-source branch (unknown placeholder, prompt user, never fabricate/block); folded into post-mining self-checks.
- 2026-10-14 — B5 dry-run revision 5: approval-card task number allows non-issue identifiers for dry-run/ops/synthetic tasks (example "B5-dryrun"); folded into the approval card five elements.
- 2026-10-14 — B5 dry-run revision 6 (cross-host field test on hbase): lazy-mining semantics validated — defer mining to before format-sensitive ops, announce to user; trigger surface unchanged; folded into the mining section.
- Dropped narrative flourishes: "B5 实测踩中" test narratives, "方法已在多个 ASF 仓抽样实战验证" condensed to "field-validated across multiple ASF repositories", "翻车主因" → "the classic failure mode".

## apache-dev-workflow

# changelog-extract — apache-dev-workflow SKILL.md

Historical items moved out of
`/Users/arthur/workspace/projects/apache-skill-suite/skills/apache-dev-workflow/SKILL.md`
during the 2026-10-14 English restructure (1.0-draft → 1.1). Every behavioral
clause from these blocks was folded into the corresponding section of the new
body; this file preserves only the dated/historical framing and provenance
codes. No rule was dropped.

## 2026-10-13 — user adjudications and votes cited throughout the original body

- R1 vote (2026-10-13): residual-risk acceptance recorded in the honest-limitations
  section (kept in the body with dates; internal vote item codes removed).
- R1-1A: backlog header as the preference-section carrier.
- R1-2A: in-session polling only; cross-session reminders unsupported
  (honest-limitations item 8) — kept in body, code dropped.
- R1-3A: flaky downgraded wording ("suspected flaky → approve a rerun").
- R1-4A: ping pre-check of release cadence via §misc release-branch-activity.
- R1-5A: numbered comment list for remote itemized instructions.
- R1-7A: honest-limitations section positioned directly after guardrails.
- R1-8B: "unverified" marking for inferred private security channels.
- R1-12: literal full interception of all git/gh writes (approval gating).
- "反闭门造车原则" (anti-reinvention) user adjudication, 2026-10-13 — kept in
  the body's Operating model section.
- Approval gating arbitration ("字面全拦") dated 2026-10-13 — kept in the body.
- No-PR-without-issue and AI-disclosure user adjudications dated 2026-10-13 —
  kept in the body.

## 2026-10-14 — 1.0-draft initial kernel (Phase A Wave 2, A2 deliverable)

- Drafted as the A2 deliverable of Phase A Wave 2 of the skill-suite plan
  (v2.5/v2.13-v2.14 plan lineage).
- Step 0 seven-item load protocol declared "verbatim-isomorphic" with
  apache-commit-pr; [USER] policy layer; seven-stage skeleton; security
  re-route hard branch; state/cross-session; hard guardrails; honest
  limitations (8-item version, text source = A4 aux-docs
  "诚实限制节", synced 2026-10-14); inline mining procedure dual-carried with
  apache-commit-pr (revisions must be synced across both files).
- Axis/section consumption map recorded in the original changelog entry:
  six axes (1→Stages 2/5; 2→Stage 2; 3→Stages 6/7; 4→Stage 5; 5→Stages 0/4;
  6→Stage 6) + four dimensions (target-branch-backport→Stage 2;
  pr-update-style→Stage 6; evidence-types→Stage 5; issue-pr-relation→Stages
  5/7) + ten sections (guardrails→general rule; title→Stages 4/5/6;
  template→Stage 5; pre-commit→Stages 3/6; ci→Stages 0/4/5/6; filter→Stage
  0.5; routing→Stages 1/6/7 + security re-route; local→Stage 3; misc→Stages
  2/6; manual-research→Stage 7). (Condensed form retained in the body's
  Changelog.)
- Installation form: SKILL.md → `~/.zcode/skills/apache-dev-workflow/SKILL.md`;
  A3 draft of the seed template = master for
  `templates/rule-pack-template.md`.
- kernel-version backfill note: this file and apache-commit-pr
  (1.0-draft-2026-10-13) are the same kernel; the version-date difference is
  only the writing date; unify at G0b finalization.

## 2026-10-14 — field-test revision notes ("实战改进注记": B3 seatunnel first
collection + B4 dolphinscheduler closed-book exam merge)

Historical framing: items below originated as write-backs from the B3 (first
live collection on seatunnel) and B4 (closed-book exam on dolphinscheduler)
field tests. Behavioral content folded into the Inline mining procedure
section; the B3/B4 provenance labels were dropped.

- Input list extended with `.github/actions/*` composite actions and the
  project website contribute/subscribe/security pages. → folded into Inputs.
- PR specimen method (API endpoints stated): `pulls?state=closed&per_page=N`
  filtered by `merged_at != null`; open specimens only needed under
  soft-convention governance. → folded into PR specimen method.
- Anonymous API rate limits: search endpoint 10 req/min, empty-body failures;
  prefer REST + fully URL-encoded queries, retry ≥7 s. → folded into
  Anonymous-API rate limits.
- Derivation line: `.asf.yaml` protected-branch `contexts` check names traced
  back to workflows/ and `.github/*bot*.yml`. → folded into Derivation mapping.
- Evidence-strength ordering: written contribution-doc rules > PR/commit
  specimen statistics. → folded into Evidence-strength ordering.
- Timing-type fields may inherit the last verified value marked 〔inherited〕.
  → folded into Timing-type fields.
- Vestigial/unmaintained configs go to manual-research with a "do not rely"
  note. → folded into Vestigial configs.
- Post-bootstrap pollution self-check uses semantic check items, not tool
  names. → folded into New-pack extra steps (bootstrap).

## 2026-10-14 — B5 dry-run revisions ("B5 干跑修订", measured write-back)

Historical framing: items below were written back after the B5 dry run; the
"B5 实测踩中/实测" provenance labels were dropped, examples retained.

- Explicit-path staging: never `git add -A` / `git add .`; untracked private
  files exposed on upstream-based branches despite local gitignore
  enhancements. → folded into Stage 4 item 2.
- Stage 3 environment precheck (JDK/toolchain vs §local matrix; switch or
  degrade to a reported gap; source-11 vs 8/21 example). → folded into
  Stage 3 item 1.
- Mining iron rule: CI artifacts read via
  `git show <upstream>/<branch>:<path>` against the upstream latest reference
  with base SHA recorded (B5 case: matrix actually 11/17, stale pack recorded
  8/11). → folded into CI-artifact direct-read iron rule.
- Stage 0.5 empty-source preference section: create with `unknown`
  placeholders and prompt; never fabricate or block. → folded into Stage 0.5
  item 1.
- Approval-card task id may be a non-issue identifier (dry-run/ops/synthetic
  scenarios, e.g. "B5-dryrun"); card structure unchanged. → folded into the
  approval-card five elements (task id).
- Lazy mining semantics (cross-host field test on hbase): pack-miss mining
  may be deferred until before push/PR/title assembly for format-insensitive
  local commits; must be announced. → folded into Step 0 item 3.

## 2026-10-14 — 1.1 English restructure (this extract's origin)

- Body rewritten in English, superpowers skill format: title → one purpose
  paragraph → `##` sections (Operating model / Step 0 / [USER] policy layer /
  seven-stage skeleton with `###` stages 0-0.5-1-2-3-4-5-6-7 + security
  re-route / State and cross-session / Hard guardrails / Honest limitations /
  Inline mining procedure / Changelog).
- YAML frontmatter preserved byte-identically (frozen trigger surface).
- No rules added, removed, weakened; no commands, paths, or thresholds
  changed.
- Dated revision blocks folded into stage sections with historical framing
  dropped; that framing is preserved in this file.

## Changelog

- **1.1-2026-10-14** — English restructure in superpowers skill format. No behavioral change: every rule, command, path, and threshold is preserved verbatim in intent. The dated revision blocks (2026-10-14 field-test notes, B5 dry-run revisions, lazy mining semantics) were folded into the Step 0 / stage / mining sections; their historical framing was archived to `changelog-extract-dev-workflow.md`.
- **1.0-draft-2026-10-14** — initial kernel (Phase A Wave 2, A2 deliverable). Historical detail archived to `changelog-extract-dev-workflow.md`: Step 0 seven-item load protocol (verbatim-isomorphic with apache-commit-pr) + [USER] policy layer (literal full interception + approval-card five elements + this-round package card + "approve this whole round" pressure valve) + the seven-stage skeleton + the security re-route hard branch + state/cross-session + hard guardrails + honest limitations + the inline mining procedure (dual-carried with apache-commit-pr; revisions must be synced across both files). Axis/section consumption coverage: six axes (1→Stages 2/5; 2→Stage 2; 3→Stages 6/7; 4→Stage 5; 5→Stages 0/4; 6→Stage 6) + four dimensions (target-branch-backport→Stage 2; pr-update-style→Stage 6; evidence-types→Stage 5; issue-pr-relation→Stages 5/7) + ten sections (guardrails→general rule; title→Stages 4/5/6; template→Stage 5; pre-commit→Stages 3/6; ci→Stages 0/4/5/6; filter→Stage 0.5; routing→Stages 1/6/7 + security re-route; local→Stage 3; misc→Stages 2/6; manual-research→Stage 7). Same kernel as apache-commit-pr (1.0-draft-2026-10-13); the version-date difference is only the writing date.
## apache-sync-fork

- 2026-10-14: renamed from sync-fork to apache-sync-fork (user decision,
  apache-* prefix unification); no dated revision blocks existed in body.
