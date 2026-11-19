# Changelog

## 2026.11.19.1

Lessons from building a 100-floor game ("Floor It") with the skill.

- Proofs are harder to pass by accident (#1): `prove.m` is a function that
  reads its level list from the game; a level cleared with no input fails;
  each game keeps its own copy of the tools in `design/tests/tools/`
  instead of naming the versioned plugin folder. Reviewers write
  `review_*.m` (MATLAB can't run hyphenated names). `obgsuite` no longer
  needs an output folder. The Ninefold example's proof scripts are now
  functions and reject empty solutions.
- Character budget (#2): over budget, cut in a fixed order (lossless
  compaction first, visual flair last, never anything a check relies on);
  a compaction pass before handover, and the report says how many
  characters are free. `--change` proposes first when a change touches the
  core mechanic, needs visible cuts or won't fit.
- Design and polish (#4): the design names the skill the player uses and
  nothing may do it for them; choices must be judgeable by eye; the polish
  check includes "losing reads as losing"; reports use the names the
  person sees.
- Endless content is allowed when it's playable by construction (#5): a
  rule that keeps a way forward, a deep multi-seed check, no way to get
  stuck, and difficulty that levels off.

## 2026.11.13.4

- The skill's own instructions now describe making one-button MATLAB games
  in the Mini Hack's format; sharing in its gallery is optional.
  `contest.md` is now `format.md`, the "Contest judge" reviewer is "Fresh
  eyes", and the Tips & Tricks draft is a "how it was made" write-up
  (`design/WRITEUP.md`).

## 2026.11.13.3

- Friendlier, more general wording: a plugin for making one-button MATLAB
  games, inspired by and following the format of the Mini Hack; sharing to
  its gallery is optional.

## 2026.11.13.2

- `--submit` records the entry's Play Game link (MATLAB Drive) and puts it,
  with the entry link, at the top of the game's README.

## 2026.11.13.1

First release.

- `/matlab-obg-gen <idea>`: brief, design, one round of design review
  (player, MATLAB builder, contest judge), build in stages under the
  10,000-character limit, headless play-testing, final review, polish pass,
  README and a draft Tips & Tricks post.
- Every level proven beatable: recorded solutions, a human-timing player,
  and a full-run replay through the contest harness; `prove.m` per game.
- `--submit`: gates on the proof, validation, the play-test suite and the
  preview, then asks for a title and go-ahead, submits, records the URL and
  refreshes the Tips & Tricks draft.
- Setup check and guided setup: MATLAB (including a no-admin install and a
  path repair), the MATLAB Agentic Toolkit and MCP server, the contest
  starter project and toolkit, and machine headroom.
- `ideas`, `--change`, `--continue`, `--plan-only`, `setup`, `help`.
- Example game: Ninefold.
