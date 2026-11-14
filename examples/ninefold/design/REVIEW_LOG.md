# Review log

## Round 1 (2026-11-13): Player, MATLAB builder, Contest judge

The refinement was done by the builder (me), not a separate refiner agent. The
findings were concrete and agreed with each other, and a physics prototype
already existed to check them against. Outcomes:

| Finding | Severity | From | Outcome |
|---|---|---|---|
| Flat floors/shelves trap balls forever | must | Player | Fixed: a ball blocked below and diagonally rolls sideways in its `dir`, flipping at walls. Only cups hold balls. |
| Glow too slow vs ball speed (5.5 s cycle, 1.3 s fall) | must | Player, Builder, Judge | Fixed: snake order (1,2,3,6,5,4,7,8,9, box), so the glow always moves to a neighbour. Dwell 0.5 s on rooms holding balls and 0.22 s on empty rooms. Ball step slowed to 0.17 s. Cups make "hold until tipped" the normal state. |
| Box turn moves the inlet and exits (off-grid spawn, unwinnable) | must | all three | Fixed: the box turn rotates only the 9×9 play area (`T(2:10,2:10)=rot90(...)`). The inlet stays top-centre and the exits stay on the bottom frame. |
| Physics rules vague (seesaw target, squeezes, inlet) | must | Builder | Fixed in the tech plan: occupancy is checked per move, balls sorted deepest first, diagonal needs side and diagonal free (no corner squeeze), seesaw pushes sideways and flips only if the move happens, inlet drips only when its tile is free. Seesaw/gate codes keep their meaning when turned (intended). |
| Preview GIF dull and slow to start | must | Judge, Player | Fixed: attract plays a showcase level with a 0.25 s drip. The bot taps as soon as a room holds 2 resting balls, and the title sits in the HUD column, not over the board. |
| One timeout can end the run | should | Player, Judge | Fixed: a timeout adds at most 3 strays. A CLEAN level heals one stray. |
| Level 1 teaches nothing | should | Player, Judge | Fixed: L1 is hand-set (cup under the inlet, otherwise empty) and the glow starts on that room. L2 adds a second cup. |
| Can't predict a turn | should | Player | Partly: distinct glyphs (wedge seesaws, red trap bars, green/red switch diamond). No ghost preview, to save characters. |
| Timer table vs formula | should | Player, Builder | Fixed: one formula, `max(30, 10+2.6*balls)*max(.75,1-.025L)`, to be tuned with the bot. |
| Selector reads as a workaround | should | Judge | Fixed: snake path plus variable dwell. Pitch hook: "the glow travels with the flow". |
| Blocky tile art | should | Judge | Partly: walls are inset blocks with bevels via the frame colour, seesaws are wedges, traps are bars, exits are coloured chutes. Revisit in the polish pass. |
| Ramps missing | should | Judge | Fixed: dropped "ramps" from the pitch. Diagonal staircases and seesaws do that job. |
| MATLAB showcase not stated | should | Judge | Fixed: `rot90` on blocks is the headline, nested hgtransforms ease the turn, the bot is a lookahead on `g.update`. |
| No Tips angle | should | Judge | Fixed: Tips section added. |
| Physics during spin mismatches | should | Builder | Fixed: physics pauses while any turn is animating (a hit-stop of about 0.3 s). |
| 8.3k estimate low | should | Builder | Accepted: budget 9.5k. The cut list now has gates/switch and pops higher. |
| Busy-frame cost | should | Builder | Fixed: HUD strings are set only when they change (same-value sets are cheap anyway), and there's no shake during spins. To be measured. |
| Unwinnable generated levels | should | Builder | Fixed: the bot sweeps L = 1..15. The inlet column in room 2 is kept clear. |
| Attract could reach game over | should | Builder | Fixed: attract ignores strays and restarts its level. |
| Held SPACE spins forever | nice | Builder | Fixed: taps are ignored while the lit thing is still mid-turn (|angle| > 0.8). |
| No score hook | nice | Player | Partly: time bonus plus CLEAN bonus, and the session best is shown on game over. |
| Switch room hidden rule | nice | Player | Fixed: diamond glyph, red when traps are shut and green when open, with a flash on toggle. |
| Exit readability | nice | Judge | Fixed: exits are coloured chutes in the bottom frame. |

Round 2 was skipped because all must-fixes were resolved by concrete rule
changes that the build's bot runs will verify directly.

## Final review (2026-11-13): Playtester and Bug hunter

| Finding | Severity | From | Outcome |
|---|---|---|---|
| Turning room 2 walls off the inlet; drip stops for good | must | Playtester | Fixed: room 2 is always an empty chute, so turning it can't block the inlet (a first fix that pinned the inlet tile broke the cup's rotation and was replaced) |
| L1 doesn't teach the tap; 30 s dead stretch | should | Playtester | Fixed: the deep cup in the centre room on every level; the pile reaches the inlet and the drip waits until you tip it; the level ends early once everything has dripped and every ball has rested 6 s |
| Taps freeze the box; physics resumes late | should | Playtester, Bug hunter | Fixed: physics and the clock resume at under 0.3 rad (about 4 ticks); re-tapping waits for the same threshold |
| Wrong-exit strays uncapped; L7 lost without a tap | should | Playtester | Fixed: at most 2 strays per level of any kind; exits are never under the inlet |
| Curve: free L3, cliff at L4 | should | Playtester | Fixed: one new idea per level (colours L4, traps and switch L5, third colour L7); centre cup on every level; looser timer `max(30, 12+3*balls)` |
| No dwell cue, no tap flash | should | Playtester | Fixed: the glow outline is thick on arrival or a tap and thins as its time runs out (a rounded rectangle, which also removed a corner-spike artifact) |
| Random tapping beats careful play (box turn) | should | Playtester | Fixed: a box turn costs 2 s of the clock |
| Inlet and exits look alike; switch same red as traps | nice | Playtester | Fixed: cyan inlet, amber switch |
| More than 3 wrong exits refunded strays | must | Bug hunter | Fixed: the per-level counter stops at the cap, so the end-of-level term is never negative |
| Inlet overwrite destroyed tiles | must | Bug hunter | Fixed by the chute redesign (no overwrite at all) |
| Attract mode accumulated "STRAYS 33/6" | should | Bug hunter | Fixed: the demo restarts with a fresh run |
| Switch shut a trap door on a ball | should | Bug hunter | Fixed: doors with a live ball on them stay open |
| Character budget nearly gone | should | Bug hunter | Handled: cut the level-start banner, the leftover text, the "BEST" HUD line and the unused clock; 9,849 / 10,000 |
| Held SPACE freezes physics, clock runs | nice | Bug hunter | Fixed: the clock pauses with physics |
| up() never skipped ball lines (column vs row) | nice | Bug hunter | Fixed: rows passed |
| Two-colour levels unsortable (found in the post-fix bot runs) | must | builder | Fixed: colours arrive in runs of three; each colour's exit gets its own section of the floor |
