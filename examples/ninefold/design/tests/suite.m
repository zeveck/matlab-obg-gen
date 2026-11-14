% Ninefold play-test suite. Run from anywhere (MCP run_matlab_file).
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', '..', '..', '..', 'skills', 'matlab-obg-gen', 'tools'));   % the skill's tools
gf = fullfile(here, '..', '..', 'game.m');
out = fullfile(here, '..', 'shots');
if ~exist('quick', 'var'), quick = false; end
if ~exist('botSeconds', 'var'), botSeconds = 150; end
old = cd(fileparts(gf)); clear game; g = game(); cd(old);
S = obgsuite(gf, out, 'Bot', @(s, k) bot(s, g), 'BotSeconds', botSeconds, ...
    'Mode', @(s) s.mode, 'Quick', quick, ...
    'Trace', @(s) [s.L s.score s.strays sum(s.a == 1) s.tl sum(s.w > 3 & s.a == 1)]);

function p = bot(s, g)
% Skilled player: when the glow arrives somewhere (or just after a tap),
% look 3 s ahead with and without a tap, using the game's own update.
p = false;
if s.mode == 0 || (s.mode == 3 && s.mt < 0), p = true; return, end
if s.mode ~= 1 || s.dw > 1e-9 && s.dw > 0.034, return, end
if abs(s.ra(s.gs)) > .8, return, end
p = value(sim(s, g, true)) > value(sim(s, g, false)) + 1;
end

function s = sim(s, g, tap)
s = g.update(s, 1/30, tap);
for k = 1:75
    if s.mode ~= 1, break, end
    s = g.update(s, 1/30, false);
end
end

function v = value(s)
a = s.a == 1;
v = s.score - 400*s.strays + 4*sum(imag(s.b(a))) - 6*sum(s.w(a) > 3) + 1000*(s.mode == 2);
end
