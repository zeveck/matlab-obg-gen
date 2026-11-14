# Game design template

Write `design/GAME_DESIGN.md` with these sections. Concrete enough to build
without guessing; short sentences and lists.

```markdown
# <Game name>

*<One-line tagline: what the tap does and why it's fun.>*

## Pitch
Two or three sentences: what you do, why it's fun, what makes it different.

## The one-button idea
What a tap means (and only that). Why this is a clever use of one button,
not just "jump". Name the skill being tested: timing, rhythm, counting,
judging distance, risk/reward, reading patterns, committing. Say how the
same tap stays interesting at minute 2 (context changes what it means).

## Core loop
The 5-second loop (what your finger does), the run (start to death or win,
target 1-3 minutes for a good player), and why you tap "again".

## The first 5 seconds (the preview)
What the attract state shows with **no input** (the gallery GIF/thumbnail),
and the words on screen telling a newcomer what to do (≤ 6 words). How the
first real tap teaches the mechanic.

## Structure and difficulty
The curve over a run, in stages (by time, score or distance): what each
stage adds (speed, a twist, a new obstacle, a rule change). How the start
avoids instant deaths. How it ends (endless with score, or a win).

## States
attract → play → game over → play ...; anything else (level clear, slow-mo
moment). What each shows, how a tap moves between them, and the lockout
after death so a mistimed tap can't skip the game-over screen.

## Look
Palette (4-5 named colours with RGB), background, the player, obstacles,
text style. Which MATLAB objects make each (patch, line, image,
hgtransform...). A tiny ASCII sketch of the screen.

## Feedback (no sound allowed)
What the player sees on a tap (must answer on the same tick), on scoring
(a small celebration), and on losing something. Keep it short; extra
effects are the first thing cut for characters.

## Tech plan
- World coordinates (800×600, YDir), state fields, the graphics objects
  created in init (with pool sizes), and which ones change per tick (aim
  ≤ ~15; see matlab-craft.md).
- Physics/timing model and dt handling.
- Character budget: estimate per part (init graphics, update logic, helpers)
  against 10,000 (aim ≤ 8,500 counted, before extra effects).

## Proving every level beatable
The finite list of levels (or seeds), and how the solver will find a
complete solution for each: what it searches over, its state copying, how
determinism is guaranteed, and the "fully cleared" condition it checks.
No endless content that can't all be verified.

## Bots (how the play-test proves it works)
- The skilled bot: a policy `@(s,k)` reading state that plays well. What it
  looks at and when it taps. What it should achieve (reach stage N / score
  ≥ X).
- The bad bot / random tapper: what should happen (dies, game over appears,
  restart works).
- Trace fields to log each tick to check the curve.

## Cut list
What to drop first if characters or performance run out. The core tap
mechanic is never on it.

## Definition of done
- [ ] **Every level has a recorded solution that fully clears it when
      replayed through the harness (CRITICAL).**
- [ ] `minihackContest.validate` passes with live rules; chars ≤ 10,000.
- [ ] No errors in idle, spam, random (5 seeds), skilled-bot and soak runs.
- [ ] Attract mode animates by itself; the first-5-seconds GIF looks inviting.
- [ ] Skilled bot reaches the late stages; the curve shows in the trace.
- [ ] Death → game over (score + best) → restart works, repeatedly.
- [ ] Graphics object count never grows after init.
- [ ] Median tick time within budget in the soak run.
- [ ] Every state looks finished in screenshots (no clipped/overlapping text).
```
