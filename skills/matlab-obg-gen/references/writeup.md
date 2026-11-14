# The "how it was made" write-up

Every game gets a short write-up in `design/WRITEUP.md` that teaches one or
two MATLAB techniques the game genuinely uses. It's for the person to share
if they like. For example, the Mini Hack's Discussions has a Tips & Tricks
channel where posts like this fit well. Never post it for them.

A good write-up teaches **one or two techniques** other people can reuse,
using this game as the worked example. Not a changelog, not a sales pitch.

Shape:

1. **Title** that names the trick: "Particles at 30 fps: one line object,
   200 dots" beats "My game".
2. **The problem** in two sentences (e.g. "50 rectangles made my game run
   at 15 fps").
3. **The technique**, with a short, runnable snippet (≤ 25 lines) that works
   on its own within the game contract, and a sentence on why it works.
4. **Numbers** where you have them (ms per frame before/after, character
   counts). Only real measurements from the harness.
5. **How it's used in the game** (with its play link if it has been shared;
   otherwise leave a `<play link>` placeholder), and one GIF or screenshot
   from `design/shots/`.
6. **Gotchas** you hit (e.g. "render runs once before update", "rectangle
   rejects NaN"), each one line.

Candidate topics (pick what this game genuinely does): batching graphics
into one patch; particles with a marker line; complex numbers for 2-D
positions and rotation; strings as compact tables; designing tap-only
mechanics; attract-mode bots; headless play-testing with scripted taps;
proving levels beatable; fitting under 10,000 characters; visual feedback
without sound.

Keep it under ~600 words, in a friendly voice. Check every claim and
snippet by running it.
