# Ninefold — brief

**In one sentence:** a real-time marble puzzle where coloured balls drip into
a box split into nine rooms, and your one button turns whichever room (or
the whole box) the roving highlight is on, to pour every ball out of the
right exit before the clock runs out.

**Feeling:** the busy, tactile tension of a tilt-maze toy: lots of little
balls clattering around, the satisfying *clunk* of turning a room so a
trapped cluster pours out, and the panic of a straggler stuck in a corner
as the timer drains.

## What they asked for
- [ ] Coloured balls flowing through a system of traps / pipes / seesaws "etc."
- [ ] Play area divided into **nine subareas**
- [ ] Tap to **rotate the whole screen**
- [ ] Tap to **rotate individual subareas**
- [ ] Real-time puzzle, "a lot going on" (toy-like, tilt-maze feel)
- [ ] (loose) "perhaps flip switches, toggle buttons, and whatnot"
- [ ] Goal: get all the balls through with no stragglers
- [ ] (loose) "maybe there's a timer"
- [ ] (loose) leftover balls count against your score
- [ ] (loose) a series of levels of increasing difficulty
- [ ] (loose) generate more levels, within the code budget

## Who plays it
A gallery visitor with two minutes and no instructions page. They need to
see in five seconds that a glow moves from room to room and a tap turns the
glowing room.

## The one-button idea
A **scanning selector**: the highlight steps through the nine rooms and then
the whole box. A tap turns whatever is lit 90° clockwise, so the skill is
*timing* (catch the right room) plus *reading the flow* (which turn frees
the balls without spilling them into the wrong exit).

## Decisions made for them
- One button can't point, so selection is the roving highlight (with a tap
  keeping the highlight on the same room, so tap-tap turns it twice).
- Switches: a room can be a big switch instead of a maze piece; tapping it
  opens/closes every gate (trap door) in the box.
- Physics is a tile grid (11×11 incl. the box frame; each room 3×3 tiles),
  with smooth animation between steps. That's what fits in 10,000
  characters, and it makes rotating a room literally `rot90` on a block.
- Levels are generated from the level number (same level every time), so
  they never run out.
- Timer per level; balls left over at time-out and balls in the wrong-colour
  exit are "strays". Six strays and the game ends.
