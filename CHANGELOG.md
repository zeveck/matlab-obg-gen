# Changelog

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
