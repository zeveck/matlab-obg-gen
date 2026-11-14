function [taps, ok, log] = nfSolve(g, s0, beam, maxSteps)
%NFSOLVE Beam search for a CLEAN clear of the level starting at state s0.
%   Decisions are made each time the glow arrives at a stop: turn that
%   room 0-3 times (a blank room: wait, or tap to skip ahead). Every
%   candidate is simulated with the game's own update at dt = 1/30.
%   Returns tap ticks (relative to s0), ok = true when the level ends
%   with every ball delivered and no wrong exit.
if nargin < 3, beam = 12; end
if nargin < 4, maxSteps = 200; end
dt = 1/30;
nodes = struct('s', s0, 'taps', zeros(1, 0), 't', 0, 'v', 0);
taps = []; ok = false; log = '';
for step = 1:maxSteps
    kids = struct('s', {}, 'taps', {}, 't', {}, 'v', {});
    for i = 1:numel(nodes)
        nd = nodes(i);
        s = nd.s;
        blank = ~any(s.T(s.R == s.gs)) && ~any(s.a == 1 & s.R(sub2ind([11 11], imag(s.b), real(s.b))) == s.gs);
        if blank, opts = [0 -1]; else, opts = 0:3; end   % -1 = tap to skip a blank room
        for n = opts
            [c, tp, t] = macro(g, s, max(n, 0) + (n < 0), nd.t, dt);
            k = struct('s', c, 'taps', [nd.taps tp], 't', t, 'v', value(c));
            if c.mode ~= 1   % the level ended
                if c.mode == 2 && contains(c.bb, 'CLEAN')
                    taps = k.taps; ok = true;
                    log = sprintf('solved at step %d, t = %.1f s, %d taps', step, t*dt, numel(taps));
                    return
                end
                continue   % ended dirty: discard
            end
            kids(end+1) = k; %#ok<AGROW>
        end
    end
    if isempty(kids), log = sprintf('dead end at step %d', step); return, end
    % keep the best distinct states
    [~, o] = sort([kids.v], 'descend');
    kids = kids(o);
    keys = arrayfun(@(k) key(k.s), kids, 'UniformOutput', false);
    [~, u] = unique(keys, 'stable');
    nodes = kids(u(1:min(beam, numel(u))));
end
log = sprintf('gave up after %d steps (best value %.0f)', maxSteps, nodes(1).v);
end

function [s, tp, t] = macro(g, s, n, t, dt)
% Tap n times on the current stop (each as soon as a tap is accepted),
% then wait until the glow moves on or the level ends.
tp = zeros(1, 0);
g0 = s.gi;
done = 0;
guard = 0;
while s.mode == 1 && guard < 400
    guard = guard + 1;
    p = done < n && all(abs(s.ra) < .3);
    t = t + 1;
    if p, tp(end+1) = t; done = done + 1; end %#ok<AGROW>
    s = g.update(s, dt, p);
    if s.gi ~= g0 && done >= n, break, end
end
end

function v = value(s)
a = s.a == 1;
v = s.score + 3*sum(imag(s.b(a))) - 4*sum(s.w(a) > 8) - 2*numel(s.q) + s.tl;
end

function k = key(s)
a = s.a == 1;
k = sprintf('%d,', [s.T(:); s.gi; numel(s.q); round(real(s.b(a)))'; round(imag(s.b(a)))'; s.k(a)']);
end
