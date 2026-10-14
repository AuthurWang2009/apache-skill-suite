# apache-skill-suite

A suite of Apache-Software-Foundation-style contribution skills for AI
coding agents. One install, three skills, any Apache repository: the
skills encode Apache contribution norms once, and every repository's own
facts (title formats, default branches, CI gates, mailing lists) are
loaded from a per-repository rule pack or mined on the spot.

Deployable to **ZCode**, **Claude Code**, and **Kimi Code**.

[中文说明](README.zh-CN.md)

## The three skills

| Skill | Responsibility |
|---|---|
| `apache-commit-pr` | Commit / PR-time conventions: upstream identification, title and PR-template frameworks, gate checks, CI triage, ASF compliance self-check, hard guardrails (no PR without an issue, approval gating on every git/gh write, AI disclosure, never push the official remote) |
| `apache-dev-workflow` | End-to-end contribution orchestration: backlog and issue selection with profile matching → branch → local verification → fork-side CI → upstream PR → review iteration → merge/withdraw decisions |
| `apache-sync-fork` | fork ↔ upstream branch synchronization: read-only four-way diagnosis (MISSING / FORK-ONLY / DIVERGED / STALE), ff-only pushes to the fork, stale-branch cleanup — every remote write behind an explicit approval |

All three read the same per-repo rule pack
(`<repo>/.zcode/rules/<project>.md`, the single source of truth). Skill
bodies contain zero repository-specific rules; on a cache miss the
inlined mining program derives them from the repository's own CI
configs, templates, and git history — never guessing, never borrowing
another repository's rules.

`rules/` ships optional G-layer rule-pack master copies (seatunnel,
dolphinscheduler) installable with `install.sh --with-rules`.

## Install

```bash
git clone git@github.com:AuthurWang2009/apache-skill-suite.git
cd apache-skill-suite

./install.sh                        # auto-detect installed environments (zcode/claude/kimi)
./install.sh --target zcode,claude  # deploy only to the listed environments
./install.sh --symlink              # symlink: the repo stays the single source of truth
./install.sh --with-rules           # also install rule-pack master copies to ~/.zcode/rules/
```

Uninstall: `./uninstall.sh` (removes only what install put in place;
side-car `.bak` backups are preserved).

## Repository layout

```
skills/      the three SKILL.md documents (English, superpowers-style format)
rules/       optional rule-pack master copies (G layer)
tests/       cross-environment trigger matrix runner and fixtures
docs/        design notes and recorded test results
```

## Design principles

- **Generic skills, per-repo facts.** Only engine mechanics ([MECH]),
  foundation policy ([ASF]), and owner policy ([USER]) live in skill
  bodies — everything else is derived at runtime and cached in the rule
  pack (mining entries with sources, invalidating after 90 days or on
  CI-artifact change).
- **Approval gating everywhere.** Every git/gh write — including local
  commits — is presented as an approval card with verbatim commands,
  per-item risk, and alternatives, before execution. The official Apache
  remote is never pushed to, identified by URL, never by name.
- **Honest degradation.** Missing rule pack = normal state: mine inline,
  use the results, and ask before caching. Refusal to work is a bug.

## Contributing & license

See [CONTRIBUTING.md](CONTRIBUTING.md) for the commit/PR conventions
(`[Type][Module] Summary`, issue-first workflow) and
[CHANGELOG.md](CHANGELOG.md) for history.

Licensed under the [Apache License 2.0](LICENSE).
Copyright 2026 The apache-skill-suite Authors.
