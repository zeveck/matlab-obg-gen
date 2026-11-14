---
name: matlab-obg-gen
description: >-
  Make a complete, polished entry for the MATLAB One-Button Game Mini Hack from
  a description. Writes a brief and design, has review agents vet it against
  the contest's rules and judging criteria, builds game.m in milestones,
  play-tests it headlessly in MATLAB with scripted taps and bots, runs
  playability and polish passes, drafts the Tips & Tricks post, and reports
  when it's ready to try. Checks and helps install MATLAB, the MATLAB MCP
  connection and the contest tools first. Also brainstorms concepts, changes
  existing games, and submits a finished game to the contest.
argument-hint: "<game idea> [--rounds 1-3] [--plan-only] | ideas [n] [theme] | --change <slug> <what> | --continue [slug] | --submit [slug] | setup | help"
---

# /matlab-obg-gen — make a One-Button Game Mini Hack entry

You are making a real, finished contest entry: one `game.m` that a stranger
clicks on in the MATLAB Central gallery, understands in five seconds, and
plays again. The person described the game (a sentence or a page) and walked
away; they come back to a game they can play right now and a short report.

Every specific thing they asked for belongs in the game; fill gaps with
choices in the same spirit. Loose ideas ("maybe", "or something") are
invitations: use them or something better that serves the same purpose, and
say which in the design. Work autonomously; only ask if the request is
unusable. Ask in plain words as the last line and end your turn.

Five rules beat everything else:

1. **Never call it done without playing it.** Every screen and every state
   transition is exercised by the headless harness (and the person's live
   window when MCP is connected) before you report success.
2. **Every level must be PROVEN fully beatable. This is critical.** For each
   level (or stage, wave or puzzle) there is a recorded input timeline in
   `design/solutions/` that clears it completely (no lost pieces, no partial
   credit) when replayed through the real harness, and the play-test replays
   all of them after every change. A bot that "gets far" is not proof. If
   levels are generated, ship only a finite set of seeds that a solver has
   cleared. Never ship endless levels that can't all be verified. If a level
   can't be proven beatable, fix it or cut it, and say so.
3. **The contest rules are hard gates.** `minihackContest.validate` must
   print `Validation passed.` with the live rules (not `SKIPPED`). Over the
   character cap or one banned call means the entry is rejected.
4. **One button, taps only.** `pressed` is a one-frame edge. There is no hold,
   no release, no position. Every mechanic is built from *when* and *how
   often* the player taps.
5. **Original work only.** Genres and mechanics are fine; never recreate a
   specific existing game's name, characters, look or levels.

**Keep the person posted:** one short plain line after each phase, about
their game, not about phases or agents.

Read each reference file when you reach its phase:

- `references/contest.md` — the contract, rules, judging, quirks. **Read at
  preflight, always.**
- `references/matlab-craft.md` — how to make MATLAB graphics look great and
  run fast inside 10,000 characters.
- `references/design-template.md` — Phase 2.
- `references/review-roles.md` — Phases 3, 6, 7.
- `references/playtest.md` — Phases 4 and 5: the harness, bots, checks.
- `references/tips-post.md` — Phase 8 and `--submit`.
- `references/setup.md` — when the setup check finds anything missing.

`SKILL_DIR` below means this skill's folder, `${CLAUDE_SKILL_DIR}`

## Modes

- **`help`** — explain the modes and flags in a few lines, then stop.
- **`ideas [n] [theme]`** — pitch n (default 5) distinct one-button concepts:
  for each, a name, the hook in one line, the tap mechanic, why it uses the
  one-button limit cleverly, what the preview GIF would show, and a rough
  character risk (low/med/high). Favour variety (timing, rhythm, toggling,
  counting, risk/reward, physics, puzzle). Write them to
  `games/IDEAS.md` (append; dated) and stop. No building.
- **`<idea>`** — make a new game (the phases below).
- **`--plan-only`** — stop after the reviewed design.
- **`--continue [slug]`** — resume an unfinished game from its
  `design/STATUS.md` (most recently changed game if no slug).
- **`--change <slug> <what>`** — change a finished game: append the request
  to STATUS.md, update the design if the change is about design, rebuild,
  and re-run Phase 5 in full (every check, not just the changed part) and
  the bug-hunter review, then report.
- **`--rounds n`** — design review rounds, 1-3 (default 1).
- **`setup`** — only run the setup check and fix what's missing (Preflight
  step 0), then stop.
- **`--submit [slug]`** — submit a finished game to the contest (see
  "Submitting" below). Most recently changed game if no slug.

## Layout

Each game lives in its own folder: `games/<slug>/` (short kebab-case name).

```
games/<slug>/
  game.m              the entry (must be named game.m)
  README.md           how to play, what's in it
  design/
    STATUS.md         requests (verbatim), settings, phase checklist, notes
    BRIEF.md
    GAME_DESIGN.md
    REVIEW_LOG.md
    TIPS_POST.md      draft Tips & Tricks post
    tests/            harness scripts (.m) and bot policies
    shots/            screenshots and GIFs from the harness
```

Never overwrite another game's folder. The project root `game.m` is the
starter stub; leave it alone unless the person asks.

## Preflight

0. **Setup check (every mode except `help` and `ideas`).** Run
   `SKILL_DIR/tools/check-setup.ps1 -Project <project folder>` (PowerShell;
   on macOS/Linux check the same items by hand, per `references/setup.md`).
   It reports MATLAB (R2021a+, and a broken-path warning), the MATLAB MCP
   server, the Agentic Toolkit, the contest toolkit, the starter project
   and free RAM. For anything MISSING, follow `references/setup.md`: do
   what you can yourself (installing MATLAB with mpm into a user folder,
   repairing the path, installing and configuring the Agentic Toolkit,
   opening the project) and walk the person through what needs them
   (MathWorks sign-in and activation, downloading the starter project,
   restarting Claude Code). Tell them plainly what's missing and why in one
   short list first. If a restart of Claude Code is needed, say what to
   type when they're back, and stop. Don't start game work on a broken
   setup; the batch fallback is fine if only the MCP connection is missing
   and they'd rather not restart.
1. **Agents.** The reviews need the Agent tool. If you don't have it, say so:
   "Please run `/matlab-obg-gen` directly in the main chat."
2. **MATLAB.** Prefer the MATLAB MCP server (tools like `evaluate_matlab_code`,
   `check_matlab_code`). If it's not connected, use the batch fallback in
   `references/playtest.md` (`matlab -batch`, ~40 s per call, so batch work
   into few calls). Say once in your first update which one you're using.
3. **Toolkit and rules.** In MATLAB, check
   `~isempty(which('minihackContest.validate'))`. If false, open the project
   (`openProject('<project>/minihackContest.prj')`), which installs it. Then
   run `SKILL_DIR/tools/fetchrules.m` and compare with
   `references/contest.md`; if the live list differs, trust the live list and
   note the difference in STATUS.md.
4. **Start `design/STATUS.md`:** heading with the working name, the request
   verbatim, settings, and a checklist of the phases. Keep it current; it's
   what `--continue` reads.

## Phase 1 — Brief

`design/BRIEF.md`, one page: the game in one sentence and the feeling it
should give; **what they asked for** as a checklist in their words (mark the
loose ones); who plays it (a gallery visitor with 2 minutes and no
instructions); the one-button idea in a sentence; decisions you made for
them.

## Phase 2 — Design

`design/GAME_DESIGN.md` from `references/design-template.md`. The parts that
matter most here: the tap mechanic and why it's clever, the first 5 seconds
(it's the preview GIF and the gallery thumbnail), the difficulty curve over a
2-3 minute run, the state machine, the feedback (every tap visibly answers at
once; scoring gets a small celebration), the character budget, the finite
level list and how each will be proven beatable, and a title screen that
explains the game in a few lines.

Scope is always "small": one strong idea done very well. Depth comes from
the curve and the polish, not from more modes.

## Phase 3 — Design review

One round by default (`--rounds` for more). A second round only if the
first found a must-fix that changed the design substantially. Each round:

1. **Review, in parallel**: dispatch the **Player**, **MATLAB builder** and
   **Contest judge** agents at once (roles in `references/review-roles.md`),
   each with the brief, the design, and `references/contest.md`. Builder also
   gets `references/matlab-craft.md`. Don't show one another's findings.
   Design reviewers read; they never run MATLAB.
2. **Refine** yourself: you're the builder and know the character budget.
   Check each factual claim, fix the design or say why not, and keep the
   design consistent. Use a separate **Refiner** agent only when the
   findings conflict with each other or you've already written code you'd
   be tempted to defend.
3. **Record** every finding and what you did with it in
   `design/REVIEW_LOG.md`, and say in your update that you refined it
   yourself (or with the Refiner).

Then re-read the design as the person who asked: is every checklist item in?

With `--plan-only`, stop: report the pitch, how it plays, how it looks, and
tell them `/matlab-obg-gen --continue <slug>` builds it.

## Phase 4 — Build

Write `game.m` in milestones. After **each** milestone: static check
(`check_matlab_code` or `checkcode`), `minihackContest.validate(<path>)`,
and a harness run (`references/playtest.md`). Fix before moving on. Track
the character count (comments excluded) in STATUS.md after each milestone.
**Measure the count at milestone 1 and project the total**: the counted
size is ~1.5x what it looks like (see matlab-craft.md). If the projection
is over ~9,000, simplify the design now, before building more.

1. **Playable core.** The tap mechanic with plain shapes: act, score, fail.
   Run the bots. If it isn't fun yet (read the traces: are there decisions?
   is timing meaningful?), fix the feel now.
2. **The whole loop.** Attract/title state that animates by itself and says
   how to play in a few words, play, game over with score and the session's
   best, tap to restart (with a short lockout so a death-tap doesn't skip the
   game-over screen). Nothing can get stuck.
3. **Content and curve.** Everything in the design's structure: the ramp,
   the twists, the variety over a run.
4. **Look.** The art direction: palette, background, shapes, text styling.
5. **Feedback.** Make sure every tap answers visibly on the same tick and
   scoring has a small celebration (e.g. a particle burst), with whatever
   characters are left. Extra effects come last and go first.

Keep the source readable: short helper functions, sensible names, few
comments (comments are free but keep them useful). Judges read the code.

## Phase 5 — Play-test

**First, prove every level beatable** ("Prove every level can be beaten"
in `references/playtest.md`): a solver finds a complete solution for each
level, saved in `design/solutions/`, and replaying each one through the
harness clears its level fully. Then follow the rest of
`references/playtest.md` in full: idle run (attract only), spam run,
random-tap runs over several seeds, the skilled bot (proves it can be played
well and that the curve ramps), the bad bot (proves dying, game over and
restart work), a long soak for performance and object growth, and
screenshots of every state plus a preview GIF of the first 5 seconds and a
gameplay GIF. **Look at every screenshot** (Read them) against the polish
checklist.

If the MATLAB MCP is connected and the person's MATLAB session is shared,
also run `minihackContest.play('<path>/game.m')` in their session, drive a
few taps through the figure's `WindowButtonDownFcn` as `AGENTS.md`
describes, then close it and clean up timers.

## Phase 6 — Final review

Dispatch in parallel (roles in `references/review-roles.md`):

- **Playtester**: gets the game folder, the shots/GIFs, the harness and the
  playtest guide; plays it with its own scripted runs and bots.
- **Bug hunter**: reads `game.m` and tries to break it (stuck states, NaN,
  unbounded growth, dt dependence, rule violations, render side effects).

Fix what they find; re-run Phase 5 for what changed. Any must-fix → one more
round after fixing.

## Phase 7 — Polish pass

One fresh **Polish reviewer** agent that didn't build the game: give it the
game path, the harness, and the playtest guide, but not your screenshots or
anyone's opinions. It takes its own shots of every state and reviews them
against the polish checklist. Fix everything; re-shoot.

## Phase 8 — Wrap up

1. `README.md` for the game: name, one line, how to play (one sentence), what
   to look for, how to run it (`cd games/<slug>` then
   `minihackContest.play`), character count.
2. `design/TIPS_POST.md`: a draft Tips & Tricks post per
   `references/tips-post.md`. The post is required for the grand prizes and
   the Most Played award, and its quality is judged.
3. Tick off STATUS.md.
4. **Report** briefly and plainly: how many levels there are and that each
   one has a replayed solution proving it fully beatable; the name and the
   one-line pitch, how to
   play it now (in MATLAB: `cd('<abs path>/games/<slug>'); minihackContest.play`),
   what's in it, the character count against 10,000, anything that doesn't
   work (plainly), the GIF path, and two or three ready-to-paste
   `/matlab-obg-gen --change <slug> ...` ideas.

**Never submit as part of making a game.** Submission is public; it only
happens through `--submit`, with the person's explicit go-ahead.

## Submitting (`--submit [slug]`)

Automate everything except the decision itself.

1. **Setup check** (Preflight step 0) and the contest toolkit is loaded.
2. **Gates. Stop and say which one failed, and why, if any fails:**
   - the proof of beatability passes **right now** on the current
     `game.m`: run the game's `design/tests/prove.m` (every level's
     recorded solution clears it fully, and the human-timing check passes).
     No `prove.m`, or a failing one, means no submission until it's fixed;
   - `minihackContest.validate('<abs path>/game.m')` prints
     `Validation passed.` with a character count (not SKIPPED);
   - the quick suite (`obgsuite ... 'Quick', true`) passes, with no errors
     and no object growth;
   - the first frame (tick 0) and a GIF of the first 5 s look right. This
     is what the server records as the gallery preview, so Read them.
3. **Ask once, with everything they need to decide:** one question with
   2-3 suggested titles (≤ 80 characters, from the README's name and
   tagline) and the facts: the proof status, the character count, the
   preview frame's path, and that submitting is public under their
   MathWorks account. They pick or type a title, which is the go-ahead.
   Without an explicit yes, stop.
4. **Submit** in MATLAB (MCP, or batch if no MCP):
   `cd('<abs path>/games/<slug>'); r = minihackContest.submit('title', "<title>", 'confirm', true)`.
   If it fails on authentication, ask them to sign in to MATLAB (Home tab ->
   sign in) and retry once. Any other error: show it plainly, don't retry.
5. **Record** the entry URL, title, date, character count and the git
   commit (if any) in `design/STATUS.md` under "Submissions". Fetch the
   entry page and take its **"Play Game" link** (a MATLAB Drive URL ending
   in `Entry<id>.mlapp`; it opens the game for anyone signed in, who clicks
   *Run*). Put both near the top of the game's README:
   `▶ [Play <name>](<play link>) · [contest entry](<entry URL>)`.
6. **The Tips & Tricks post** (required for the grand prizes and Most
   Played): refresh `design/TIPS_POST.md` against the submitted code (every
   number measured, every snippet run), put the entry URL in it, and give
   them the post's path and where to post it: MATLAB Central → Discussions
   → the contest channel (Contest Channels, "MATLAB One-Button Game Mini
   Hack"), as a Tips & Tricks post. They post it themselves.
7. **Report:** the entry URL, the title, what to do next (post the Tips
   draft, share the link), and that `--submit` again after changes updates
   their entry (if the contest allows resubmitting; say so if unknown).
