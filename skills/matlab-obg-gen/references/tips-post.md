# The Tips & Tricks post

Required for the grand prizes and the Most Played award, and judged on
clarity, usefulness, accuracy and educational value. Draft it in
`design/TIPS_POST.md`; the person posts it themselves in MATLAB Central
Discussions (contest channel). Never post it for them.

A good post teaches **one or two techniques** other entrants can reuse,
using this game as the worked example. Not a changelog, not a sales pitch.

Shape:

1. **Title** that names the trick: "Particles at 30 fps: one line object,
   200 dots" beats "My game".
2. **The problem** in two sentences (e.g. "50 rectangles made my game run
   at 15 fps").
3. **The technique**, with a short, runnable snippet (≤ 25 lines) that works
   on its own in the contest harness's contract, and a sentence on why it
   works.
4. **Numbers** where you have them (ms per frame before/after, character
   counts). Only real measurements from the harness.
5. **How it's used in the game** (link placeholder `<entry URL>`), with one
   GIF or screenshot from `design/shots/`.
6. **Gotchas** you hit (e.g. "render runs once before update", "rectangle
   rejects NaN"), each one line.

Candidate topics (pick what this game genuinely does): batching graphics
into one patch; particles with a marker line; hgtransform for camera shake
and squash; designing tap-only mechanics; attract-mode bots for the preview
GIF; headless play-testing with scripted taps; fitting under 10,000
characters; visual feedback without sound.

Keep it under ~600 words. Check every claim and snippet by running it.
