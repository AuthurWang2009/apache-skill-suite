---
name: apache-dev-workflow
description: >-
  ASF-generic end-to-end contribution workflow orchestration: backlog and
  issue selection with profile matching, branch setup, local verification,
  fork-side CI staging, upstream PR preparation, review iteration, and
  merge/withdraw decisions. Use ONLY when BOTH hold: (1) the repo is Apache
  (a checkout or fork of a github.com/apache project) and (2) the user
  wants to start, continue, or orchestrate development end to end — pick or
  get a recommended issue, claim it, run the right local tests, stage the
  change on the fork and watch CI, prepare the upstream PR, absorb reviewer
  feedback, or review PR status and decide keep/withdraw, even indirectly
  ("找个 issue 开始做", "今晚两小时有什么小任务", "CI 跑完告诉我", "我的 PR
  都什么状态了"). Loads or mines the per-repo rule pack and dispatches
  stages by its axes. Enforces approval gating on every git/gh write, no
  upstream PR without an issue, never push the official remote.
when_to_use: >-
  Also for continuing interrupted work (read docs/tasks state first),
  mobile self-review loops, and cross-session PR status tracking; indirect
  phrases include "看看 reviewer 说了什么", "这个先不做了". Do NOT trigger
  for single commit/PR mechanics without workflow intent (apache-commit-pr),
  plain git questions, non-Apache repositories, or fork/branch syncing
  (apache-sync-fork).
---

# apache-dev-workflow — Apache End-to-End Contribution Workflow

This skill orchestrates a complete Apache contribution from end to end: pick an issue that fits the user's profile, claim it, branch, verify locally, stage on the personal fork, watch CI, open the upstream PR, absorb reviewer feedback, and merge or withdraw. It owns the seven-stage skeleton, approval gating on every git/gh write, rule-pack axis dispatch, backlog profile matching, and the mobile self-review loop. The sibling skill `apache-commit-pr` owns the norm-level details at the commit/PR moment; `apache-sync-fork` owns fork↔upstream branch syncing. Never push the official remote; never open an upstream PR without an issue.

## Operating model

- **Scope split.** This skill handles end-to-end task orchestration. The norm-level details at the commit/PR moment — title templates, PR template sections, gate checklists, evidence-chain cards, and the execution shape of the compliance self-check — declare allegiance to the sibling skill `apache-commit-pr`.
- **Single source of truth.** Both skills read the same rule pack (`.zcode/rules/<project>.md`), share the same [USER] policy layer, and share the same inline mining procedure (the text is carried in both files). When both trigger on the same intent, Step 0 in-session deduplication converges them — whoever triggers first behaves identically.
- **Sync boundary.** `apache-sync-fork` is self-contained: its sync set does not read this suite's rule packs.
- **All repository-specific values come from the rule pack.** Title format, default branch, gate commands, template sections, label vocabulary, branch naming, channel addresses, CI carrier, stale thresholds — none of these live in this body. Stage existence and gating are fixed here; mechanisms everywhere dispatch on rule-pack axes (six axes + four dimensions + the pack's sections).
- **Annotation system.**
  - [MECH] = GitHub/gh engine mechanics (repository-independent).
  - [ASF] = Apache Software Foundation all-project policy.
  - [USER] = user collaboration conventions (user rule, stricter than community norms).
- **Anti-reinvention principle** (user adjudication 2026-10-13). Only "very certain" three-tier content is hardwired: engine mechanics, foundation policy, user policy. Every project fact is read at runtime from the already-cloned repository (project docs, git change history and records, CI config). The cache is just the persisted result of that fresh read; a miss is derived on the spot.
- **Installation layout.** This file installs to `~/.zcode/skills/apache-dev-workflow/SKILL.md`. The seed template installs beside it at `templates/rule-pack-template.md` — the master form of the inline mining procedure's persisted output.

## Step 0 — Load the repository rule pack (MANDATORY, before any other step)

**In-session deduplication.** If this session has already loaded this repository's rule pack, or already holds mining results for it, reuse them. Do not re-read, do not re-mine, and do not ask for approval a second time (actions triggered by both sibling skills converge here).

0. **Deferral precheck — before any read.** If this session's skill discovery list contains a self-contained, same-intent, project-level skill for this repository (the pre-migration old form), defer completely:

   - Read no pack. Run no mining. Run no bootstrap.
   - That old skill leads all behavior.
   - The decision basis is the **skill discovery list** — archive directories are not on the discovery path, so archiving the old skill lifts the deferral automatically.

1. **Upstream identification chain** ([MECH]-level procedure — identification is a procedure, not a constant; match by URL, never by remote name):

   a. `git remote -v` — if a remote points at `github.com/apache/<project>`, that is the official remote and `<project>` is the rule pack key (fast path; covers the main scenario).

   b. No hit and origin is a GitHub repo → **fork lineage API** (authoritative fallback, works anonymously):

      ```
      GET api.github.com/repos/<owner>/<repo>
      ```

      When `.fork=true`, the official repository is `.source.full_name`. For nested forks take `source`, not `parent` — `source` is the root of the fork network. If a local remote already points there, use it; if not, tell the user they can run `git remote add` themselves. Never add it automatically.

   c. **Ownership determination (independent of identification).** The official repository is in the `apache/` organization, **or** the repo contains `.asf.yaml` → ASF project: enable the kernel compliance checklist (ALv2 / ICLA / PR-first). Non-apache organization → the same skeleton still applies, with the ASF-specific compliance items treated as N/A and an explicit statement of which norms do not apply. Neither play dead nor hard-refuse; this is the body-level degradation path for explicit slash invocations, outside the trigger domain.

   d. All of the above fail (non-GitHub hosting, missing lineage) → ask the user. Never guess.

2. **Read `<repo-root>/.zcode/rules/<project>.md` immediately and in full** — no skimming.

   - **Layer G** = generic kernel rule snapshot (anti-skim redundancy; the skill body is always authoritative).
   - **Layer P** = the project's CI/CD rule cache.
   - P-cache hit and not stale → use it directly, no re-collection, and report a one-line source, e.g. `cache hit · verified <date> · source .zcode/rules/<project>.md`.

3. **Pack/cache missing** (new repository, first execution, fresh clone — a normal state, not an error):

   - First try to restore from the personal master copy `~/.zcode/rules/<project>.md` (at most 1 approval, at most 5 minutes).
   - Still missing → run this document's **inline mining procedure** on the spot (read-only, minutes-level). Use the results directly for the current task, and — with user approval — write them into the cache for direct use next time. First execution *is* the "collect and cache" process; the task is never blocked.
   - The user declines persistence → use the results this once without writing anything, and ask again on the next miss. No permanent suppression state.
   - **DO NOT guess or borrow another repository's rules — not even partially.** What is forbidden is guessing/borrowing *instead of* mining; mining itself is the anti-guessing mechanism. Fields mining cannot determine → generic default + ask the user.
   - **Lazy mining semantics.** For format-insensitive, local-only commits (pure local draft work), mining on a pack miss may be deferred until just before push/PR/title assembly. Do not block or refuse unmined local commits — but always tell the user explicitly: "rule pack missing; it will be collected before any push/PR." The trigger surface is unchanged; the validity of the axis matrix is preserved.

4. **Cache invalidation check** — time + event, dual trigger. Run `git fetch <upstream> --prune` first (fetch is an approval-free read-only operation). Re-mine at pack level when:

   - the `verified` header is older than 90 days; **or**
   - CI artifacts (workflows / lint config / templates / `.asf.yaml`) have changed since `verified`.

   Discipline under "Invalidation re-mine" in the inline mining procedure.

5. **Conflict adjudication order:**

   ```
   [USER] policy layer  >  Layer P project facts  >  skill body (non-[USER] kernel)  >  Layer G snapshot
   ```

   - The [USER] policy layer cannot be overridden; only an explicit user exemption lifts it.
   - Layer P may only *record deviation facts* about [USER] policy and report them to the user. Example: "recent merged PR samples in this community mostly do not use close keywords" is a deviation fact — it cannot overturn the user's no-PR-without-issue policy.
   - When upstream's own AGENTS.md or templates conflict with the pack, likewise report to the user for adjudication. **Never silently pick a side.**

6. **Schema degradation.** An unrecognized `schema-version` in the pack = treat as "missing" (go to item 3). Use the results in memory only, **do not overwrite the original pack**, and report to the user — this prevents cross-machine version ping-pong.

## [USER] policy layer (shared stage-gate conventions; same source as apache-commit-pr)

### Approval gating — literal full interception (arbitrated 2026-10-13)

Every git/gh write operation requires explicit approval from the user in the current session. The set includes, completely:

- local commit;
- push;
- PR / issue / comment writes (including claiming, pings, closes, approval-request comments);
- CI reruns;
- rule-pack cache persistence;
- remote branch deletion.

An approval is the user's **explicit instruction** in the current session, or an **explicit reply to an approval card**. Instruction coverage is read literally; when ambiguous, interpret narrowly — e.g. "commit it" covers only the local commit, and push/PR each get their own approval card.

**Approval card — five elements** (one unified template across repositories):

- [ ] The **command text to approve, verbatim**
- [ ] **Risk**, one sentence
- [ ] **Task id** — has issue = `issue #N`; ops/dry-run/synthetic scenarios without an issue = the task-log entry id, e.g. `<branch-or-topic>-<date>` (the card structure is unchanged)
- [ ] **Alternatives** (at least 2)
- [ ] **30 min without approval → park** (suspend, keep the summary, resumable at any time, no auto-retry)

**This-round package card** (this skill's common card form):

- A round of several write steps (e.g. commit + push + specific comments) may be listed item-by-item and presented as one package.
- **Remote writes are always confirmed as a separate line on the card.**
- Attach the diff summary / file list plus the local gate results already run.

**Pressure valve = "approve this whole round"** (conversational, session-scoped range authorization, e.g. the user's itemized instruction "items 2 and 3 — fix and push"):

- Within the authorized range, no per-item approval requests.
- Every remote write is logged item-by-item in the task log.
- **Remote writes never enter permanent approval-free status.**
- A new write operation in a later round gets a new card.

**The approval gate recognizes the session, not the channel.**

- An approval arriving through a user-configured Bot Channel (never hardcode a channel name) is an in-session approval.
- The desktop session is always the only executor; the Bot Channel is its remote interface, and remote input is just session I/O.
- Approval cards work over any channel the session is mirrored to.
- The desktop app being online is the precondition (see Honest limitations).

**Event wait vs approval timeout.**

- Waiting for CI to finish or a review to arrive = event suspension, **no timeout** (in-session polling; on a hit, immediately push a draft for presentation — no write is executed).
- Only waiting for *approval* has the 30-minute park.

**Approval-free read-only set:**

- `git fetch <upstream> --prune`
- gh read commands
- anonymous API calls
- all input operations of the inline mining procedure

### No upstream PR without an issue (user adjudication 2026-10-13 — zero exemptions)

Every PR starts from an issue — typo, doc, and follow-up included. In the follow-up scenario where the original issue is already closed, open a new issue or reopen one that references the original PR. The linkage channel is dispatched by the rule pack's issue-link-channel axis (see Stage 5).

### AI disclosure (user adjudication 2026-10-13)

Attach `Assisted-by: <model-name:version>` to the PR body voluntarily (e.g. `Assisted-by: ZCode:GLM-5.3`) — never as a co-author line. The rule pack's template section records whether the project template has an AI section: if it does, fill that section; if not, attach voluntarily (placement in Stage 5 assembly).

## The seven-stage skeleton

**General rule for every stage:**

- Before starting any stage, re-check the rule pack's **§guardrails** (project disaster-level guardrails, the pack's top section) once.
- Write to the task log immediately at every stage transition (discipline under "State and cross-session continuity").
- Which actions require an approval card is fixed below.
- Every command value, vocabulary, duration, and channel is a repository value — read it from the pack.

### Stage 0 — One-time setup

- **Fork preparation.**
  - No personal fork → prompt the user to fork (creating a fork is a remote write: approval gate, or the user does it themselves).
  - Fork exists → confirm the local remote layout: origin = fork; official remote = the product of the Step 0 identification chain. When the official remote is missing, tell the user they can `git remote add` it — never add it automatically.
- **Fork Actions enablement.** Manual GitHub UI operation (Settings → Actions); git/gh cannot do it.
  - **Mandatory when ci-carrier=push-direct** — without it, a push triggers no CI at all and Stage 4 loses its entire judgment basis.
  - Other carrier values follow the startup etiquette recorded in the pack's §ci.
- **One-time bookkeeping.** Write the completion into the task log. Later sessions do not ask again (except after an environment rebuild).

### Stage 0.5 — Backlog profile matching (lightweight; no heavy state machine)

1. **Read the task log first: `docs/tasks/backlog.md`.**

   - Current tasks and their stages — an in-flight task exists → present its status before discussing any new task; avoid parallel digging.
   - The log header's **user preference section** — exactly three items: **available time / task-type preference / module familiarity**.
   - Preference section missing = first use: extract from the conversation (e.g. "about 2 hours tonight, wants to fix bugs, familiar with module X") and record it as a section. If the conversation also yields no preference statements, create the section with `unknown` placeholders and ask the user to state preferences — never fabricate preferences and never block the flow.
   - The user's statements change → update conversationally (zero extra ceremony).

2. **Candidate pool refresh** (read-only, approval-free).

   - The filter surface comes **only from the rule pack's §filter** (issue-template shapes + label/search vocabulary).
   - **Label vocabulary must come from this repository's first-hand list — inheriting it across repositories is forbidden.** Querying another repo's vocabulary against this repo, getting zero hits, and then asserting "no available issues" is a hard failure.
   - Pool stale (fetch timestamp aged, or the user asks for a different slice) → re-fetch, and record the filter used plus the timestamp back into the backlog.

3. **Per-issue profiling** (issue characteristics; every signal comes from API fields):

   - **Granularity estimate** — body length / template-section completeness / number of modules touched → rough order of effort.
   - **Type** — bug / feature / doc / dependency upgrade ... categorized with the §filter vocabulary.
   - **Activity** — `updated_at` age / comment signals / traces of maintainer activity.

4. **Collision triple-check** (mandatory before recommending AND before claiming — the pool is only a snapshot):

   - [ ] `state=open`
   - [ ] no assignee
   - [ ] no in-flight linked PR — `gh issue view <N> --json state,assignees,comments` + the issue timeline API for linked PRs. An open linked PR means someone is on it → skip. Closed-unmerged means a predecessor attempt → report to the user to decide whether to take over.

5. **Output.**

   - A graded Top 2-3 recommendation set; each item carries a **"why this fits you"** line: time profile × type preference × module familiarity × collision risk.
   - A **time-box filter**: items whose granularity exceeds the available time are downgraded or excluded.
   - **Present graded results only — never dump the raw list.**
   - Write the candidate pool back to the backlog.

6. **User-brings-their-own-idea** (the upstream face of [USER] no-PR-without-issue): the user arrives with a substantive idea rather than a pooled issue → first draft an issue via Stage 1's search-before-create and get confirmation, then start work.

7. **Claiming — this stage's ONLY approval card.**

   - After the user picks, re-run the collision triple-check.
   - Draft the claim comment ("taking this"-style wording; non-committers cannot self-assign — [ASF] default etiquette).
   - Approval card: posting a public comment as the user in the official repo is a claim commitment that enters the community's view.

### Stage 1 — Issue

1. **Search before create** ([ASF] default etiquette):

   ```
   gh issue list -R <upstream> --state open --search "<keywords>"
   ```

   - Search thoroughly → on a hit, use the existing issue.
   - Only when truly none exists, open a new one: `gh issue create -R <upstream> --title ... --body-file <f>`.
   - GitHub issue forms cannot be filled non-interactively — pass the body content directly ([MECH]).
   - **Creating an issue is a public write → approval card.**

2. **Proposal first — large changes do not go straight to Stage 2.** Architecture-scale / wide-blast-radius / new-public-API changes:

   - Follow the rule pack's §routing to the project's proposal/discussion channel (e.g. a mailing-list [DISCUSS] thread, a FLIP/KPIP-style proposal process, the discussion forum). The channel's form and address are read from §routing; channels marked "unverified" are presented to the user before use.
   - Draft the proposal for user review, then send it (approval card).
   - Only enter Stage 2 after a **green-light signal**: an assignee is set / a maintainer +1 / the proposal is accepted.

3. **Claiming.** If Stage 0.5 step 7 was not exercised, exercise it here (same approval-card path).

4. **Triage.**

   - Pure questions → the pack §routing Q&A channel; do not occupy an issue.
   - Security concerns → the security-vulnerability re-route hard branch; never a public issue.

### Stage 2 — Branch

```
git fetch <upstream> <default-branch>          # read-only, approval-free
git checkout -b <branch-name> <upstream>/<default-branch>
```

- **Base = the rule pack's axis-1 default-branch.** The pack records the double-confirmation source; **never guess** — a wrong base means the PR opens against the wrong branch. Always branch from `<upstream>/<default>` as just fetched — never from a stale local branch.
- **Backport / fix-into-a-maintenance-line scenarios.** The target branch dispatches on the pack's target-branch-backport dimension and axis-2 release-branch-pattern. Pack value unknown → present to the user for adjudication; never cite another repository's precedent.
- **Naming.** Read the pack §misc branch-naming entry. No written convention (unknown) → a short kebab-case descriptive name is enough; invent no ceremony.

### Stage 3 — Local verification

1. **Environment precheck.** Before running anything, compare the local JDK/toolchain against the pack §local matrix. When no available local version matches (e.g. the project needs source 11 while the machine has only 8 and 21 — 8 fails to compile, 21 crashes an old spotless javac internal API):

   - switch to a workable JDK, or
   - degrade to an explicitly reported gap.

   Never silently skip.

2. **Check chain.** Run the rule pack's §pre-commit chain **item by item** — gate commands + the repository-specific checklist, each with its CI-artifact source — locally for real. **Anything not run is a gap item — never mark it green.**

3. **Target-module tests.** Per the change surface, pick the targeted/full commands and profiles from the pack §local. **Local pass = necessary, not sufficient** — the CI matrix dimensions (JDK/OS/engine etc., per the matrix listed in §local) are usually only partially covered locally. "Local pass ≠ CI green."

4. **The fix loop closes inside this stage.** Change code → rerun the check chain → all green (or gaps explicitly reported) → only then Stage 4. Local builds / formatting / tests do not enter the approval gate.

### Stage 4 — Fork staging + CI + self-review

1. **Push = approval gate (this-round package card):**

   ```
   [Approval card · issue #N · this-round package] Commands for approval (verbatim, one per line):
     1) git commit -m "<title — format per pack §title; never hand-write the (#N) suffix>"
     2) git push -u origin <branch>                 <- remote write, confirmed as a separate line
   Risk: 1) local commit (undoable via reset, touches no remote); 2) push to the personal fork (touches no upstream)
   Task id: issue #N
   Attached: file list to commit + diff summary; local gate results already run
   Alternatives: a) commit only, no push   b) show the full diff first   c) run the full gate chain, then re-present
   30 min without approval -> park (changes kept in the worktree, no auto-retry)
   ```

   Approval of this card (or the user's explicit "approve this whole round") = session-scoped authorization covering the multi-step round as listed; a new write in a later round gets a new card. Commit-title details and the evidence-chain card form follow `apache-commit-pr`.

2. **Stage files by explicit path — never `git add -A`, never `git add .`.** When the work branch is based on an upstream base, local gitignore enhancements that were never upstreamed do not take effect, so workspace-private files (plan documents, rule-pack cache) sit untracked inside the add surface.

3. **CI carrier dispatch (axis-5 ci-carrier):**

   - **push-direct** — pushing any branch triggers the full CI.
     - Monitor: `gh run list -R <fork> --branch <branch>`.
     - On failure, drill down: `gh run view <run-id> --log-failed` (add `-j <job-id>` when needed).
     - Fast-gate duration and normal wall clock: read the pack §ci.
     - **Never open an intra-fork PR** under this carrier — it is the wrong track and produces an entity with no CI value that needs manual cleanup.
   - **intra-fork-PR-only** — the only trigger for fork-side CI is an intra-fork PR.
     - Open one with `gh pr create -R <fork> --base <fork default branch> --head <branch>` to trigger it; monitor with `gh pr checks -R <fork>`.
     - **After verification it MUST be closed — never merge it into the fork's default branch** (fork-default divergence permanently breaks ff-only re-sync, [MECH]).
     - Closing that PR is a remote write → approval card.
   - **upstream-pr** — CI runs only after the upstream PR exists.
     - This stage degrades to "staging complete + propose entering Stage 5"; CI interpretation moves later.
     - The five-state framework below is unchanged.
   - Axis value unknown → determine it via the inline mining procedure. Never guess.

4. **CI five-state interpretation report.** One line per job — a four-column table of **job / state / evidence / action** — plus a conclusion row. **No assertion without evidence.**

   - **Real bug** — the failure locates to a module/test touched by this diff → back to the Stage 3 fix loop.
   - **Environment** — infrastructure / network / dependency-fetch failures → watch, or rerun (after approval).
   - **Flaky** — weak determination procedure; downgrade the wording to "suspected flaky → approve a rerun to verify" (a rerun is a write → approval card; may enter an 'approve this whole round' package).
   - **Not run (first-contributor approve-label gate)** — recognize the waiting state → explain the unlock mechanism per the first-contributor approval chain recorded in the pack §ci, and draft the approval-request comment card. **Do not misreport it as a failure and rework.**
   - **Compliance gate (lint / license class)** — **cannot be saved by a rerun** → the code/header must change; back to the §pre-commit check chain.
   - Compare away known baseline noise (expected-red categories recorded in the pack §ci) — do not panic as if it were regression.
   - The conclusion row states: X items yours / Y items not yours / Z items procedural.

5. **Mobile self-review (carrier per ci-carrier).**

   - intra-fork-PR-only → the intra-fork PR (GitHub mobile renders diff/CI/comments — one artifact, three uses: CI verification + mobile self-review + fix-tracking thread).
   - push-direct → the branch diff (`gh pr diff` / compare view / branch diff URL).
   - A user comment on the carrier is first-class user input.

6. **Conditional wake = in-session polling.**

   - On entering this stage, propose in-session polling (~30-minute level) reading run / PR status (read-only).
   - When CI completes or a comment arrives → immediately push a draft for presentation.
   - **Waiting for events has no timeout.**
   - Cross-session scheduled reminders / event wake-ups are not supported (Honest limitations, item 8).

### Stage 5 — Upstream PR (two hard preconditions)

**Two hard preconditions (never create when either is missing):**

- [ ] The user has completed self-review on the Stage-4 carrier AND explicitly approved in the current session.
- [ ] A linked issue exists ([USER] no-PR-without-issue, **zero exemptions** — typo/doc/follow-up all start from an issue; original issue closed → open a new issue or reopen one referencing the original PR).

1. **Duplicate check before opening:**

   ```
   gh pr list -R <upstream> --state open --search "<topic words>"
   git log --oneline -20 <upstream>/<default-branch> -- <path>
   ```

   Plus a final recheck of the issue's state: fixed or closed by someone else → present for re-discussion; do not force the PR open.

2. **Automated assembly (everything cross-checked against the rule pack):**

   - **Title** — per the pack §title. **Never hand-write the `(#N)` suffix**: what squash auto-appends is the PR number ([MECH]).
   - **Structured gate** — at presentation you MUST **restate the title format used and its source**: "title format <format>, source: rule pack title section, original artifact <artifact>". It self-certifies that the rule source was read. No restatement, no creation.
   - **Body** — assemble section-by-section per the pack §template checklist.
   - **Issue linkage** — per axis-4 issue-link-channel; the common form is a `close #N` keyword in the body. Only closing keywords in the body auto-close the issue; a number in the title is not parsed by GitHub ([MECH]).
   - **AI disclosure** — [USER]: attach `Assisted-by: <model-name:version>` to the body voluntarily — never a co-author line. If the pack §template records an AI section in the project template, fill that section; otherwise attach voluntarily.
   - **Evidence checklist** — per the pack's evidence-types dimension (benchmark / license / checklist / ai-trailer etc., per the change surface).
   - **base** = axis-1 default-branch; **head** = `<owner>:<branch>`.
   - **Umbrella tasks** — attach per the pack's issue-pr-relation dimension (e.g. a body line `Main Issue: #N`, and the closing does not auto-close the parent issue).

3. **Creation = approval gate.** Approval card:

   ```
   gh pr create -R <upstream> --base <default-branch> --head <owner>:<branch> --title ... --body-file <f>
   ```

   - Risk = submitting a public PR to the official repository and entering community review view.
   - Present the title-format source + the full body with the card.
   - At least 2 alternatives.
   - 30 min without approval → park.

4. **First-contributor approve-label gate prompt.** PR checks show waiting / not-run → interpret it per the pack §ci first-contributor approval chain and prompt the user (draft the approval-request comment card); do not treat it as a failure.

5. The full execution details of PR-template compliance self-check (evidence-chain card / contraband interception / adversarial self-review) follow `apache-commit-pr`.

### Stage 6 — Review iteration

1. **Fetch and present.**

   ```
   gh pr view <N> -R <upstream> --comments
   gh api repos/<upstream>/pulls/<N>/comments
   ```

   Both read-only. Present comments as a **numbered list** (#1, #2, ...: author / location / gist, one line each). Remote itemized instructions ("items 2 and 3 — fix and push") rely on this format to dereference the numbers.

2. **Three-way handling** (classify item-by-item, then execute in groups; **no comment is published without the user reviewing it**):

   - **Agree, fix** — fix → §pre-commit gates → **commit+push this-round package card** (same template as Stage 4; title per §title).
   - **Push back with evidence** — draft the reply (technical, non-defensive) → user review → comment approval card (public replies are reputation assets).
   - **Ask** — draft a clarifying question, same comment-approval-card path.

3. **Update style.** Dispatch on the pack's pr-update-style dimension (rebase / merge / push-only — the project-discipline value must come from this repository's own evidence).

   - On rebase/merge conflicts: present hunk-by-hunk with upstream log/blame context + graded proposals. **Never silently pick a side.**
   - A maintainer has edited the PR directly → fetch-sync, then present the diff.

4. **Scope boundary.** Review comments implying a scope expansion → go back to the issue layer to align (update the issue comment / scope); act only after the new scope is confirmed. Never expand unilaterally (same origin as contraband interception; details in `apache-commit-pr`).

5. **Ping timing.**

   - Stalled 1-2 weeks → **polite in-thread ping, never a DM**.
   - Before pinging, **check the release cadence** — stalls during a release window or vote freeze are a high-frequency external cause (proxy data source = pack §misc release-branch-activity); do not misread them as being ignored.
   - New-public-API waiting periods get the same judgment (waiting-period records in pack §ci / §misc).
   - Stale-risk thresholds: read the pack §misc (stale-days configuration).

6. **"Approve this whole round", conversationally.** An itemized user instruction = session-scoped range authorization:

   - This round's commit+push+specified comments are covered at once, with no per-card approval (every step logged in the task log).
   - **Remote writes never enter permanent approval-free status.**
   - A new write in a later round gets a new card.

7. Propose in-session polling as in Stage 4 (new comment arrives → immediately push a draft for presentation).

### Stage 7 — Close-out and keep-or-withdraw

1. **Merge close-out.**

   - Verify the merge result (squash semantics: the PR title/body become the commit message, [MECH]; merge-button state per pack axis-3).
   - **Delete the branch**: `git branch -d <branch>` (local git write) + `git push origin --delete <branch>` (remote write) — **packaged on one card, with the remote write confirmed as a separate line**.
   - Archive in the backlog (state machine advances to "merged").
   - Hand off to Stage 0.5 to recommend the next task (closed loop).
   - Under the intra-fork-PR-only form, additionally close the residual intra-fork PR.

2. **Keep-or-withdraw rules** (position each PR individually; recommend presenting the decision to the user; both keep and withdraw actions go through approval cards):

   - **Active** (unanswered comments / pending CI) → an action item, not a keep-or-withdraw case.
   - **2-3 pings without response** → graceful-exit options: mention a different reviewer / move to the pack §routing discussion channel / close with thanks.
   - **Directional veto** → respect the decision + distill the lesson into a rule-pack Layer-P proposal: diff preview + source labeled "user correction / decision archaeology <date>" + approved persistence into §manual-research (if declined, change only this once).
   - **Issue closed as wontfix / closed by a bot** → stop investing (distinct from "sniped" — tell the user per the presentation template) and wind the PR down accordingly.
   - **Self-solved / fixed externally** → draft the issue-close explanation and leave it for future searchers.

3. **Graceful abandonment** (the user's "not doing this one for now"):

   - **Releasing the claim comment is mandatory** — the symmetric fulfillment of "taking this"; disappearing without notice leaves a dead claim, which is bad form.
   - Clean up local / remote branches (deleting the remote = approval card).
   - Mark the backlog entry re-pickable.
   - Under the intra-fork-PR-only form, additionally close the intra-fork PR.

### Security-vulnerability re-route (global hard branch — hit at any stage, abort the PR flow)

- **Detection.** Vulnerability semantics appear in the change or the investigation (RCE / auth bypass / sensitive-information disclosure / injection class) → trigger immediately, regardless of progress.
- **Abort.** Create no issue, open no PR, and put no vulnerability details or reproduction steps in any public comment or PR body. Existing public carriers must not contain vulnerability details; present the handling to the user.
- **Re-route.** Private channel: read the pack §routing security entry. If the pack is missing or the entry is marked unverified → infer the ASF default private channel, **mark it "unverified", and present it to the user before use** (a wrong address means a lost vulnerability report — asymmetric risk).
- After the re-route, follow the project's security process (embargo / coordinated disclosure). Any seven-stage paragraph that conflicts with this branch is declared inapplicable.

## State and cross-session continuity

1. **Three-source rebuild** (do this first when resuming or taking inventory; **report before acting**):

   - [ ] **Git scene** — branches / worktree / remote layout after `git fetch <upstream> --prune`.
   - [ ] **Fork-side entities** — intra-fork PRs, branches, run states (present per the ci-carrier form), plus upstream PR readings via gh read-only.
   - [ ] **Task log** — the `docs/tasks/backlog.md` state machine: candidate → claimed → developing → fork-review → upstream-PR → merged (+ abandoned / externally closed); complex tasks add `docs/tasks/<issue>-<slug>.md` per-task checklists.

   Cross-validate the three sources; annotate whatever is stale — **never assert unfetched state**.

2. **Continuation discipline.**

   - Three-line report: where you are / what is done / what is next.
   - Environment recheck: re-walk Step 0 + fetch to prevent drift.
   - Only then act.
   - **Never rerun work another session already completed.**
   - Leave no half-approved state behind — an interruption means archiving it into the task log.

3. **Cross-repo switch.** Explicitly confirm the target repo → re-walk Step 0 to load that repo's rule pack. Packs are keyed per repository — **never apply repo A's rules to repo B**. A cross-repo phrasing of "my PRs" = walk each repo separately.

4. **Multi-PR dashboard.** Organize `gh pr status` (current-repo context) / `gh pr list --author <me> -R <repo>` into one table: repo / PR# / branch / stage / CI / unanswered reviews / stale risk / action needed. Highlight the action-needed rows; keep-or-withdraw positioning follows the Stage 7 rules.

5. **Task-log discipline.** Write back at every stage transition, immediately (same discipline as a design-doc changelog). The scope and execution trail of any "approve this whole round" authorization are recorded here too.

## Hard guardrails (standard text, uniform across repositories)

Disaster-level rules are backstopped in layers: the rule pack's §guardrails top section → the structured gate (Stage 5 approval restates the title format and its source) → the repo-local AGENTS.md pointer, if present → approval gating as the final backstop.

- NEVER push to the official Apache remote (`github.com/apache/<project>`, whatever it is named). PRs only — the personal fork is the only staging area.
- NEVER open an upstream PR without a linked issue (user rule, zero exceptions — typo/doc/follow-up all start from an issue; if the original issue is closed, open a new/reopened issue referencing the original PR). The linkage channel dispatches on the rule pack axis.
- NEVER hand-write the `(#N)` title suffix — what GitHub squash auto-appends is the PR number.
- NEVER force-push a shared branch (force-pushing your own coordinated PR branch is acceptable).
- NEVER commit credentials, IDE files, build artifacts, logs, or other private artifacts; new files carry the Apache-2.0 header ([ASF], ALv2).
- NO git/gh write operation without explicit approval in the current session (approval card, five elements; "approve this whole round" is the session-scoped pressure valve — remote writes never become permanently approval-free).
- Security vulnerabilities never go through a public issue/PR — re-route to the private channel (see the security-vulnerability re-route hard branch).

## Honest limitations (residual risks, all accepted)

> Text source: these eight items are inlined from the shared honest-limitations text (single copy-source to prevent drift between the sibling skills; the 8-item version was synced 2026-10-14). The section sits directly after the guardrails section.

This suite depends on probabilistic triggering and local file reads; the following residual risks are known and accepted by the user (2026-10-13):

1. **Triggering is probabilistic.** The skill has no deterministic invocation as the main path (explicit `/apache-*` slash calls exist only as a fallback escape hatch); the description is designed per official guidance, but no natural-language trigger can be guaranteed to hit.
2. **The rule pack can be bypassed by non-target paths.** When an ordinary session does not trigger this skill but happens to run a commit/PR anyway, the rule pack is not read and no compliance self-check happens; approval gating is the final backstop (every push/PR still needs explicit approval, and bypassed results still reach the user as a proposal).
3. **kyuubi has no controllable AGENTS.md resident channel.** Its AGENTS.md is a tracked upstream asset that cannot be modified, so this suite's disaster guardrails cannot be injected into that resident channel. When its existing name-based remote-identification rule conflicts with the skill's URL-based identification, present it to the user; never silently pick a side. That repository's guardrails ride on three layers: the rule pack's top section + the structured gate + approval gating.
4. **A stale Layer G can mislead a skimmer.** The conflict adjudication order is [USER] policy > Layer P facts > skill body > Layer G snapshot — the body is always authoritative; but a session that reads only Layer G without the body may pick up an outdated generic-rule snapshot.
5. **Title drift on soft-convention repos has only the 90-day time backstop.** In a repository with no title-lint workflow and no merge-rewrite script, community title-convention drift causes no CI-artifact change, so the cache's event trigger never fires; only the `verified` > 90-day time trigger re-mines.
6. **Fresh-clone coexistence across machines leaves deferral residue.** When this machine hosts no old project-level skill, the Step 0 item-0 deferral check has nothing to defer to; during that window, approval gating is the backstop (every remote write still needs explicit approval).
7. **A desktop app being online is the precondition for remote command/approval capability.** The Bot Channel is the desktop ZCode session's remote interface, not an independent mobile execution environment (the executor is always the desktop session). When the desktop session sleeps or exits, phone-side commands (approvals included) cannot be processed — an environment fact; no wake-up design is attempted.
8. **Cross-session scheduled reminders / event wake-ups are not supported.** Cron-style polling (in-session reminders for CI completion, new review comments, etc.) works only while the session lives and dies with it; cross-session scheduled reminders have no carrier and need the user to start a new session (adjudicated 2026-10-13).

All of the above are residual risks explicitly recorded and accepted by the plan and the 2026-10-13 vote; they are not to be designed away further.

## Inline mining procedure (shared engine for first collection / new-repo bootstrap / invalidation re-mine; self-contained here, dual-carried with apache-commit-pr)

**Cache semantics — three Layer-P properties:**

- **Non-mandatory.** A missing cache is a normal state, not an error (new-repo onboarding, first execution, fresh clone, cleanup). Work proceeds without it, and the correct behavior on a miss is to mine online on the spot (this procedure: read-only, minutes-level), not to refuse the task or guess rules.
- **Non-static.** Invalidation re-mines on dual triggers — time (`verified` > 90 days) + event (CI artifacts changed). No manual maintenance.
- **Enhancing when present.** A hit is used directly with no re-collection; operations are precise to the project's real gates, and professionalism = every entry traceable to a source artifact.

**Inputs (all read-only, approval-free):**

- `.github/workflows/*` — triggers / jobs / step commands / matrix / permissions / secrets dependencies.
- `.github/actions/*` composite actions — they often hide gate implementations such as spotless or license checks; reading only `workflows/*.yml` misses them.
- CI script directories — the usual `tools/`, `dev/`, `build/`, etc.
- lint/format configs — spotless / checkstyle / `.licenserc.yaml` / scalafmt / pre-commit hooks, etc.
- `.asf.yaml` — merge buttons + protected branches + notifications.
- PR/issue templates — `.github/PULL_REQUEST_TEMPLATE*`, `.github/ISSUE_TEMPLATE/*`; labeler / dependabot / renovate configs.
- CONTRIBUTING / contribution docs.
- The project website's contribute / subscribe / security pages — the strongest written evidence for community etiquette and the security channel; more authoritative than PR specimens.
- git sampling: `git log --oneline -100 <upstream>/<default>` for title shapes.
- PR specimens: ~20 open + ~20 merged PR titles (anonymous API works).

**Anonymous-API rate limits.** The search endpoint allows 10 requests/minute and may return an empty body instead of a JSON error on failure. For label/issue counts, prefer REST endpoints with fully URL-encoded queries and a retry interval of at least 7 seconds.

**CI-artifact direct-read iron rule.** A local clone may be thousands of commits behind upstream. Reading CI artifacts (e.g. `backend.yml`) must go against the upstream latest reference — `git show <upstream>/<branch>:<path>` — and record the base SHA; otherwise the matrix/trigger surface gets recorded as stale facts.

**Three-step mechanical derivation** (covers the large majority of axes; the method is field-validated by sampling across multiple ASF repositories):

1. `.asf.yaml` + workflow triggers → merge-governance / default-branch / ci-carrier / `(#N)` semantics / release-branch-pattern.
2. Templates + PR specimens → issue-link-channel / template-section checklist / presence of an AI-disclosure section.
3. CI steps + scripts + lint configs → gate checklist / local test commands / label filter vocabulary.

**PR specimen method (API endpoints stated).** Pull `pulls?state=closed&per_page=N`, then filter `merged_at != null` (closed ≠ merged). Open specimens are necessary only when merge-governance = soft-convention; under ci-lint, open titles are force-compliant too, so they contribute zero evidence.

**Derivation mapping:**

- Workflow triggers → ci-carrier axis + fork runnability (secrets-dependency analysis).
- Locally pre-runnable commands among the CI steps → gate checklist.
- Title-lint workflow → title-governance state + title rules.
- Test matrix (JDK/OS/engine profiles) → local reproduction commands + the "local pass ≠ CI green" hint (list the matrix dimensions).
- PR/issue templates → template sections and filter-surface inputs.
- `.asf.yaml` → branch-protection axis.
- Labeler path mappings → label filter vocabulary. **The vocabulary must come from this repository's first-hand list; cross-repo inheritance is forbidden.**
- Check names inside `.asf.yaml` protected-branch `contexts` (e.g. "Title Validator") → trace back through `workflows/` and `.github/*bot*.yml` bot configs to locate the gate implementation. The gate's name and its implementation often live in two different artifacts.

**Evidence-strength ordering.** A written rule in the contribution docs beats PR/commit specimen statistics — for fields like the issue channel, the docs often supply two-thirds of the evidence on their own.

**Timing-type fields** (fast-gate duration / matrix size): may inherit the last `verified` value, marked `[inherited]` — no forced re-measurement (re-measuring needs run-specimen sampling, beyond the regular input surface).

**Vestigial / unmaintained configs** (bot-config typos, regex mismatches): record them in manual-research with a "do not rely" note; never use them as a derivation basis.

**Output persistence (after approval) — rule-pack structure** (schema-version 1; the full master lives at `~/.zcode/skills/apache-dev-workflow/templates/rule-pack-template.md`; when the master is missing, persist per this skeleton):

- Header: `schema-version: 1` / `kernel-version:` (= this document's current Changelog version) / `verified: <today>` (the pack-level invalidation criterion).
- **Layer G** (generic rule snapshot, generated read-only, anti-skim redundancy): the g-guardrails + g-kernel sections, mechanically regenerated from the seed template, hand-edits forbidden; may be backfilled later (not mandatory).
- **Layer P** (project cache): the axis-value header (upstream / default-branch / release-branch-pattern / merge-governance / issue-link-channel / ci-carrier / branch-protection / target-branch-backport / pr-update-style / evidence-types / issue-pr-relation) + the sections: **guardrails (project disaster-level guardrails, top)** / title / template / pre-commit / ci / filter / routing / local / misc / manual-research.
- Every Layer-P value carries a one-line source (file/command/API + date). Fields that cannot be mined are recorded as `unknown` plus a note of the sources attempted — **copying another repository's values is forbidden**.

**New-pack extra steps (bootstrap):**

- Mirror the personal master copy (`cp` to `~/.zcode/rules/<project>.md`).
- Confirm `/.zcode/` is gitignored.
- Write the two [USER] norms (no-PR-without-issue + AI disclosure) into every new pack by default, and confirm their applicability with the user once.
- After bootstrap, run a **pollution self-check whose check items are semantic, not tool-named** — e.g. "does the PR-title section show `[Type][Module]` without an issue number", not a grep for a tool name (the target repo's own legitimate use of a same-named tool causes false positives).

**Invalidation re-mine** (time > 90 days, or CI artifacts have git changes since `verified`; run `git fetch <upstream> --prune` before judging):

- Re-mine at pack level; diff "cache ↔ actual CI config"; update on drift.
- **Mining entries update; manual-research entries never do.** Manual-research entries (soft conventions / historical anti-patterns / operational rules — anything not derivable from CI artifacts) live in their own subsection and are **never overwritten by a re-mine**; when in doubt, present to the user.
- **Summary lines marked `[manual]` in the guardrails section must not be deleted by a re-mine** — the disaster-rule dual-write form: guardrails summary + manual-research full record + cross-references.
