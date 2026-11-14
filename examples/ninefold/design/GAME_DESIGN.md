# Ninefold

*Nine rooms, one button: turn the glowing room to pour every ball home.*

## Pitch
Coloured balls drip into a square box divided into nine 3×3 rooms full of
cups, shelves, ramps, seesaws and trap doors. A glow steps from room to room
and then around the whole box; tap to turn whatever is glowing a quarter
turn. Route every ball out of its matching exit before the clock runs out:
stragglers and wrong exits are strays, and six strays end the run.

## The one-button idea
- A tap = "turn the lit thing 90° clockwise". The lit thing is one of 10
  stops: rooms 1-9 (reading order), then the whole box.
- The glow dwells 0.55 s per stop; a tap resets the dwell, so tap-tap turns
  the same room 180°, tap-tap-tap 270°.
- Turning a room `rot90`s its 3×3 tiles **and the balls inside it**: a cup
  full of balls tips out, a shelf becomes a wall, a ramp changes direction.
- Turning the box turns everything (frame, exits, inlet) so "down" becomes
  a different side: the big, dramatic move, but it also moves the exits.
- A *switch room* (from level 4) can't turn; tapping it toggles every gate
  (trap door) in the box between closed and open.
- Skills: timing the glow; reading the flow (which turn frees balls without
  spilling them into the wrong exit or a cup); juggling several jams at once.
  Context keeps the tap fresh: the same tap fixes or wrecks depending on
  what's inside the room at that moment.

## Core loop
- 5 s: watch where balls are piling up, wait for the glow, tap (maybe twice).
- A level: 25-60 s; balls drip in from the inlet, get routed, the level
  clears when every ball has left (or the timer hits zero).
- A run: levels 1, 2, 3... until 6 strays; 2-4 minutes. "Again" because the
  levels are the same each time (seeded by number): you learn them and get
  further.

## The first 5 seconds (the preview)
Attract mode plays level 2 by itself (a built-in bot taps when the glow is
on a room holding resting balls): balls dripping, rooms spinning, balls
pouring out with bursts. Over it: **NINEFOLD** and "TAP TO TURN THE GLOWING
ROOM". The first tap starts level 1, which has one colour, one exit and one
obvious cup to tip.

## Structure and difficulty
Generated from the level number L with a seeded LCG:
| L | colours | balls | exits | pieces | timer |
|---|---|---|---|---|---|
| 1 | 1 | 5 | 1 white (any colour) | mostly empty, 1-2 cups | 40 s |
| 2-3 | 1 | 7-9 | 1-2 white | cups, shelves, ramps | |
| 4-5 | 2 | 10-12 | 1 per colour | + seesaws, gates + switch room | |
| 6+ | 2-3 | 12-24 | 1 per colour | denser walls, more seesaws/gates | tighter |

- Balls: `min(24, 3+2L)`; drip interval `max(0.45, 1.3-0.08L)` s.
- Timer: `12 + 3.2*balls` s, shrinking factor `max(0.7, 1-0.03L)`.
- Room motif probabilities shift from empty/cup toward dense pieces with L.
- Endless: levels keep coming; difficulty caps around L=10.

## States
- **attract (0):** demo of level 2 with bot; title overlay. Tap → level 1.
- **play (1):** glow cycles; HUD live. All balls out → clear; timer 0 →
  leftovers become strays → clear (if strays < 6) or over.
- **clear (2):** 1.8 s banner "LEVEL n CLEAR" + bonuses ("CLEAN +500" if no
  strays this level). Taps ignored. Then next level.
- **over (3):** "GAME OVER", score, best (session), level reached. 0.8 s
  lockout, then tap → level 1.

## Look
Palette: background navy `[.06 .07 .14]`; room floors alternating
`[.10 .12 .22]`/`[.12 .14 .25]`; walls slate `[.55 .62 .78]`; frame
`[.30 .34 .50]`; seesaws amber `[1 .7 .2]`; gates red `[.95 .3 .35]`
(closed) / dim outline (open); balls coral `[1 .35 .4]`, teal `[.2 .9 .8]`,
gold `[1 .85 .25]`; white exit `[.95 .95 1]`; glow cyan `[.3 .95 1]`.

```
+-----------------------------+   NINEFOLD
|#####I#######################|   LEVEL 3
|#  .   |  ___  |       #     |   [==== time ====]
|#  o   | |o o| |  /    #     |   SCORE 1200
|#------+-------+-------#     |   strays  o o o . . .
|#  ... GLOW ROOM ...   #     |   (o -> its exit)
|######E#######################|
```
Board: 11×11 tiles of 50 px (9×9 play area + frame) at x,y 25..575, YDir
reversed. HUD on the right (x 600-790).

Objects: one `hgtransform` for the box (room turns animate it); per room an
`hgtransform` child holding one `patch` (that room's tile glyphs: up to 9
quads); one frame `patch`; balls as one `line` per colour (`'o'` markers);
a particle `line`; glow `rectangle` + its dwell bar `line`; switch
`rectangle`; HUD texts; banner text with shadow; a full-screen flash patch.

## Juice (no sound)
- Must: on every tap, the lit room spins (eased 0.22 s) and its glow flashes.
- Must: balls lerp smoothly between tile steps.
- Must: exit burst of particles in the ball's colour and a "+100" pop.
- Must: stray = red flash on the HUD pip + small shake of the box.
- Should: box spin is bigger/slower (0.35 s) with a slight scale bounce.
- Should: timer bar turns red and pulses under 10 s.
- Should: "CLEAN!" banner with colour cycling.
- Nice: balls squash (marker size) when they land.

## Tech plan
- Grid `T` 11×11: 0 empty, 1 wall, 2 seesaw-left, 3 seesaw-right, 4 gate
  closed, 5 gate open, 7 inlet, 10+k exit for colour k (10 = any).
- Balls: arrays `br, bc` (tile), `pr, pc` (previous, for lerp), `col`,
  `dir` (preferred slide ±1), `rest` (steps resting), `alive`.
- Step every 0.14 s (accumulator; several steps if dt is large):
  bottom-up, each ball falls if the tile below is free; if blocked by a
  seesaw it is pushed to the seesaw's side and the seesaw flips; else it
  slides diagonally (preferred side first); else it rests. Moving into an
  exit removes it (delivered if colour matches or exit is white, else stray).
- Room turn: `T(blk,blk) = rot90(T(blk,blk),-1)`; balls in the block map
  `(r,c) → (c, n-r+1)` locally; their `pr,pc` reset. Animate the room's
  hgtransform from -90° to 0; balls in that room get the same rotation in
  render.
- Box turn: `T = rot90(T,-1)`, all balls mapped, box hgtransform animates.
- Switch room: a room flagged `sw`; tap toggles 4↔5 everywhere.
- Levels: `lcg` in state; motifs as 9-bit integers → `reshape(bitget(m,1:9),3,3)`,
  random `rot90`; inlet at top centre; inlet's tile kept empty.
- Character budget: physics ~1.6k, levels ~1.4k, init graphics ~2.2k,
  render ~1.6k, state machine/HUD ~1.5k → ~8.3k.

## Bots
- **Skilled bot (test only):** lookahead through `g.update` itself: when the
  glow has just moved to a new stop, simulate 3 s with a tap now vs no tap
  (copies of state; update is graphics-free) and tap if it delivers more
  balls / leaves fewer resting balls. Must clear levels 1-6 most of the time.
- **Built-in attract bot:** tap if the lit room holds a ball resting ≥ 6
  steps (or, at the box stop, if ≥ 4 balls rest anywhere).
- **Random tapper:** loses strays fast, reaches game over.
- Trace: mode, level, delivered, strays, balls alive, time left.

## Cut list
1. Squash on landing. 2. Colour-cycling CLEAN banner. 3. Box scale bounce.
4. Third colour. 5. Gates + switch room. (Never: room turns, box turn,
seesaws, levels, timer.)

## Revisions after review round 1 (these override the sections above)
- **Rolling:** a ball blocked below and on both diagonals rolls one tile
  sideways in its `dir` if that tile is free, otherwise it flips `dir`. Flat
  floors carry balls to exits; only cups (U shapes) and corners hold them.
  "Resting" means the ball's row hasn't changed for n steps.
- **Box turn rotates only the 9×9 play area** (and its balls). The inlet
  stays at top centre and the exits stay on the bottom frame row, so a box
  turn means "tip everything", and every level stays reachable.
- **Glow:** snake order 1,2,3,6,5,4,7,8,9, then box, so it always moves to
  a neighbour and travels with the flow. Dwell 0.5 s on rooms holding balls
  (and the box), 0.22 s on empty rooms. Taps are ignored while the lit thing
  is still mid-turn. Ball step 0.17 s. Physics pauses while any turn
  animates.
- **Strays:** a timeout adds at most 3. A CLEAN level heals one.
- **Level 1** is hand-set: a cup in room 2 under the inlet, everything else
  empty, glow starts on room 2. Level 2 adds a cup in room 5. Generated from
  L3.
- **Exits:** bottom frame only, at distinct columns (one per colour).
- **Timer:** `max(30, 10+2.6*balls)*max(.75, 1-.025L)`, to be tuned.
- **Attract:** the showcase level drips every 0.25 s, the bot taps rooms
  with ≥ 2 resting balls, the title and "TAP TO PLAY" sit in the HUD column,
  and strays are ignored.
- "Ramps" dropped; diagonal staircases and seesaws provide the deflection.

## Tips & Tricks angle
1. "The puzzle is `rot90`": turning a sub-block of a grid together with its
   contents (the `(r,c)→(c,n-r+1)` remap).
2. Snap the data, ease the picture: nested hgtransforms easing from -90°.
3. Testing a one-button game with a lookahead bot that calls the real
   `update` on copies of the state, with and without a tap.

## Definition of done
- [ ] `minihackContest.validate` passes with live rules; chars ≤ 10,000.
- [ ] No errors in idle, spam, random (5 seeds), skilled-bot and soak runs.
- [ ] Attract mode animates by itself; first-5-seconds GIF is inviting.
- [ ] Skilled bot clears levels 1-5; strays rise on later levels.
- [ ] Clear → next level, timeout → strays, over → restart work repeatedly.
- [ ] Graphics object count never grows after init.
- [ ] Median tick time within budget.
- [ ] Every state looks finished in screenshots.
