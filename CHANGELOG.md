# Changelog

All notable changes to this project are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/); the project
follows Apache-style `[Type][Module] Summary` commits (see CONTRIBUTING).

## [0.2.0] — 2026-10-14

### Added
- LICENSE (Apache License 2.0), ALv2 headers on all scripts, CONTRIBUTING
  with the commit/PR conventions, English README (Chinese moved to
  README.zh-CN.md), and this CHANGELOG.
- CI workflow: `shellcheck` on all shell scripts plus skill-frontmatter
  validation (`name` present, `description` ≤ 1024 chars with trigger
  conditions front-loaded) — turns the over-long-description failure mode
  discovered in the field into a hard gate.
- Layered validation results for the ZCode host (discovery / trigger
  simulation / dual-host live matrix) under `docs/results/`.

### Changed
- Skill documents restructured into English with the superpowers-style
  format: purpose-first sections, imperative instructions, checklists for
  gates. The trigger surface (frontmatter) is unchanged.
- Behavioral fixes observed during field testing are folded into the
  skill bodies where they apply; their historical narratives moved here:
  - Stage files by explicit path, never `git add -A` — local uncommitted
    gitignore enhancements do not protect the add surface on branches
    based on an upstream ref.
  - Environment precheck before the local verification chain (JDK /
    toolchain vs the rule pack's CI matrix; switch or degrade to a
    reported gap, never silently skip).
  - CI-artifact mining must read files at their pinned upstream ref and
    record the base SHA — a stale local clone produced an outdated
    Java matrix (8/11 vs the real 11/17).
  - Lazy mining: for format-insensitive local-only commits, a missing
    rule pack may be mined later (before push/PR) but must be announced.
  - Backlog preference section: unknown placeholders when the
    conversation yields nothing; ask, don't block.
  - Approval-card task ids may be non-issue identifiers (ops / dry runs).

## [0.1.0] — 2026-10-14

### Added
- Initial import of the three skills (`apache-commit-pr`,
  `apache-dev-workflow`, `apache-sync-fork`) with the rule-pack
  architecture: repo facts live in per-project rule packs
  (`.zcode/rules/<project>.md`), skill bodies stay repo-agnostic.
- `install.sh` / `uninstall.sh` for ZCode, Claude Code, and Kimi Code
  environments, with side-car `.bak` backups preserved on replace
  (mktemp staging dir).
- G-layer rule-pack master copies for seatunnel and dolphinscheduler
  under `rules/` (optional `--with-rules` install).
- Cross-environment trigger matrix runner (`tests/run-trigger-matrix.sh`)
  with a portable macOS timeout watchdog, self-contained fixtures, and
  recorded results (claude 7/7 PASS, kimi 6 PASS + 1 PARTIAL in
  auto-mode, ZCode discovery-verified).
