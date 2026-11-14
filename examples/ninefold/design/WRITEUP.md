# How Ninefold was made (a write-up to share if you like)

**Title:** Your 10,000 characters are counted after MATLAB re-spaces your code (and two ways to win them back)

My first draft of Ninefold, a one-button marble puzzle, *looked* like about
8,000 characters. `minihackContest.validate` said 16,410.

## Why

The limit is measured on `tree2str(mtree(file,'-file'))`. That strips
comments, but it also **re-prints the code**: four spaces of indentation per
nesting level (function bodies included), spaces around operators, spaces
inside every `f( x )` and `a( i, j )`, and commas between numbers in brackets:

```matlab
s.P(:,1:2) = [x y];             % what I typed: 19 characters
s.P( :, 1:2 ) = [ x, y ];       % what is counted: 25
```

In my draft, **6,132 of the 16,410 counted characters were spaces**, and
3,336 of those were indentation. Check yours:

```matlab
t = char(tree2str(mtree('game.m','-file')));
fprintf('%d chars, %d spaces\n', strlength(t), sum(t == ' '))
```

So short variable names barely help. What costs is the **number of
statements, index operations and nesting levels**.

## Trick 1: strings are counted verbatim, so keep tables in strings

A numeric table is padded with a comma and a space per number. A string
isn't. Ninefold's 14-colour palette is one string, 3 digits per colour:

```matlab
K = reshape('934287982399833112234112223999567962423678' - 48, 3, [])'/9;
```

The corner offsets of every tile shape (9 shapes × 8 numbers) are a
72-letter string decoded with `(letter - 'n')/10`.

## Trick 2: complex numbers fold x and y into one value

A ball's tile is `z = col + 1i*row`, so it's drawn at `50*z`. Moves are
complex steps (`[1i, 1i+d, 1i-d, d]` = fall, slide either way, roll on). The
puzzle's core move, turning a 3×3 room a quarter turn clockwise, is:

```matlab
T(i,j) = rot90(T(i,j), -1);     % the tiles
z = c + (z - c)*1i;             % the balls (y points down, so *1i is clockwise)
```

and the animation is `z.*exp(1i*angle)` on every tile corner and ball. One
value per point instead of two halved the index operations. That rewrite
alone won back about 470 counted characters.

With these two tricks, plus merging all 121 tiles into one patch, the same
game fits in 9,927 characters.

## Bonus: a measured performance trap

Setting a **patch's `Vertices` or a line's `XData` to the same value it
already has still forces a full redraw**: 17–35 ms per frame in my tests,
against a 33 ms budget. Text `String`, rectangle `Position` and `Visible`
don't. Guard your data sets:

```matlab
function up(h, varargin)   % set only when something really changed
if ~isequaln(get(h, varargin(1:2:end)), varargin(2:2:end))
    set(h, varargin{:});
end
end
```

(`get` with a cell array of property names returns a cell array of values,
so one comparison covers them all. Use `isequaln`, because NaN-padded line
data never compares equal with `isequal`.) In Ninefold, redrawing a frame
where nothing changed takes **63 ms** if the board patch and ball lines are
re-set, and **4.5 ms** with the guard. Watch which way round your vectors
are, too: lines store `XData` as a row, so a column never compares equal and
the guard silently stops working.

**Gotchas:** `render` is called once right after `init`, before any
`update`. `delete` is banned, so pool your graphics. And `rowVector(colIdx)`
returns a row, which quietly broadcasts to a matrix when you add a column.

*Play Ninefold: `https://www.mathworks.com/matlabcentral/communitycontests/contests/10/entries/16598`*
