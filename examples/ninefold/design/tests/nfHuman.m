function [ok, info] = nfHuman(gameDir, L, seedNo, beam, depth)
%NFHUMAN Can a player with human reaction times clean level L?
%   Plays closed-loop like a person: each time the glow reaches a room it
%   decides (a short beam search from what it can see) how many times to
%   turn it, then taps 2-8 ticks late (65-265 ms reaction), and each extra
%   tap waits for the previous turn to finish plus 0-4 ticks. Blank rooms
%   are skipped. It re-decides at every room from the ACTUAL state, so
%   timing slop is absorbed the way a person would. ok = clean clear.
if nargin < 4, beam = 5; end
if nargin < 5, depth = 8; end
rs = RandStream('mt19937ar', 'Seed', 1000*L + seedNo);
[s, g, fg] = nfLevelStart(gameDir, L);
cl = onCleanup(@() close(fg));
dt = 1/30; k = 0; taps = 0;
while s.mode == 1 && k < 30*120
    n = plan(g, s, beam, depth);
    gi = s.gi;
    wait = randi(rs, [2 8]);            % reaction to the glow arriving
    done = 0;
    while s.mode == 1 && (s.gi == gi || done < n) && k < 30*120
        p = false;
        if s.gi ~= gi, done = n; end        % too late: the glow moved on
        if done < n
            if wait > 0
                wait = wait - 1;
            elseif all(abs(s.ra) < .3)
                p = true; done = done + 1; taps = taps + 1;
                wait = randi(rs, [0 4]);    % watch the turn, then a beat
            end
        end
        k = k + 1;
        s = g.update(s, dt, p);
    end
end
ok = s.mode == 2 && contains(s.bb, 'CLEAN');
info = sprintf('%s at %.1f s, %d taps, banner "%s / %s"', pick(ok, 'CLEAN', 'FAILED'), k*dt, taps, s.ba, s.bb);
end

function n = plan(g, s, beam, depth)
% the player's judgement: a short beam search over the next few rooms,
% returning the first move of the best line (no timing slop in thought)
if isBlank(s), n = 1; return, end
nodes = struct('s', {}, 'f', {}, 'v', {});
for o = 0:3
    c = macro(g, s, o);
    if isClean(c), n = o; return, end
    if c.mode == 1, nodes(end+1) = struct('s', c, 'f', o, 'v', value(c)); end %#ok<AGROW>
end
n = 0;
if isempty(nodes), return, end
for d = 2:depth
    kids = struct('s', {}, 'f', {}, 'v', {});
    for i = 1:numel(nodes)
        x = nodes(i).s;
        if isBlank(x), opts = 1; else, opts = 0:3; end
        for o = opts
            c = macro(g, x, o);
            if isClean(c), n = nodes(i).f; return, end
            if c.mode == 1, kids(end+1) = struct('s', c, 'f', nodes(i).f, 'v', value(c)); end %#ok<AGROW>
        end
    end
    if isempty(kids), break, end
    [~, o] = sort([kids.v], 'descend');
    nodes = kids(o(1:min(beam, end)));
end
n = nodes(1).f;
end

function b = isBlank(s)
b = ~any(s.T(s.R == s.gs)) && ~any(s.a == 1 & s.R(sub2ind([11 11], imag(s.b), real(s.b))) == s.gs);
end

function b = isClean(s)
b = s.mode == 2 && contains(s.bb, 'CLEAN');
end

function s = macro(g, s, n)
g0 = s.gi; done = 0; guard = 0;
while s.mode == 1 && guard < 400
    guard = guard + 1;
    p = done < n && all(abs(s.ra) < .3);
    done = done + p;
    s = g.update(s, 1/30, p);
    if s.gi ~= g0 && done >= n, break, end
end
end

function v = value(s)
a = s.a == 1;
v = s.score + 3*sum(imag(s.b(a))) - 4*sum(s.w(a) > 8) - 2*numel(s.q) + s.tl;
end

function t = pick(c, a, b)
if c, t = a; else, t = b; end
end
