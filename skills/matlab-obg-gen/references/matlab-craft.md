# MATLAB craft: good-looking, fast, under 10,000 characters

Measured on R2026b (hidden uifigure, Windows, Nov 2026). Numbers are per
tick including `drawnow`; the real window may be faster with a GPU, but the
ratios hold.

## Performance: what a frame costs

| Change per tick | ms |
|---|---|
| nothing changed (drawnow only) | ~0-3 |
| same value set on text String, rectangle Position, Visible | ~0.2 (no redraw) |
| same value set on **patch Vertices/FaceVertexCData, line XData/YData, FaceAlpha** | **17-35: always redraws** |
| any one visible change (base redraw) | ~9-15 |
| each additional separately-changed object | ~+1 |
| 50 separate rectangles moved | ~58 |
| one `patch` with 100 quads (Vertices + colours) | ~14 |
| one `line` with 100 NaN-separated segments | ~16 |
| `line` with 200 `'.'` markers (particles) | ~9 |
| `scatter` with 200 points | ~20-25 (avoid for particles) |
| `image` CData update (any small size) | ~13 |
| `hgtransform` Matrix (moves a whole group) | ~13 |
| changing `ax.XLim`/`YLim` (camera shake/scroll) | ~20 |
| changing `ax.Color` | ~20 (use a background patch instead) |

The budget is 33 ms at 30 fps. Rules that follow:

- **Batch.** Many similar things → one object: a `patch` with `Faces`/
  `Vertices`/`FaceVertexCData` for blocks/tiles/enemies; one `line` with
  NaN breaks for many segments; one `line` with `'Marker','.'` for
  particles. Aim for ≤ ~15 objects that change per tick.
- **Don't touch what didn't change.** Patch and line *data* properties
  redraw even when set to identical values, so guard them (isequaln costs
  ~0.15 ms):
  ```matlab
  function up(h, varargin)   % set only if something actually changed
  if ~isequaln(get(h, varargin(1:2:end)), varargin(2:2:end))   % get({names}) -> {values}
      set(h, varargin{:});
  end
  end
  ```
  (Use isequaln, not isequal: NaN-padded line data never compares equal.
  Pass line data as **rows**: lines store XData/YData as rows, so a column
  never matches and the guard silently does nothing.)
- **Camera moves:** put the world under one `hgtransform` and set its
  `Matrix` (scroll, shake, zoom) instead of changing axis limits.
- **Flashes:** a full-screen `patch` with `FaceAlpha` (hidden when idle),
  not `ax.Color`.
- **Hide, don't delete** (`delete` is banned): pool objects, toggle
  `Visible`, or move them off-screen / set data to NaN (lines accept NaN;
  rectangles do NOT).
- The harness passes `dt` clamped at 0.05: a slow frame slows the game but
  doesn't explode physics. Still, keep physics stable for dt up to 0.05
  (sub-step if needed).

## Crashes to design out (an error ends the game)

- `rectangle` `Position` must be finite with width/height ≥ 0: NaN or a
  negative size throws. Clamp sizes with `max(0, w)`.
- **`render` runs once right after `init`, before any `update`**: init must
  set every field render reads.
- Toolbox functions (e.g. `padarray`, Image Processing) may not exist on
  every machine that runs the game; stick to base MATLAB.
- Colours must stay within [0,1]: clamp anything computed (pulses, mixes).
- Index guards: empty pools, `find(...,1)` returning empty, `mod` for wrap.
- Text `String` with TeX: stray `_` or `^` become sub/superscripts; set
  `'Interpreter','none'` for plain text.
- `sprintf('%d', 3.5)` prints `3.500000e+00`: round first.

## Looking good

- **Background:** `image(ax,[0 800],[0 600],C)` with a procedural `C`
  (`meshgrid` gradients, noise, stars) made once in init. Or layered
  patches with interpolated colour (`'FaceColor','interp'` +
  `FaceVertexCData`) for gradients.
- **Glow:** draw a line/patch twice: wide + low alpha (`'Color',[r g b .25]`,
  `LineWidth` 10-14) under thin + bright. Pulse the alpha.
- **Shapes:** `patch` polygons from a few vertices (`cos`/`sin` around a
  circle for n-gons, stars, blobs); `rectangle` with `'Curvature',[1 1]` for
  circles, `[.3 .3]` for rounded boxes.
- **Rotation/scale/squash:** parent a group to `hgtransform`, set
  `makehgtform('translate',[x y 0],'zrotate',a,'scale',[sx sy 1])`.
- **Trails:** a `line` whose XData/YData is a short history buffer
  (`h = [h(2:end,:); x y]`), NaN-initialised.
- **Particles:** one `line` with `'LineStyle','none','Marker','.'`,
  arrays of position/velocity/life in state; dead particles → NaN.
- **Text:** default font or `'FixedWidth'`; bold, large (24-48) titles;
  `HorizontalAlignment','center'`. A dark copy offset by 2 px under the text
  gives a cheap drop shadow. TeX colour: `'{\color[rgb]{1 .4 .4}TAP}'`.
- **Palette:** pick 4-5 colours and stick to them; one accent colour for
  "this is the button's effect". Dark background + saturated foreground
  reads well in a small GIF.
- **Colour maps** (`hsv`, `turbo`, `parula`, `interp1` over a custom map)
  for rainbow progressions and heat.

## Feedback without sound

Every tap must give instant visible feedback on that tick: a squash, a
flash ring, a particle puff, a colour pulse. Also: screen shake on hits,
hit-stop (freeze 2-4 ticks), score pop-ups that drift and fade, easing
(`x += (target-x)*min(1,dt*k)`), a short white flash on death, a slow-mo
on near misses, combo counters that grow, background hue shifting with
progress.

## State machine skeleton

```matlab
switch s.mode
  case 0  % attract: animate a demo by itself; tap -> reset & mode 1
  case 1  % play
  case 2  % game over: show score/best; after a 0.6 s lockout, tap -> mode 1
end
```

The attract mode should *play itself* (a simple bot inside update) so the
preview GIF shows the game in motion.

## Randomness

`rand`/`randn` are fine. For a reproducible demo, keep your own seed in
state (a small LCG: `s.r = mod(s.r*1103515245+12345, 2^31)`) rather than
calling `rng` (allowed, but it changes global state).

## The character count is of REFORMATTED code

The limit counts `strlength(tree2str(mtree(file,'-file')))`. `tree2str`
strips comments but **re-prints the code**: 4 spaces of indentation per
nesting level (function bodies included), one statement per line, spaces
around binary operators, `f( x )` / `a( i, j )` with spaces inside parens,
`[ 1, 2, 3 ]` with commas and spaces in brackets. Typical hand-written code
grows ~1.5x. A first draft of Ninefold that "looked" like 8k was 16.4k;
37% of the counted characters were spaces. So:

- **Measure early and after every milestone** (`minihackContest.validate`
  prints it). Budget the design in counted characters.
- **Statements and tokens cost, not typing.** Fewer statements, fewer
  index operations, fewer nesting levels. Short names save little.
- **Strings are counted verbatim**: put tables in strings and decode,
  e.g. a palette `reshape('934287...'-48,3,[])'/9` or shape offsets
  `reshape('ddxdxx...'-110,8,[])'/10` instead of numeric matrices.
- **Complex numbers** fold x/y pairs into one value: positions, velocities,
  grid cells (`col + 1i*row`), rotations (`z.*exp(1i*a)`; with YDir
  reverse, `*1i` is a clockwise quarter turn).
- `[a.x, a.y, a.z] = deal(...)` merges several assignments into one line.
- One `text(ax, X, Y, {strings})` call creates many texts; style them with
  `set(h, {'FontSize'}, {..})`.
- `plot(ax, x, y, 'o', ...)` takes a LineSpec; `line` needs
  `'LineStyle','none','Marker','o'`.
- A local `mk = @(Z,c) patch(...)` lambda for repeated patch creation.
- Keep state field names meaningful; people read the code.

**When over budget, cut in this order**, measuring each step:

1. **Lossless compaction**: the same behaviour and look in fewer counted
   characters (merged statements, `deal`, string tables, fewer nesting
   levels, shared helpers). Do a full pass before cutting anything; on one
   game it freed 312 characters with nothing visible lost.
2. **Code the player never sees**: duplicate branches, over-general
   helpers, attract-mode logic that could be simpler.
3. **Wording**: shorter on-screen text (keep it clear).
4. **Rule and score extras** that don't change how it plays.
5. **Visual flair last.** People value the look most; propose such cuts
   rather than making them.

Never cut something a check relies on to save characters (behaviour at
dt 0.05, the proof), and never the core tap mechanic.

## Indexing shape gotcha

When a vector is indexed by a vector, the result takes the **source's**
orientation: `rowVec(colIdx)` is a row. Mixing that with a column then
broadcasts to a matrix (silent bug or size error). Keep lookup tables as
columns and pass `k(:)`.
