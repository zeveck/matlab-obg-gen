# matlab-obg-gen: working on the plugin

matlab-obg-gen is a Claude Code plugin: one skill, `/matlab-obg-gen`, that
designs, reviews, builds, play-tests, proves and submits entries for the
MATLAB One-Button Game Mini Hack.

## Layout

- `skills/` is the plugin root (what Claude Code copies on install):
  `skills/.claude-plugin/plugin.json`, `skills/LICENSE`, and the skill in
  `skills/matlab-obg-gen/`.
- `skills/matlab-obg-gen/SKILL.md` is the pipeline; detail for each phase
  lives in `references/`, read when the skill reaches that phase. Keep
  SKILL.md readable end to end.
- `skills/matlab-obg-gen/tools/`: `check-setup.ps1` (setup check),
  `obgtest.m` / `obgsuite.m` (headless harness mirroring
  `minihackContest.play`), `fetchrules.m` (live contest rules).
- `.claude-plugin/marketplace.json` is the marketplace (one plugin).
- `examples/ninefold/` is the example game with its design, solver,
  recorded solutions and proof. Its test scripts find the skill's tools
  relative to the repo.
- `docs/images/` holds the README's screenshots and GIFs, made by
  `examples/ninefold/design/tests/makeShots.m` (replays the proven run).

## Rules that keep it honest

- **Every level proven beatable** (solver + human-timing player + full-run
  replay, re-run after every change) is the skill's critical rule. Don't
  weaken it.
- Never submit without the person's explicit go-ahead; `--submit` asks.
- MATLAB processes are heavy: check machine load, one batch run at a time,
  and confirm every process you started has exited.
- No machine-specific paths in `skills/` (the tests check). Inside the
  skill, `SKILL_DIR` / `${CLAUDE_SKILL_DIR}` is the skill's folder.

## Versions

`plugin.json` uses date versions (`YYYY.MM.DD.N`). Bump it with every
change to `skills/`, and add a line to `CHANGELOG.md`.

## Tests

`node --test` checks the manifests, the skill's frontmatter, that every
file SKILL.md names exists, and that `skills/` has no machine paths.
Testing the skill itself means running it: make a game with it.
