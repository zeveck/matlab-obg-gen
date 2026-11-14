# Play-testing

The game isn't done until it's been played: every state, every transition,
mashing, idling, dying and restarting, a skilled run through the whole
curve, with no errors and no object growth. All of it is scripted, so it
repeats after every change.

## Running MATLAB

**MCP (preferred):** run code with the MATLAB MCP evaluate tool. Add the
tools folder once per session:
`addpath('<SKILL_DIR>/tools')`.

**Batch fallback (no MCP):** each call starts MATLAB (~40 s), so write a
script and run it in one go. Find MATLAB: `C:\MATLAB\R*\bin\matlab.exe`,
`C:\Program Files\MATLAB\R*\bin\matlab.exe`, or `where matlab`. From Git
Bash, don't put `"` inside the `-batch` string; write a `.m` file instead:

```bash
cd "<project>/games/<slug>/design/tests" && "<matlabroot>/bin/matlab.exe" -batch "suite" 2>&1 | tail -40
```

**Check the machine before running MATLAB in parallel.** Each batch run is
a full MATLAB process (about 1.5-2 GB RAM plus heavy CPU). Running the MCP
suite alongside two reviewers' batch runs once made a user's machine crawl,
and contention also spoils frame-time measurements. Before launching batch
runs or MATLAB-running agents, check free RAM, CPU load and how many MATLAB
processes are already running (Windows PowerShell: `Win32_OperatingSystem`
FreePhysicalMemory, `Win32_Processor` LoadPercentage, `Get-Process MATLAB`),
and size the parallelism to what fits. Tell reviewer agents how many batch
runs they may have going at once. Take timing measurements with nothing else
running. Interactive MCP calls share one session, so never run them from
several agents at once.

**Clean up after yourself.** After each phase, and before reporting, check
that no MATLAB processes you or your agents started are still running
(`Get-CimInstance Win32_Process -Filter "Name like '%MATLAB%'"` with
CommandLine and ParentProcessId: `-batch` runs are yours, while the MCP
session's MATLAB is the one launched by `matlab-mcp-server.exe`). Stop
leftover batch processes only once you're sure they're yours and finished.
In the shared session, check `findall(groot,'Type','figure')` and
`timerfindall` are empty, and `clear` big suite results (they can hold GBs).
Leftovers slow every later run and skew timings.

## The tools (`SKILL_DIR/tools`)

- `obgtest(gameFile, ...)`: one run in a hidden window mirroring
  `minihackContest.play`: fixed dt, scripted `Presses` or a `Policy` bot,
  `Shots` (tick 0 = right after init), a `Gif` window, a `Trace` of state per
  tick, `StopWhen`. Returns errors with the tick, ms per tick, and object
  counts at init vs end. See its header for all options.
- `obgsuite(gameFile, outDir, ...)`: the standard suite (idle, spam,
  5 random seeds, bad player, skilled bot), writes `summary.txt`, screenshots
  and GIFs. `'Quick', true` for milestone checks (~1 min); the full suite
  (~3-4 min) before any report.
- `fetchrules.m`: prints the live limit and banned lists.

Keep each game's test scripts in `design/tests/` (`suite.m`, `bots.m`...)
and outputs in `design/shots/`. A typical `design/tests/suite.m`:

```matlab
addpath('<SKILL_DIR>/tools');
g = '<project>/games/<slug>/game.m';
bot = @(s,k) <skilled policy reading s>;
S = obgsuite(g, '<project>/games/<slug>/design/shots', ...
    'Bot', bot, 'BotSeconds', 150, 'Mode', @(s) s.mode, ...
    'Trace', @(s) [s.score s.speed]);
```

`obgtest` changes into the game's folder for the run, because MATLAB's
current folder outranks the path (a root `game.m` would otherwise win).

## Bots

**Lookahead bot (strong and generic):** because `update` must not touch
graphics, a bot can call the game's own `update` on copies of the state:
when the moment to decide arrives, simulate ~3 s with a tap now vs no tap
and tap if the outcome scores better. Get the handles with
`old = cd(gameDir); g = game(); cd(old);` in the test script and pass
`@(s,k) bot(s, g)`.


A policy is `@(s,k) -> logical`, called every tick with the full state. It
can read anything in `state`, so it can play like a strong player: tap when
the next obstacle is within a window, when a phase angle is right, etc.
Write it as a local function in the test script if it's more than a line.
Bots must only *decide when to tap*: never modify state.

- **Skilled bot:** must survive deep into the curve. If it can't, either
  the bot is weak or the game is unfair; find out which from the trace.
- **Imperfect bot:** the skilled bot with jitter (tap 1-3 ticks late at
  random) shows how forgiving the timing is. Good games: a perfect bot goes
  far, a jittery bot goes a fair way, a random tapper dies early.
- **The attract demo** inside the game is a bot too; the idle run shows it.

## Prove every level can be beaten (CRITICAL)

A strong bot getting far is NOT proof. For every level:

1. **Find a solution.** Write a solver for the game (in `design/tests/`),
   usually a search over tap timings that drives the game's own `update` on
   copies of the state (the game must be deterministic for a fixed `dt`:
   seed any randomness that affects play, and keep cosmetic randomness out
   of the rules). Make it search harder than the skilled bot: multi-step
   lookahead or beam search over "tap now / tap n times / wait" decisions.
2. **Record it** as a tap timeline, `design/solutions/level-N.mat` (or
   `.txt`), the tick indices at `dt = 1/30` from the level's first tick.
3. **Replay it** through the real harness from a clean start of that level,
   and check the level is cleared **fully** (no lost pieces, the game's own
   clear condition, not partial credit).
4. **Replay all solutions after every change** to the game. A solution
   that stops working means the level (or the rules) broke: re-solve,
   and confirm the level is still beatable before reporting.

5. **Prove it's doable by a HUMAN, not just a machine.** A solver finds
   frame-perfect solutions (taps exact to 1/30 s) that no person can
   reproduce. Test each level with a closed-loop "human" player: it decides
   at each decision point from the state it actually sees (a short search
   is fine; that's judgement), then acts with human timing: 2-8 ticks
   reaction delay (65-265 ms), follow-up taps only after the previous
   action's feedback, and it re-plans from the real state. Several such
   runs per level must clear it fully. Don't test human-ness by replaying
   the solver's script with random delays: that's blind play and fails
   everything, because people watch and adapt. A level that only a
   frame-perfect script can beat must be simplified or replaced.

Put the whole proof behind one script, **`design/tests/prove.m`**: it replays
every solution, runs the human-timing check and plays one full run from the
title to the ending, and its last line says `ALL LEVELS PROVEN BEATABLE` or
`NOT PROVEN`. `--submit` refuses unless it passes on the current game.m.
If seeds are chosen by a solver, have it write the chosen seeds back into
game.m, so the game and its solutions can never drift apart.

Generated levels: ship a finite set of seeds, each with its own recorded
solution. If the solver can't clear a seed, pick another seed or change
the level. Never ship levels that haven't been proven.

## What to check

1. `minihackContest.validate('<abs path>/game.m')` prints
   `Validation passed.` with a character count (not `SKIPPED`).
2. Static check (`check_matlab_code` / `checkcode`): no errors; fix real
   warnings.
3. Suite `result PASS`: no errors in any run, no object growth.
4. **Modes visited** (the `modes` column): idle stays in attract; bad visits
   play → game over → play...; spam doesn't get stuck; bot stays in play.
5. **Performance:** overall median ≤ ~20 ms and p95 ≤ ~33 ms in the
   hidden window. If not, see matlab-craft.md (batch objects, avoid scatter
   and axis-limit changes).
6. **The curve:** from `bot-trace.csv`, speed/difficulty rises across
   stages as designed; the skilled bot reaches the late stages; the random
   tapper's score is clearly lower.
7. **dt extremes:** one bot run with `'Dt', 0.05` and one with `'Dt', 0.01`;
   it must behave the same (no tunnelling, same difficulty by time).
8. **Look at every screenshot and both GIFs** (Read them): attract at 0, 2
   and 5 s, early/mid/late play, game over, after restart. Against the
   polish checklist in review-roles.md. The idle GIF is the gallery
   preview: it must move and invite a click from the first frame.
   (The harness's screenshots crop to the axes' tight inset, a few px
   smaller than 800×600; that's the harness, not the game.)

## In the person's MATLAB (MCP and a shared session only)

After the suite passes, open the real window once:
`cd('<abs path>/games/<slug>'); minihackContest.play`, wait 3-5 s, check
`timerfindall` is running, fire a few taps with
`fig = findall(groot,'Type','figure','Name','MATLAB One-Button Game'); fig.WindowButtonDownFcn(fig,[]);`
(the harness's `pause` is fine here; it's not game code), then close the
figure and stop/delete timers. If the person is watching, tell them first.

## Never silence a check

When a check fails, fix the cause or make the check more precise. Never
weaken a bot or shorten a run to make a failure go away.
