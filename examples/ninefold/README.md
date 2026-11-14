# Ninefold

*Nine rooms, nine levels, one button: turn the glowing room to pour every ball home.*

Coloured balls drip into a box divided into nine 3×3 rooms full of cups,
shelves, staircases, seesaws and trap doors. A glow moves from room to room
and then around the whole box. **Tap to turn whatever is glowing a quarter
turn clockwise**, and get every ball out through a hole of its own colour
(white holes take any colour) before the clock runs out. Clear all nine
levels to win.

## How to play

- **Tap** (SPACE or click) turns the glowing room 90°. Tap again while it's
  still lit to keep turning it. Tapping a blank room skips the glow ahead.
- When the glow goes round the **whole box**, a tap tips everything at once.
- A hole only takes balls of its own colour; others roll straight over it.
- Balls still inside when the level ends are **strays** (at most 2 per
  level). Six strays and the run is over. A **clean** level (every ball
  home) wins a stray back.
- If the **inlet** at the top turns **red**, something is blocking it and
  balls are waiting: clear the top room.
- The **amber diamond** room is a switch. Tapping it opens or shuts every
  red trap door.

## The nine levels

Every level starts with the drip running down a sealed tube into the **deep
cup in the centre**: nothing scores until you tip it. Colours arrive at
level 4 (in runs of three), trap doors and the switch at level 5, and a
third colour at level 7.

**Every level is proven beatable.** Each one has a recorded solution that
clears it with every ball home (`design/solutions/level-N.mat`). A
simulated player with human reaction times (65-265 ms, re-planning from
what it sees) clears every level cleanly, and one complete run from the
title to the "ALL NINE CLEAR!" screen is replayed through the contest
harness. Re-run the proof after any change: `design/tests/replayAll.m`.

## Run it

In MATLAB, with the contest toolkit installed:

```matlab
cd examples/ninefold   % in a contest project made with /matlab-obg-gen: cd games/ninefold
minihackContest.play
```

## Inside

- 9,903 / 10,000 characters (comments excluded, as the contest counts them).
- The box is an 11×11 tile grid. Turning a room is `T(i,j) = rot90(T(i,j),-1)`.
  Each ball's tile is a complex number `col + 1i*row`, so turning the balls
  is `centre + (z - centre)*1i`, and the animation eases back with
  `z.*exp(1i*angle)`.
- The nine levels come from a generator seeded by a 9-character string,
  `'lmonplrsm'`, one seed per level, each chosen and verified by a solver.
- Everything on the board (121 tiles) is one patch, and the balls are three
  marker lines (one per colour). Patch and line data are only set when they
  change, because MATLAB redraws them even for identical values.
- Design notes, reviews, solver and test scripts are in `design/`.
