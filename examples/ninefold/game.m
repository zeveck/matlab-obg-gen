function g = game()
% NINEFOLD by Rich Conlan - a one-button marble puzzle.
% Coloured balls drip into a box of nine 3x3 rooms. A glow snakes through
% the rooms and then the whole box; tap to turn whatever is glowing a
% quarter turn clockwise. Pour every ball out of a matching exit before
% the clock runs out. Stragglers and wrong exits are strays: six and
% you're out (a clean level wins one back). Levels are generated from the
% level number, so there is always another one.
%
% How it works: the box is an 11x11 tile grid T (frame included), and a
% ball's tile is one complex number, column + 1i*row (so 50*z is where it
% is drawn). Turning a room is T(i,j) = rot90(T(i,j),-1) for the tiles and
% centre + (z-centre)*1i for the balls: with y pointing down, multiplying
% by 1i IS a clockwise quarter turn. The picture then eases back from -90
% degrees with z.*exp(1i*angle).
g.init = @initGame;
g.update = @updateGame;
g.render = @renderGame;
end

%% ---------- setup ----------
function s = initGame(ax)
ax.YDir = 'reverse';
ax.Color = [.06 .07 .14];
% palette, 3 digits (0-9) per colour: 1-3 balls, 4 glow, 5 red, 6 bar,
% 7 frame, 8-9 floors, 10 white, 11 wall, 12 amber, 13 dim red, 14 grey
s.K = reshape('649287982399833112234112223999567962423678' - 48, 3, [])'/9;
u = [-1-1i 1-1i 1+1i -1+1i];   % unit square corners
[I, J] = ndgrid(1:11);
s.Z = 50*(J(:) + 1i*I(:));      % tile centres in pixels
s.R = 10*ones(11);              % room of each tile (10 = frame)
for k = 1:9
    [i, j] = blk(k);
    s.R(i, j) = k;
    s.Q(k, 1) = 50*(j(2) + 1i*i(2));   % room centres (a column)
end
s.Q(10) = 300+300i;                     % ...and the box's
mk = @(Z, c) patch(ax, 'Faces', reshape(1:numel(Z), 4, [])', 'Vertices', vx(Z), ...
    'FaceVertexCData', c, 'FaceColor', 'flat', 'EdgeColor', 'none');
mk([300+300i + 275*u; 695+135i + 85*real(u) + 7i*imag(u)], s.K([7 6], :));
mk(s.Q(1:9) + 75*u, s.K(8 + mod(1:9, 2), :));
s.bd = mk(s.Z + 0*u, s.K(ones(121, 1), :));
s.gl = rectangle(ax, 'EdgeColor', s.K(4,:), 'LineWidth', 5, 'Curvature', .12);
for k = 1:3
    s.bl(k) = plot(ax, 0, 0, 'o', 'MarkerSize', 24, 'MarkerFaceColor', s.K(k,:), 'Color', s.K(k,:)/2, 'LineWidth', 2);
end
s.pl = plot(ax, 0, 0, '.w', 'MarkerSize', 14);
s.hb = rectangle(ax, 'Position', [610 128 170 14], 'EdgeColor', 'none', 'FaceColor', s.K(4,:));
s.bn = mk(300+290i + 275*real(u) + 115i*imag(u), [0 0 .1]);
s.fx = mk(400+300i + 400*real(u) + 300i*imag(u), s.K(5,:));
% every text in one call: title, level, balls to go, score, strays, help, banner x2
s.tx = text(ax, [680*ones(1, 6) 300 300], [45 105 162 215 265 480 235 325], ...
    {'NINEFOLD', '', '', '', '', sprintf('TAP = TURN THE\nGLOWING ROOM\n\n\n\n\n '), '', ''}, ...
    'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Color', 'w');
set(s.tx, {'FontSize'}, {24; 20; 14; 20; 16; 13; 40; 16});
set(s.tx([1 6 8]), 'Color', s.K(4,:));
set(ax.Children, 'HitTest', 'off', 'PickableParts', 'none');
s.bn.FaceAlpha = .9;
s.P = zeros(0, 3);   % particles: position, velocity (complex), life
[s.best, s.fl, s.mt] = deal(0);
s = newRun(s, 0);
end

function V = vx(Z)
% corners (one row of 4 per quad) -> patch vertices
Z = Z.';
V = [real(Z(:)) imag(Z(:))];
end

function [i, j] = blk(k)
i = 2 + 3*floor((k-1)/3) + (0:2);
j = 2 + 3*mod(k-1, 3) + (0:2);
end

function s = newRun(s, mode)
[s.mode, s.score, s.strays] = deal(mode, 0, 0);
s = startLevel(s, 1 + 4*~mode);
if ~mode   % the title screen, over a demo that plays itself
    s = banner(s, 'NINEFOLD', sprintf(['A glow moves from room to room.\n' ...
        'TAP to turn the glowing room.\nGet each ball out by its colour.\n\nTAP TO START']), Inf);
end
end

%% ---------- levels ----------
function s = startLevel(s, L)
r0 = rng;
z = 'lmonplrsm';   % the nine levels' seeds (as characters), each proven beatable
rng(z(L) - 0);
T = ones(11);
M = [0 422 36 292 16 130 273 295];       % room motifs as 9-bit masks (422 = cup)
F = [0 455 0 0 487 0 36*(L>1) 0 422*(L>1)];   % levels 1-2 by hand; room 2 is always a sealed tube into room 5, the deep cup
for k = 1:9
    b = reshape(bitget(M(randi(min(8, 2+L))), 1:9), 3, 3);
    if L > 2 && rand < .35, b(2, 2) = 2 + (rand < .5); end   % seesaw
    if L > 4 && rand < .3, b(3, :) = 4; end                  % trap doors
    b = rot90(b, randi(4));
    if L < 3 || k == 2 || k == 5, b = reshape(bitget(F(k), 1:9), 3, 3); end
    [i, j] = blk(k);
    T(i, j) = b;
end
if L > 4   % a switch room flips the trap doors
    k = randi(7);
    [i, j] = blk(k + (k > 1) + (k > 3));   % never the chute or the cup
    T(i, j) = 0;
    T(i(2), j(2)) = 6;
end
T(1:2, 6) = [7; 0];   % the inlet
nC = 1 + (L > 3) + (L > 6);
e = [2:5 7:10];
n = 1:max(nC, 1 + (L > 1));
e = e(ceil((n - rand(size(n)))*8/n(end)));   % exits in the floor: one per section, never under the inlet
T(11, e) = 10 + n.*(nC > 1);   % white exits (any colour) until colours arrive
s.nB = 3 + 2*L;
q = randi(nC, 1, 8);
s.q = q(ceil((1:s.nB)/3));   % colours arrive in runs of three
rng(r0);
[s.T, s.L, s.gi, s.gs] = deal(T, L, 5, 5);
s.tl = max(30, 12 + 3*s.nB);
s.t0 = s.tl;
s.si = max(.45, 1.3 - .08*L);   % drip interval
% balls: tile z, previous tile p, colour k, roll direction d, steps waiting w, alive a
[s.b, s.p, s.k, s.d, s.w, s.a] = deal(zeros(1, 0));
[s.dw, s.lb, s.acc, s.st, s.bt] = deal(0);
s.ra = zeros(1, 10);
end

function s = banner(s, a, b, t)
[s.ba, s.bb, s.bt] = deal(a, b, t);
end

%% ---------- update ----------
function s = updateGame(s, dt, p)
s.ra =s.ra.*(abs(s.ra) > .01)*exp(-16*dt);
[s.fl, s.bt, s.mt] = deal(max(0, s.fl - dt), s.bt - dt, s.mt - dt);
P = s.P;
s.P = [P(:, 1) + P(:, 2)*dt, P(:, 2), P(:, 3) - dt];
s.P(s.P(:, 3) < 0, :) = [];
m = s.mode;
if p && (~m || m == 3 && s.mt < 0)
    s = newRun(s, 1);
    return
end
if m < 2
    % (in the demo, a bot tips any room holding two resting balls)
    s = play(s, dt, p || ~m && s.lb ~= s.gs && sum(s.w > 3 & inRoom(s, s.gs)) > 1);
end
% level over: time is up, or everything has dripped in and nothing can still move
e = s.tl <= 0 || isempty(s.q) && all(s.w(s.a == 1) > 35);
if ~m && e
    s = newRun(s, 0);
end
if m == 1 && e
    n = sum(s.a == 1) + numel(s.q);   % stragglers, and balls still waiting at the inlet
    c = ~n;   % clean: a stray back and a bonus
    b = ~n*round(s.tl)*10 + 500*c;
    % at most 2 strays per level, however they happen
    [s.score, s.strays, s.a(:), s.q, s.mode, s.mt, s.fl] = deal(s.score + b, max(0, s.strays + min(2, n) - c), 0, [], 2, 2, .5*(n > 0));
    t = {'CLEAR!', 'TIME UP'};
    s = banner(s, sprintf('LEVEL %d %s', s.L, t{1 + (n > 0)}), sprintf('+%d%s', b, repmat('   CLEAN!', 1, c)), 2);
end
if m == 1 && s.strays >= 6 || m == 2 && s.mt < 0 && s.L > 8   % out of strays, or all nine done
    [s.mode, s.mt, s.best] = deal(3, .9, max(s.best, s.score));
elseif m == 2 && s.mt < 0
    s.mode = 1;
    s = startLevel(s, s.L + 1);
end
if s.mode == 3
    t = {'GAME OVER', 'ALL NINE CLEAR!'};
    s = banner(s, t{1 + (s.strays < 6)}, sprintf('SCORE %d  BEST %d  TAP TO RETRY', s.score, s.best), 1);
end
end

function m = inRoom(s, k)
% live balls in room k (k = 10: anywhere in the box)
m = s.a == 1 & (k == 10 | s.R(ix(s.b)) == k);
end

function i = ix(z)
% grid index of tile z = col + 1i*row
i = sub2ind([11 11], imag(z), real(z));
end

function s = play(s, dt, p)
f = all(abs(s.ra) < .3);   % physics (and the clock) wait for a turn to (nearly) finish
[s.dw, s.tl, s.st] = deal(s.dw + dt, s.tl - dt*f, s.st - dt);
% a tap on a blank room (no pieces, no balls) skips the glow ahead instead
b = p && ~any(s.T(s.R == s.gs)) && ~any(inRoom(s, s.gs));
if p && f && ~b
    s = turn(s, s.gs);
    [s.dw, s.lb, f] = deal(0, s.gs, 0);   % no physics step on the turned grid this tick
elseif s.dw > .6 + .5*(s.gs > 9 || s.lb == s.gs) || b   % 0.6 s per room; longer on the box or after a turn
    o = [1 2 3 6 5 4 7 8 9 10];   % snake order: always a neighbouring room
    s.gi = mod(s.gi, 10) + 1;
    [s.gs, s.dw, s.lb] = deal(o(s.gi), 0, 0);
end
n = numel(s.b) + 1;
if ~isempty(s.q) && s.st <= 0 && free(s, 6+2i, 0)   % drip in at the inlet
    [s.b(n), s.p(n), s.k(n), s.d(n), s.w(n), s.a(n), s.st] = deal(6+2i, 6+2i, s.q(1), 2*mod(n, 2) - 1, 0, 1, s.si);
    s.q(1) = [];
end
s.acc = s.acc + dt*f;
while s.acc >= .17
    s.acc = s.acc - .17;
    s = step(s);
end
end

function ok = free(s, z, k)
v = s.T(imag(z), real(z));
% a hole only takes balls of its own colour (white holes take any)
ok = (~v || v == 5 || v == 10 || v == 10 + k) && ~any(s.a == 1 & s.b == z);
end

function s = turn(s, k)
if k < 10 && any(s.T(s.R == k) == 6)   % the switch room flips every trap door
    o = s.T == 5;
    o(ix(s.b(s.a == 1))) = 0;   % never shut a door on a ball
    s.T = s.T + (s.T == 4) - o;
    return
end
[i, j] = blk(k);
if k > 9   % the whole play area; the inlet and exits stay put
    i = 2:10;
    j = i;
end
s.T(i, j) = rot90(s.T(i, j), -1);
m = inRoom(s, k);
c = s.Q(k)/50;
s.b(m) = c + (s.b(m) - c)*1i;   % a quarter turn clockwise
s.p(m) = s.b(m);
s.ra(k) = s.ra(k) - pi/2;
end

%% ---------- tile physics: one step ----------
function s = step(s)
s.p = s.b;
s.a(s.a == 2) = 0;
[~, o] = sort(imag(s.b), 'descend');
for i = o(s.a(o) == 1)
    z = s.b(i);
    d = s.d(i);
    v = s.T(imag(z) + 1, real(z));
    w = v == 2 || v == 3;   % a seesaw pushes the ball to its low side
    M = [1i, 1i + d, 1i - d, d];   % fall, slide either way, roll on
    if w, M = 2*v - 5; end
    n = 0;
    for m = M
        if free(s, z + m, s.k(i)) && (~real(m) || ~imag(m) || free(s, z + real(m), 0))
            n = m;
            break
        end
    end
    s.T(imag(z) + 1, real(z)) = v + (5 - 2*v)*(w && n ~= 0);   % ...and then tips over
    s.d(i) = d*(1 - 2*(n == 0));
    s.w(i) = (s.w(i) + 1)*~imag(n);   % steps without dropping
    z = z + n;
    s.b(i) = z;
    v = s.T(imag(z), real(z));
    if v > 9   % out through an exit
        [s.a(i), s.score] = deal(2, s.score + 100);
        s.P = [s.P; 50*z + 0*(1:14)', randn(14, 2)*[250; 250i], .3 + .3*rand(14, 1)];
    end
end
end

%% ---------- render ----------
function renderGame(~, s)
% tiles: shape and colour per code, then rotate with their room and the box
T = s.T(:);
q = min(T, 8) + 1;
q(s.R(:) > 9 & T == 1) = 1;   % the frame is one solid border
% corner offsets per tile code, one letter per number: (letter-'n')/10
% empty, wall, seesaw low-left, seesaw low-right, trap shut, trap open, switch, inlet, exit
S = reshape('nnnnnnnnddxdxxdxdxxkxxxxdkxxdxdxdkxkxqdqdmxmxodona{nn{aniisissisffvfvvfv' - 110, 8, [])'/10;
C = s.K([1 11 12 12 5 13 12 10 10], :);
C(8, :) = s.K(10 - 5*(s.T(2, 6) > 0), :);   % the inlet goes red when something blocks it
C = C(q, :);
C(T > 10, :) = s.K(T(T > 10) - 10, :);
[z, e] = place(s, s.Z, s.R);
up(s.bd, 'Vertices', vx(z + 23*e.*(S(q, 1:2:7) + 1i*S(q, 2:2:8))), 'FaceVertexCData', C);
% the glow
w = 75 + 207*(s.gs > 9);
s.gl.Position = [real(s.Q(s.gs)) - w, imag(s.Q(s.gs)) - w, 2*w, 2*w];
s.gl.LineWidth = max(1.5, 9 - 9*s.dw);
s.gl.Visible = s.mode < 2;   % hidden under banners
% balls slide between tiles, and spin with their room
z = place(s, 50*(s.p + (s.b - s.p)*min(1, s.acc/.17)).', s.R(ix(s.b)));
for k = 1:3
    m = s.a > 0 & s.k == k;
    up(s.bl(k), 'XData', [real(z(m)); nan]', 'YData', [imag(z(m)); nan]');
end
up(s.pl, 'XData', [real(s.P(:, 1)); nan]', 'YData', [imag(s.P(:, 1)); nan]');
% HUD and banner
s.hb.Position(3) = max(0, 170*s.tl/s.t0);
set(s.tx([2:5 7 8]), {'String'}, {sprintf('LEVEL %d', s.L); sprintf('%d TO GO', numel(s.q) + sum(s.a == 1)); ...
    sprintf('SCORE %d', s.score); sprintf('STRAYS %d/6', s.strays); s.ba; s.bb});
set([s.tx(7) s.tx(8) s.bn], 'Visible', s.bt > 0);
up(s.fx, 'FaceAlpha', .5*min(1, s.fl)*(s.mode > 0));
end

function up(h, varargin)
% patch and line data redraw even when unchanged, so only set real changes
% (get with a cell of names returns a cell of values)
if ~isequaln(get(h, varargin(1:2:end)), varargin(2:2:end))
    set(h, varargin{:});
end
end

function [z, e] = place(s, z, k)
% rotate points in rooms k by their room's turn, then by the box's
k = k(:);
a = [s.ra(1:9) 0]';
a = a(k);
b = s.ra(10)*(k < 10);
z = s.Q(k) + (z - s.Q(k)).*exp(1i*a);
z = s.Q(10) + (z - s.Q(10)).*exp(1i*b);
e = exp(1i*(a + b));
end
