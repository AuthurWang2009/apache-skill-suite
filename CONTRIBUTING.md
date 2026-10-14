# Contributing to apache-skill-suite

Thanks for your interest in improving this skill suite. This project follows
Apache-style contribution conventions, adapted to a personal open-source
repository (not hosted by the Apache Software Foundation).

## License

By contributing, you agree that your contributions are licensed under the
[Apache License 2.0](LICENSE). Add the standard ALv2 header to every new
script or source file (see any existing script for the exact form).

## Workflow

1. **Issue first.** Every pull request references an issue. If none exists,
   open one describing the problem or proposal before you start work.
2. **Fork & branch.** Branch from `main` on your fork, naming the branch
   `fix/<slug>`, `feature/<slug>`, `docs/<slug>`, or similar.
3. **Keep changes focused.** One concern per PR; unrelated drive-by edits go
   into their own issue + PR.
4. **Local checks.** `shellcheck` the scripts you touched and run the
   frontmatter validation in CI locally if you can.
5. **Open the PR against `main`**, fill the description with motivation and
   test evidence, and link the issue with a closing keyword in the PR body.

## Commit message convention

Format:

```
[Type][Module] Summary in English, imperative mood, <= 72 chars

Optional body wrapping at 72 columns explaining motivation,
trade-offs, and test evidence. No issue number suffix —
GitHub appends "(#N)" automatically on squash merge.
```

Types: `Feature` · `Fix` · `Improve` · `Test` · `Doc` · `CI` · `Chore`

Modules (pick the closest; omit when genuinely cross-cutting):
`Skills` · `Install` · `Tests` · `Rules` · `Doc` · `CI`

Examples:

```
[Fix][Install] Install kimi skills to ~/.kimi-code/skills (not legacy path)
[Test] Record cross-env B4 trigger matrix results and fix kill_tree watchdog
[Doc] Add LICENSE, ALv2 headers, CONTRIBUTING, and CHANGELOG
```

Rules:

- Never hand-write a `(#N)` suffix — the squash-merge adds it.
- The PR title becomes the final commit message on squash merge; keep
  commits and PR titles consistent.
- Historical commits in this repository were rewritten once (2026-10-14) to
  this convention; see CHANGELOG for the mapping era.

## Skill document guidelines

- `skills/<name>/SKILL.md` contains only operator-facing, actionable
  content. Test narratives, dated revision notes, and history belong in
  `CHANGELOG.md` or `docs/results/`, not in the skill body.
- Frontmatter `description` must stay under **1024 characters** with the
  trigger conditions front-loaded in the first ~250 (hosts truncate and
  drop over-long skills). CI enforces this.
- Skill bodies are written in English; keep the rule-pack schema terms
  (`§filter`, `§local`, Step 0, `[USER]/[ASF]/[MECH]`) stable across edits.

## Reporting security issues

Do not open public issues for security-sensitive problems. Contact the
maintainer privately first.
