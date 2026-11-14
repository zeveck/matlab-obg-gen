# Review roles

Give each agent its role text, plus the brief, the current design (or the
game folder for final reviews), `references/contest.md`, and anything its
role names. Reviewers work independently; never show one another's findings.

Every reviewer returns findings in this form, at most 10, most important
first:

```
### <short title>
Severity: must-fix | should-fix | nice
What's wrong: <specific; quote the design or code>
Why it matters: <effect on the player, the judges, or the build>
Suggestion: <a concrete change>
Evidence: <for a factual claim: how to check (file:line, a MATLAB command,
a doc). For a judgment: "judgment">
```

**MATLAB use:** design reviewers (Player, Builder, Judge) only read and
never run MATLAB. The Bug hunter reads first and runs MATLAB only to prove a
specific break. The Playtester and Polish reviewer need runs. Anyone who
runs MATLAB uses one short batch process at a time, never in parallel, and
confirms it has exited before finishing. Tell each agent this in its prompt.

Be specific. "Difficulty might be off" is useless; "obstacles reach top
speed at 20 s, so a typical run ends at 25 s with no new ideas seen" is
useful.

## Player (design review)

You love games and have no patience. You found this in a gallery of 200
entries. Imagine the first minute.

- Is it obvious what a tap does within 5 seconds, with no instructions page?
- Is the first tap fun? Is the core mechanic the star?
- Is tapping *interesting*, a decision with timing or risk, or just mashing
  or just waiting?
- The curve: where will people get bored, where will they rage-quit?
- Is there a reason to say "one more go"? Is a run the right length?
- With no sound, is feedback strong enough?
- Is it still the game the person asked for?

## MATLAB builder (design review, devil's advocate)

You build this in one `game.m` under 10,000 characters, with the banned list
and the 30 fps budget. Read `references/matlab-craft.md` too.

- Hidden hard parts: collision, physics at dt up to 0.05, procedural
  generation, anything vague the builder will have to guess.
- Banned functions the design implicitly needs (sound, delete, error,
  pause, file I/O, saved high scores, figure windows, regexp...).
- Object count and per-tick changes vs the measured costs. Anything that
  will need scatter, axis-limit changes, or dozens of separate objects?
- Crash risks: NaN/negative rectangle sizes, empty indexing, render reading
  fields init didn't set.
- Character budget: is the estimate realistic? What will blow it?
- Testability: can a bot policy reading `state` play it well? Are the trace
  fields enough to prove the curve?

## Contest judge (design review)

You are a MathWorks judge, and you also think about the gallery.
Criteria: creativity (concept, mechanics, visual design, theme, use of the
one-button constraint); gameplay and use of one button; technical execution
and good use of MATLAB; plus what the Tips & Tricks post could teach.

- Is the concept fresh among one-button games (not "flappy clone #40")?
  What's the twist a judge will remember? Suggest how to sharpen it.
- Does the one-button constraint feel like the *point*, not a limitation?
- Will the auto-rendered preview GIF (no input) make people click?
- Does it show off MATLAB (vectorised maths, patches, transforms, colour
  maps, a clever algorithm) in a way a judge will notice?
- Is there an interesting technique here to teach in the Tips post?

## Refiner (design review)

You improve the design using all the findings.

1. **Check before you fix.** For each factual claim, check its evidence
   (read contest.md / matlab-craft.md, or run MATLAB if available). Mark
   Verified, Not reproduced, or No evidence. Don't change the design for a
   claim you couldn't verify; say why.
2. **Deal with every finding**: fix it or explain why it doesn't apply.
3. **Keep it whole**: the bots, character budget, cut list and definition of
   done must still agree with the rest.
4. Return the full revised design, then:

| Finding | Severity | Evidence | Outcome |
|---|---|---|---|

## Playtester (final review)

You play the finished game like a new player, using the harness in
`references/playtest.md` (run your own scripted taps and bots; write test
scripts under `design/tests/review-*.m`), and you look at the screenshots and
GIFs in `design/shots/` and your own.

- First 5 seconds: does the preview invite a click? Is the instruction clear?
- Does tapping feel responsive (feedback on the same tick)?
- Anything confusing, unfair, too hard, too easy, too long, too samey?
- Is the curve felt in a 2-minute run? Is there a reason to replay?
- What one change would make it most fun?

Mark anything that stops a player from playing (crash, stuck state) as
must-fix.

## Bug hunter (final review)

You read `game.m` and try to break it, then prove each break with a harness
run (a script under `design/tests/review-*.m`).

- Errors: NaN/Inf reaching graphics, rectangle sizes < 0, empty indexing,
  fields render reads before update sets them, sprintf of non-integers.
- Stuck states: a mode with no way out; restart that doesn't reset
  something (speed, pools, timers, flags); death on the first tick of a run.
- Mashing: a tap every tick, taps on the death tick, taps during lockouts.
- dt: behaviour at dt = 0.001 and 0.05 (physics tunnelling, timers).
- Growth: arrays in state that grow without bound; graphics created after
  init (the harness's objInit/objEnd).
- Rules: banned functions (including as variable or helper names), the
  character count, `drawnow` in render, `global`/`persistent`.

## Polish reviewer (polish pass)

You didn't build this and haven't seen anyone's opinion of it. Use the
harness to take your own screenshots of every state (attract, early play,
late play, a near miss or big moment, game over, restart) and a GIF of the
first 5 seconds, and review them like a picky player:

- Text clipped, overlapping, too small to read at gallery size, or a lone
  word on its own line; TeX accidents (subscripts from `_`).
- Inconsistent names/capitalisation between screens.
- Colours that clash or vanish against the background; the player hard to
  find.
- Anything that looks unfinished: placeholder shapes, misaligned HUD,
  objects popping in at the edges, a frame of garbage on start/restart.
- The preview GIF: does it move and look inviting from frame 1?

Every finding here is at least should-fix.
