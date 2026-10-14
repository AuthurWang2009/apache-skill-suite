---
name: apache-commit-pr
description: >-
  ASF-generic commit & pull-request conventions, guardrails, and pre-submit
  compliance self-check for any Apache Software Foundation repository. Use
  ONLY when BOTH hold: (1) the repo is Apache (a checkout or fork of a
  github.com/apache project) and (2) the user asks for commit/PR work —
  commit changes, write a commit or PR title, open or update a PR, fill the
  PR template, check changes against the repo's rules before submitting, or
  investigate CI/PR failures, even indirectly ("提交一下", "开个 PR", "CI 挂了
  看看"). Loads or mines the per-repo rule pack (.zcode/rules/<project>.md)
  — never guesses, never borrows another repo's rules. Enforces: no upstream
  PR without an issue, approval gating on every git/gh write, AI disclosure
  in the PR body, never push the official remote. NOT for non-Apache repos;
  fork/branch syncing is the apache-sync-fork skill's domain.
when_to_use: >-
  Trigger on indirect phrasings too ("帮我开个 PR", "开 PR 前帮我过一遍规范",
  "CI 挂了看看", "reviewer 评论了帮我改"). Covers title format, PR body
  template, evidence chain, squash-merge mechanics, backport targets. Do NOT
  trigger for plain git questions (revert/rebase) without commit/PR intent,
  non-Apache repositories, or fork-upstream syncing (apache-sync-fork).
---

# Apache Commit & PR Compliance Kernel

A personal-level, repository-generic skill that governs the commit/PR moment in any Apache Software Foundation repository: remote identification, title and PR-template frameworks, gate frameworks, CI interpretation, ASF compliance, and hard guardrails. It loads — or mines — a per-repository rule pack (`.zcode/rules/<project>.md`) before any commit or PR action, and never guesses or borrows another repository's rules.

## Scope, Tags, and Core Principles

**Division of labor:**

- End-to-end task orchestration (find issue → branch → verify → review → wrap up) belongs to the sibling skill `apache-dev-workflow`.
- fork↔upstream branch syncing belongs to `apache-sync-fork`; its sync set is self-contained and does not read this suite's rule packs.
- When both generic skills trigger on the same intent, Step 0's session-level dedup converges them: whoever triggers first, the behavior is identical.

**No repository facts live in this body.** Every repo-specific value — title format, default branch, gate commands, template sections, label vocabulary, and so on — comes from the rule pack.

**Tier tags** (every rule below carries its tier as its confidence basis):

- `[MECH]` — GitHub/gh engine mechanics, repo-independent.
- `[ASF]` — Apache Software Foundation policy, common to all projects.
- `[USER]` — user collaboration policy (user rule, stricter than community norms).

**Anti-reinvention principle.** Only "very certain" content is hardcoded, limited to the three tiers above: engine mechanics, foundation policy, user policy. Every project fact is read at runtime from the already-cloned repository (project docs, git history, CI configs). The cache is nothing more than the persisted result of that reading; a cache miss means "derive it now", never "invent it".

## Step 0: Load the Repository Rule Pack (Mandatory)

Run this before any other step.

**Session dedup:** if this session has already loaded this repository's rule pack, or already holds mining results, reuse them — no re-reading, no re-mining, no second approval request. This is what converges a double trigger from the sibling skills.

### Deference pre-check (before any reading)

If the session's skill discovery list contains a self-contained, same-intent project-level skill for this repository (the pre-migration legacy form), defer to it completely: do not read the pack, do not mine, do not bootstrap — the legacy skill leads all behavior. The skill discovery list is the sole basis for this judgment (archive directories are outside the discovery path, so archiving the legacy skill automatically lifts the deferral).

### Upstream identification chain

[MECH]-level procedure — identification is a procedure, not a constant. Identify by URL, never by remote name.

- **a. Fast path (covers the main scenario).** Run `git remote -v`. A remote pointing to `github.com/apache/<project>` is the official remote, and `<project>` is the rule pack key.
- **b. Fork lineage API (authoritative fallback, works anonymously).** If (a) misses and `origin` is a GitHub repository, call `GET api.github.com/repos/<owner>/<repo>`. When `.fork=true`, the official repository is `.source.full_name` — for nested forks take `source`, not `parent`, because `source` is the root of the fork network. If a local remote already points to it, use that remote; otherwise tell the user they may run `git remote add` themselves. Never add the remote automatically.
- **c. Attribution (independent of identification).** The official repository is in the `apache/` organization, or the repository contains `.asf.yaml` → ASF project: enable the kernel compliance checklist (ALv2 / ICLA / PR-first). If the organization is not `apache`, keep the same skeleton, treat the ASF-specific compliance items as N/A, and state explicitly which norms do not apply — do not go silent and do not hard-refuse. This is the body-level degrade path used on explicit slash invocation; it lies outside the trigger domain.
- **d. Everything failed** (non-GitHub hosting, missing lineage) → ask the user. Do not guess.

### Read the pack

Immediately read `<repo-root>/.zcode/rules/<project>.md` in full — no skimming.

- **G layer** — generic kernel rule snapshot (anti-skim redundancy; the skill body is always authoritative over it).
- **P layer** — the project's CI/CD rule cache.

On a P-cache hit that has not expired, use the cache directly — no re-collection — and report a one-line source note, e.g. `cache hit · verified <date> · source .zcode/rules/<project>.md`.

### Missing pack or cache

A missing pack or cache — new repository, first execution, fresh clone — is a normal state, not an error.

1. First attempt to restore from the personal master copy `~/.zcode/rules/<project>.md` (at most one approval, ≤ 5 minutes).
2. If still missing, run the Inline Mining Program (below) on the spot — read-only, minutes-level. Use the results for the current task immediately; then, with user approval, write them into the cache for direct use next time. A first execution is simply the "collect and cache" pass, and the task is never blocked by it.
3. If the user declines persisting the cache, use the results for this run only and ask again on the next miss. There is no persistent suppression state.
4. **Never guess or borrow another repository's rules — not even partially.** What is forbidden is guessing or borrowing instead of mining; mining itself is the anti-guessing mechanism. Fields that mining cannot determine get a generic default plus a question to the user.

### Cache invalidation

Dual trigger — time plus event. Before judging, run `git fetch <upstream> --prune` (a fetch is an approval-free, read-only operation):

- The `verified` header is more than 90 days old; **or**
- CI artifacts (workflows, lint configs, templates, `.asf.yaml`) have changed since `verified`.

Either condition → pack-level re-mine (discipline under "Invalidation and re-mining discipline").

### Conflict resolution order

**[USER] policy layer (cannot be overridden; only an explicit user exemption lifts it) > P-layer project facts > skill body (non-[USER] kernel) > G-layer snapshot.**

- The P layer may only record deviation facts against a [USER] policy and report them to the user; it can never override the policy. "Recent merged PRs in this community mostly skip the close keyword" is a deviation fact — it does not overturn the user's no-PR-without-an-issue policy.
- When the upstream's own AGENTS.md or templates conflict with the pack, report the conflict to the user for a ruling. Never silently pick one side.

### Schema-version downgrade

A pack whose `schema-version` is unrecognized is treated as missing (follow "Missing pack or cache"). Use the re-mined results in memory only — never overwrite the original pack — and report the situation to the user. This prevents cross-machine version ping-pong.

## Hardcoded Tiers

Only the three tiers below are hardcoded, and every rule carries its tier tag as its confidence basis.

### [USER] User Policy (stricter than community norms)

#### Approval gating — literal full interception of every git/gh write

- **Scope.** Every git/gh write operation requires explicit approval from the user in the current session: local commits, pushes, PR/issue/comment writes, persisting the rule pack cache, and CI reruns are all included ("字面全拦"). Only read-only operations are approval-free (the set is listed below).
- **Form of approval.** An explicit instruction from the user in the current session, or an explicit reply to an approval card. Instruction coverage is read literally and interpreted narrowly when ambiguous — "提交一下" ("commit it") covers only the local commit; push and PR each get their own approval card.
- **Approval card — five elements** (one unified template across all repositories):
  1. The verbatim command text awaiting approval.
  2. A one-sentence risk statement.
  3. A task number: `issue #N` when an issue exists; otherwise a task-log entry ID such as `<branch-or-topic>-<date>` (ops, dry-run, and synthetic tasks may use their own identifiers — the card structure is unchanged).
  4. At least two alternative options.
  5. No approval within 30 minutes → park: suspend, keep the summary, resumable at any time, no automatic retry.
- **Pressure valve — "approve-all-for-this-round" ("这轮都批").** A conversational, session-scoped ranged authorization, e.g. the user instructing "items 2 and 3 are fixed — push them". Within the authorized range, stop asking per item, but log every remote write to the task log individually. Remote writes never enter a permanently approval-free state.
- **The gate recognizes the session, not the origin.** An approval arriving through a user-configured Bot Channel (never hardcode the channel name) is an in-session approval. The executor is always the desktop session; the Bot Channel is its remote interface, and the desktop app being online is a precondition (see Honest Limitations).
- **Waiting semantics.** Event waits — CI completion, review arrival — have no timeout. Only approval waits use the 30-minute park.
- **Approval-free read-only set:** `git fetch <upstream> --prune`, gh read commands, anonymous API calls, and every input operation of the Inline Mining Program.

#### No upstream PR without an issue — zero exceptions

Every PR starts from an issue, including typo, doc, and follow-up changes. For a follow-up whose original issue is already closed, create or reopen an issue that references the original PR, and start from there. The linking channel — a `close #N` keyword in the body versus an issue number in the title — is dispatched by the rule pack's `issue-link-channel` axis; this clause deliberately does not mandate a channel. Community deviation facts recorded in the P layer are report-only and are never applied.

#### AI disclosure

Voluntarily append an `Assisted-by: <model:version>` line to the PR body (e.g. `Assisted-by: ZCode:GLM-5.3`). The rule pack's template section records whether the project template has an AI section: fill that section when it exists; otherwise append the line voluntarily. Never list the AI as a co-author, and never place AI self-references in source code, comments, titles, or commit messages (ASF Generative Tooling Guidance framework).

### [MECH] Engine Mechanics (GitHub/gh behavior, repo-independent)

**Squash merge semantics.** In squash-enabled repositories (the mainstream ASF form), the PR title and body become the merge commit message — when the scope grows, update the title and body in sync. The individual commit messages inside the branch never enter final history.

**The `(#N)` suffix is the PR number.** The suffix GitHub auto-appends on squash merge (including the backport double-suffix scenario) is the PR number, not the issue number. A human never writes it — hand-writing it forges engine behavior. The repository's specific title format comes from the rule pack's title section, but "never hand-write `(#N)`" holds across all repositories.

**Closing keywords.** Only `close`/`fix`/`resolve #N` in the PR **body** can auto-close an issue; GitHub does not parse numbers in the title. When auto-closing is required, the link must live in the body — or in the equivalent channel dispatched by the pack's axis. Title and body are not interchangeable.

**Fork = staging area.** The personal fork is the only push target (the mirror of the [ASF] PR-first rule). Fork-side CI forms vary by repository: a push may trigger CI directly, only an upstream PR may trigger it, or an intra-fork PR may be the only route. Always check the rule pack's `ci-carrier` axis before opening an intra-fork PR — the wrong track creates an entity with no CI value that then needs manual cleanup.

**CI investigation pattern.**

```bash
gh run list  -R <repo> -b <branch> -L 5
gh run view <run-id> -R <repo> --log-failed    # add -j <job-id> to drill into one job
```

Classify each failed job into exactly one of five states — one line per job: state + basis + action. Never assert a state without a basis.

- **Real bug** — the failure localizes to a module or test this diff touches → back to the fix loop.
- **Environment** — infrastructure / network / dependency-fetch failure → observe or rerun.
- **Flaky** — the judging procedure is weak, so downgrade the wording: "suspected flaky → request rerun approval to verify" (revisit upgrading only after samples accumulate).
- **Not run** (first contribution awaiting the approval chain) — recognize the waiting status → run the unlock chain: draft the approval-request comment and issue an approval card.
- **Compliance gate** (lint / license class) — a rerun cannot save it → fix the code or add the missing headers, back to the gate checklist.

A rerun is a write operation: issue an approval card (it may fall under "approve-all-for-this-round").

### [ASF] Foundation-Level Policy

**PR-first contribution flow.** An individual never pushes the official repository (`github.com/apache/<project>`, whatever the remote happens to be named). Every change goes through PR + review.

**ALv2.** New files carry the Apache-2.0 license header, copied from any existing file in the repository. License-check tools may scan gitignored local files — do not place private files in the repository root.

**ICLA policy framework.** An occasional PR needs no ICLA (ALv2 clause 5). Sign before sustained substantial contributions or a committer nomination — personal email, matching the git config email.

**Issue etiquette defaults.** Search before creating; claim by comment ("taking this"); non-committers cannot self-assign. When the repository has more specific etiquette, the rule pack governs.

**Security vulnerability re-routing (hard branch).** On discovering a security vulnerability (RCE / authentication-bypass class), abort all public process at once: create no issue, open no PR, and describe no vulnerability details in public comments. Route through the private channel recorded in the rule pack's routing section. If the pack is missing, infer the ASF default private channel and mark it "unverified" — a wrong address means a lost vulnerability report, an asymmetric risk (pending verification closure).

### Hard Guardrails (standard text, identical across all repositories)

Disaster-level rules are backstopped in layers: the rule pack's guardrails section (placed first) → the structured gate (see "Pre-Submit Compliance Self-Check") → the repository-local AGENTS.md pointer, if present → approval gating as the final backstop.

- NEVER push to the official Apache remote (`github.com/apache/<project>`, whatever it is named). PRs only — the personal fork is the only staging area.
- NEVER open an upstream PR without a linked issue — zero exceptions: typo, doc, and follow-up changes all start from an issue; if the original issue is closed, create or reopen an issue referencing the original PR. The linking channel follows the rule pack axis.
- NEVER hand-write the `(#N)` title suffix — GitHub squash auto-appends the PR number.
- NEVER force-push shared branches (force-pushing a PR branch you have coordinated on is acceptable).
- NEVER commit credentials, IDE files, build artifacts, logs, or other private artifacts; new files carry the Apache-2.0 header.
- NO git/gh write operation without explicit approval in the current session (approval card with its five elements; "approve-all-for-this-round" is the session-scoped pressure valve; remote writes are never permanently approval-free).

## Honest Limitations (Accepted Residual Risks)

This suite relies on probabilistic triggering and local file reads. The residual risks below are known and accepted; they are not to be designed away.

1. **Triggering is probabilistic.** The skill has no deterministic invocation as its main path (explicit `/apache-*` slash calls exist only as a fallback escape hatch). The description follows the official design advice, but no natural-language trigger can be guaranteed to hit.
2. **The rule pack can be bypassed by non-target paths.** A session that never triggers this skill may still casually commit or open a PR: the pack goes unread and the compliance self-check does not run. Approval gating is the final backstop — every push and PR still needs explicit approval, and results produced on the bypass still reach the user as proposals.
3. **kyuubi has no controllable AGENTS.md resident channel.** Its AGENTS.md is a tracked upstream asset that cannot be modified, so this suite's disaster guardrails cannot be injected into that resident channel. When its existing identify-the-remote-by-name rule conflicts with this skill's identify-by-URL rule, report to the user for a ruling — never silently pick one. That repository's guardrails are carried by three layers: the pack's guardrails section, the structured gate, and approval gating.
4. **A stale G layer can mislead a skimmer.** The conflict order keeps the skill body authoritative over the G-layer snapshot, but a session that reads only the G layer may walk away with an outdated generic rule snapshot.
5. **Soft-convention repositories have only the 90-day time backstop against title drift.** In a repository with no title lint workflow and no merge-rewrite script, community title drift changes no CI artifacts, so the event trigger never fires; only the `verified` > 90-day time trigger re-mines.
6. **The cross-machine fresh-clone coexistence window leaves deferral residue.** When no legacy project-level skill exists on this machine, the Step 0 deference check has nothing to defer to; approval gating backs that window (every remote write still needs explicit approval).
7. **A desktop app online is the precondition for remote instruction and approval capability.** The Bot Channel is the desktop ZCode session's remote interface, not an independent mobile execution environment; the executor is always the desktop session. When the desktop session sleeps or exits, phone-side instructions — approvals included — cannot be processed. This is an environmental fact; there is no wake-up design.
8. **Cross-session scheduled reminders and event wake-up are not supported.** Cron-style polling (CI completion, new review comments — in-session reminders) lives only as long as the session does. There is no carrier for cross-session reminders; the user must start a new session.

## Derived Layer: Repository Facts (Never Hardcoded)

General rule: on a cache hit, use it directly. On a miss, derive on the spot from the sources below — or run the whole Inline Mining Program — and persist to the cache with approval. **Title conventions are repo-specific and sometimes mutually exclusive**: never treat any one repository's form as the generic default.

1. **Merge buttons and protected branches** → read `.asf.yaml` (merge buttons + `protected_branches` sections).
2. **Default branch** → double confirmation: the `.asf.yaml` protected branch name plus `git symbolic-ref refs/remotes/<upstream>/HEAD`.
3. **Title conventions** → three mutually exclusive states:
   - *ci-lint state* — a title lint workflow exists (semantic-PR / pr-title-check class) → read the workflow config for the rules.
   - *merge-tool state* — a merge rewrite script exists (dev/tools-style directories) → read the script's regex and rewrite behavior.
   - *soft-convention state* — neither of the above → title pattern statistics from `git log --oneline -50 <upstream>/<default>` plus the title section of the project's contribution docs.

   Applying repository A's form to repository B is the classic failure mode.
4. **Issue linking channel and etiquette** → PR/issue templates + contribution docs (CONTRIBUTING, docs/contributing) + recent merged PR body samples (closing-keyword usage statistics).
5. **PR template sections (including whether an AI disclosure section exists)** → read `.github/PULL_REQUEST_TEMPLATE*` and mark each section required or optional.
6. **Pre-submit gates and CI details** — gate commands, ci-carrier, fork runnability, fast-gate duration, known baseline noise → Inline Mining Program output (the rule pack's pre-commit / ci sections).
7. **Official and private channels** — mailing lists, discussion areas, security channel → the rule pack's routing section (`.asf.yaml` notifications + contribution docs + presence of SECURITY.md; when missing, infer the ASF defaults and mark them "unverified").

## Inline Mining Program (Self-Contained)

One shared engine for first collection, new-repository bootstrap, and invalidation re-mining.

### Cache semantics (three P-layer properties)

- **Non-mandatory.** A missing cache is a normal state — new repository onboarding, first execution, fresh clone, cleanup — not an error. The program works without a cache: on a miss, mine online on the spot (this program, read-only, minutes-level) and then act. Never refuse the task and never guess rules.
- **Non-static.** Invalidation re-mines on a dual trigger — time (`verified` > 90 days) and event (CI artifacts changed) — with no manual maintenance.
- **Enhancing when present.** A hit is used directly, with no re-collection; operations are precise to the project's real gates. Professionalism equals every entry being traceable to a source artifact.

### Inputs (all read-only, approval-free)

- `.github/workflows/*` — triggers, jobs, step commands, matrix, permissions, secrets dependencies
- `.github/actions/*` — composite actions, which often hide spotless/license gate implementations that `workflows/*.yml` alone would miss
- CI script directories (`tools/`, `dev/`, `build/`, and similar conventions)
- lint/format configs — spotless, checkstyle, `.licenserc.yaml`, scalafmt, pre-commit hooks, and the like
- `.asf.yaml` — merge buttons, protected branches, notifications
- PR/issue templates (`.github/PULL_REQUEST_TEMPLATE*`, `.github/ISSUE_TEMPLATE/*`); labeler / dependabot / renovate configs
- CONTRIBUTING and the other contribution docs
- The project website's contribute / subscribe / security pages — the strongest written evidence for community etiquette and security channels, more authoritative than PR samples
- git sampling: `git log --oneline -100 <upstream>/<default>` title forms
- PR samples: ~20 open + ~20 merged PR titles (the anonymous API works)

### Read CI artifacts at the pinned upstream ref

The local clone may sit thousands of commits behind upstream. Read CI artifacts (backend.yml and the like) against the upstream's latest ref and record the base SHA:

```bash
git show <upstream>/<branch>:<path>
```

Skipping this records matrices and trigger surfaces as stale facts.

### Three-step mechanical derivation

Covers the vast majority of axes (the method is field-validated across multiple ASF repositories):

1. `.asf.yaml` + workflow triggers → merge-governance / default-branch / ci-carrier / `(#N)` semantics / release-branch-pattern
2. Templates + PR samples → issue-link-channel / template section list / presence of an AI disclosure section
3. CI steps + scripts + lint configs → gate checklist / local test commands / label filter vocabulary

### Derivation mapping

- Workflow triggers → ci-carrier axis + fork runnability (secrets-dependency analysis)
- Locally pre-runnable commands found in CI steps → gate checklist
- Title lint workflow → title governance state + title rules
- Test matrix (JDK / OS / engine profiles) → local reproduction commands + a "local pass ≠ CI green" reminder that lists the matrix dimensions
- PR/issue templates → template sections and filter inputs
- `.asf.yaml` → branch-protection axis
- Labeler path mappings → label filter vocabulary — must come from this repository's first-hand list; cross-repo inheritance is forbidden
- Check names in `.asf.yaml` protected-branch `contexts` (e.g. "Title Validator") → trace back through `workflows/` and `.github/*bot*.yml` bot configs to locate the gate's implementation — a gate's name and its implementation often live in two different artifacts

### PR sampling and API discipline

- Fetch merged samples via `pulls?state=closed&per_page=N`, then filter `merged_at != null` (closed ≠ merged). Open samples are only worth fetching when merge-governance is soft-convention — under ci-lint, open titles are forcibly compliant too, so they contribute nothing as evidence.
- Anonymous API rate limits: the search endpoint allows 10 requests per minute and, on failure, may return an empty body instead of a JSON error. Prefer REST endpoints with fully URL-encoded queries for label and issue counts, with a retry interval of at least 7 seconds.

### Evidence strength and special fields

- Evidence strength ordering: written rules in the contribution docs > PR/commit sample statistics — the docs often deliver two-thirds of the evidence for fields like the issue channel.
- Timing-type fields (fast-gate duration, matrix scale) may inherit the last verified value, marked 〔继承〕 (inherited) — re-measuring requires run-sample collection, which lies beyond the normal input surface.
- Vestigial or broken configs (bot config typos, regex mismatches) go into manual-research with a "do not rely" note; they are never a derivation basis.

### Output: rule pack structure (after approval)

Schema-version 1. The full master template lives at `~/.zcode/skills/apache-dev-workflow/templates/rule-pack-template.md`; when the master is missing, persist per this skeleton.

Header fields:

- `schema-version: 1`
- `kernel-version:` — this kernel's current version, `1.0-draft-2026-10-14`
- `verified: <today>` — the pack-level invalidation criterion

Layers:

- **Layer G** — generic rule snapshot, generated read-only, anti-skim redundancy: the g-guardrails and g-kernel sections, mechanically regenerated from the seed template with hand-editing forbidden; may be backfilled later (not mandatory).
- **Layer P** — the project cache: the axis-value header (upstream / default-branch / release-branch-pattern / merge-governance / issue-link-channel / ci-carrier / branch-protection / target-branch-backport / pr-update-style / evidence-types / issue-pr-relation) plus the sections — **guardrails (the project's disaster-level guardrails, placed first)** / title / template / pre-commit / ci / filter / routing / local / misc / manual-research.

Every P-layer value carries a one-line provenance (file / command / API + date). Record fields mining could not determine as `unknown`, with a note on what was tried — never copy another repository's value.

### New-pack bootstrap

1. Mirror the personal master copy (`cp` to `~/.zcode/rules/<project>.md`).
2. Confirm `/.zcode/` is gitignored.
3. Write the two [USER] norms — no PR without an issue, and AI disclosure — into every new pack by default, and confirm their applicability with the user once.

### Invalidation and re-mining discipline

Triggers: time > 90 days, or CI artifacts changed since `verified` per git — and run `git fetch <upstream> --prune` before judging. Re-mine at pack level: diff "cache ↔ actual CI config" and update on drift. The discipline:

- Mining entries: update them.
- Manual-research entries — soft conventions, historical anti-patterns, operational rules, anything not derivable from CI artifacts — live in their own manual-research subsection; re-mining never overwrites them; report when in doubt.
- Summary lines marked 〔manual〕 inside the guardrails section must survive re-mining. Disaster-level rules are dual-written: guardrails summary + manual-research full record + cross-reference.

### Lazy mining semantics

When the pack is missing, on-the-spot mining may be deferred until just before a format-sensitive operation — push, PR, or title assembly. A purely local, draft-type commit is not blocked by the missing pack and must not be refused; but tell the user explicitly: "the rule pack is missing; it will be collected before any push or PR."

### Post-mining self-checks

- **Pollution self-check (after bootstrap).** Phrase the checks at the semantic level, not by tool name — "does the PR title section show a `[Type][Module]` without an issue number", not a grep for a tool name. The target repository's own legitimate use of a same-named tool causes false positives.
- **Empty-source preference section.** When the conversation contains no extractable preference statements, create the preference section with `unknown` placeholders and prompt the user to state preferences. Never fabricate preferences and never block the flow on it.

## Pre-Submit Compliance Self-Check and Evidence Chain Card

**When it runs:** when the user asks to check everything against the norms before opening a PR, and as the accompanying material for every push / PR approval card (a diff summary and the evidence chain card are encouraged to ride along with the card).

**Operation sequence:** local code changes and gate pre-runs → self-check card → commit (approval-gated) → push approval card → fork CI five-state interpretation → structured gate + PR approval card.

**Environment precheck (before gate pre-runs).** Compare the local JDK / toolchain against the rule pack's local matrix. When none of the machine's versions is workable (e.g. the project targets a source level the local JDKs cannot build), either switch to a workable JDK or downgrade the item to an explicitly reported gap — never silently skip.

**Commit procedure.** Stage files by explicit path — never `git add -A`, never `git add .`. When the working branch is based on an upstream base, locally added gitignore enhancements that upstream does not yet have do not apply, so private workspace files (planning docs, rule pack caches) sit untracked inside the add surface.

### Evidence chain card (three columns)

Rule + source + verification evidence. Source-less assertions in the style of "✅ checked" are forbidden. At minimum, cover:

| Check | Rule (source = rule pack entry) | Verification evidence |
|---|---|---|
| Title form | title-section cache entry (with original provenance) | the actual title + type-word / component-word hit verdict + the trade-off note when a word was omitted as uncertain |
| Issue link | [USER] no-PR-without-issue + issue-link-channel axis | issue existence + the actual linking method (e.g. the verbatim close line) |
| PR body sections | template section (template file provenance) | presence, section by section |
| AI disclosure | [USER] disclosure policy + template-section presence | the actual `Assisted-by:` line in the body |
| Gate checklist | every pre-commit entry (each with its CI-artifact provenance) | locally executed commands + result summary (not run = a gap item, never marked green) |
| Base branch | default-branch axis value (double-confirmation provenance) | the actual `--base` value |
| Hard guardrails | g-guardrails | ALv2 header check on new files + itemized evidence of no credentials / IDE files / build artifacts / logs |

### Hitchhiker changes

Refuse to mix drive-by changes unrelated to the issue (typos, unrelated refactors) into the diff; suggest a separate issue + PR instead. [USER] grants no exemption here either — a typo needs an issue too.

### Adversarial self-review

Re-examine your own diff from a fresh-context perspective: re-read it with a changed viewpoint, without "I just wrote this" assumptions, and append any findings to the card.

### Structured gate (mandatory before `gh pr create`)

When presenting the approval card, restate the title format used and its source — for example: "title format <format>, source: rule pack title section, original provenance <artifact>". This self-certifies that the rule source was actually read. No restatement, no creation.
