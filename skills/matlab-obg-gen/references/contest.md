# The contest: contract, rules, judging, quirks

MATLAB One-Button Game Mini Hack (MATLAB Central, 25th anniversary).
Runs Nov 2 – **Nov 29, 2026, 11:59:59 PM EST**.

## The contract

`game.m` defines `game()` returning a scalar struct of three handles:

```matlab
g.init(ax)                    -> state      % once; create ALL graphics here
g.update(state, dt, pressed)  -> state      % every tick
g.render(~, state)            -> (nothing)  % every tick; mutate handles only
```

- `ax`: a `uiaxes` filling an 800×600 px window, already set up with
  `XLim=[0 800]`, `YLim=[0 600]`, `hold on`, hidden ticks/axes, toolbar off,
  default interactivity off. Override `XLim`/`YLim`/`YDir`/`Color` in init if
  wanted. (`YDir='reverse'` gives screen-style y-down.)
- `dt`: seconds since the last tick, clamped to `[0.001, 0.050]`. Target is
  30 fps (timer `fixedRate`, period 0.033, `BusyMode='drop'`). Scale every
  motion by dt. If the game lags, dt caps at 0.05 so the game slows down
  instead of skipping.
- `pressed`: logical scalar, true on the tick after SPACE (KeyPressFcn) or a
  mouse click (WindowButtonDownFcn) since the last tick. Several presses
  between two ticks collapse into one `true`.
- `render`: no `drawnow` (the harness does it), no new graphics, idempotent.
- State flows only through `state`. No `global`, no `persistent`.
- An error in update/render stops the game and shows a `uialert`. There is
  no recovery: a single runtime error ends the player's session.

## Hard rules (checked locally and re-checked on the server)

- **≤ 10,000 characters**, counted as `strlength(tree2str(mtree(file,'-file')))`,
  so comments are free but the code is **re-printed with generous
  spacing and 4-space indentation** before counting: expect ~1.5x your
  hand-written size. See "The character count is of REFORMATTED code" in
  matlab-craft.md and measure from the first milestone.
- **No `!` (BANG) operator.**
- **163 banned functions** (live list from `tools/fetchrules.m`, Nov 13 2026).
  The ones that bite game code most:
  - `delete` — you can't delete graphics: pool them and toggle `Visible`.
  - `error`, `rethrow`, `lasterr` — no throwing.
  - `regexp` (but `regexprep`, `strrep`, `strsplit`, `contains` are fine).
  - `pause`, `input`, `keyboard` — no blocking.
  - `sound`, `soundsc`, `audioplayer`, `beep`, `playblocking` — **no audio at
    all**. Feedback has to be visual.
  - `eval`, `evalc`, `evalin`, `feval`, `str2func`, `builtin`, `inline`,
    `run`, `assignin` — no dynamic dispatch. Function handles (`@f`) are fine.
  - `uicontrol`, `uimenu`, `uicontextmenu`, dialogs, `figure` windows.
  - `cd`, `pwd`, `dir`, `path`, `addpath`, `which`, `who(s)`, `computer`,
    `feature`, `getpref/setpref` — no environment access, so no saved high
    scores. Best score lives only in `state` for the session.
  - `import`, `java*`, `py*`, `NET`, `System`, `Microsoft`.
  - All file I/O (`load`, `save`, `fopen`, `imread`, `readtable`, ...).
  - `print`, `help`, `type`, `edit`, `web`, `more`, `echo`.

  Full list: Microsoft, NET, System, VideoReader, actxcontrol, actxserver,
  addpath, arrayviewfunc, assignin, audiodevinfo, audioinfo, audioplayer,
  audioread, audiorecorder, aviread, beep, builtin, cd, cdfread, chdir,
  computer, copyfile, csvread, csvwrite, datastore, dbstack, dbstop, delete,
  delimitedTextImportOptions, detectImportOptions, diary, dir, dlmread, dos,
  echo, edit, error, eval, evalc, evalin, execute, exit, fclose, feature,
  feval, fgetl, fgets, fileDatastore, fileread, finfo, fitsread, fopen,
  fread, fscanf, ftp, get_param, getpref, gunzip, h5info, h5read, hdf5read,
  hdfread, help, hgload, hgsave, imageDatastore, imageinfo, imfinfo,
  imformats, import, importdata, imread, inline, inlineeval, inmem, input,
  java, javaArray, javaMethod, javaObject, jpropeditutils, keyboard, lasterr,
  lasterror, load, lookfor, ls, matfile, matlabpath, mbuild, mex, mislocked,
  mlock, more, movefile, munlock, ncinfo, ncread, openfig, parquetinfo,
  parquetread, path, pause, perl, playblocking, print, printdlg, pwd, py,
  pyrun, pyrunfile, quit, readcell, readdictionary, readlines, readmatrix,
  readstruct, readtable, readtimetable, readvars, regexp, rethrow, rmpath,
  run, save, sendmail, set_param, setpref, sheetnames, sound, soundsc,
  spreadsheetDatastore, spreadsheetImportOptions, str2func, system,
  system_dependent, tabularTextDatastore, textread, thingSpeakRead, type,
  uicontextmenu, uicontrol, uigetfile, uiimport, uimenu, uiopen, uiputfile,
  unix, untar, unzip, urlread, wavread, web, webread, websave, webwrite,
  what, which, who, whos, xlsfinfo, xlsread, xmlread.

  The check uses `mtfind(t,'Fun',list)`: it matches identifiers used as
  calls/names in code, not text inside strings or comments. Don't name your
  own variables or local functions after a banned function either.

## Judging

Grand prizes ($300/$200/$100), hand-picked by MathWorks judges on:

1. **Game creativity** — originality of concept, mechanics, visual design,
   theme, *or use of the one-button constraint*.
2. **Gameplay and use of the one-button constraint** — clear, engaging,
   playable with one control.
3. **Technical execution** — runs reliably; uses MATLAB well.
4. **Tips & Tricks post quality** — clarity, usefulness, accuracy, teaching
   value. A post is required for grand prizes and for Most Played.

**Most Played Award**: top 10 authors by plays of their most-played game
($50 each). Ties broken by votes. So: an inviting thumbnail and a game people
replay and share. Weekly T-shirt/sock draws for authors and players.

## Quirks that shape design

- **The server renders a preview GIF and a screenshot** of each entry on
  submit, presumably with no input. That's the gallery thumbnail: the
  attract/title state must look great and move within the first seconds
  with no taps. A static "Press SPACE" on black is a wasted thumbnail.
- **The server renderer may differ from Windows desktop**: stick to default
  or generic fonts (`'FixedWidth'`, default `Helvetica`-ish sans). Don't
  rely on emoji or exotic Unicode glyphs rendering.
- **Holding SPACE auto-repeats** (OS key repeat, ~0.5 s delay then ~30/s),
  so a held key becomes a stream of taps; a held mouse button is one tap.
  Games must stay sane under mashing; don't design around holding.
- **Clicks on graphics**: objects need `'HitTest','off','PickableParts','none'`
  or clicks may not reach the figure's handler.
- **No audio**: replace sound with flashes, shake, particles, colour pulses,
  text pops.
- **Errors are fatal**: guard indexing, empty arrays, divide-by-zero,
  `NaN` positions (a NaN in `Position` of a `rectangle` throws).
