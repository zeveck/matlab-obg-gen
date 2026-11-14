function [s, g, f] = nfLevelStart(gameDir, L)
%NFLEVELSTART State at the first tick of level L (the state S0 a solution starts from).
%   Tick k of a solution is the k-th update after S0, at dt = 1/30.
%   Level 1 is entered from the title by a tap; level L > 1 through the
%   game's own banner -> startLevel path. Returns the hidden figure f
%   (close it when done).
old = cd(gameDir);
clear game
g = game();
cd(old);
f = uifigure('Visible', 'off', 'Position', [100 100 800 600]);
ax = uiaxes(f);
hold(ax, 'on');
s = g.init(ax);
s = g.update(s, 1/30, true);          % tap on the title: level 1 starts
if L > 1
    s.mode = 2; s.L = L - 1; s.mt = -1; s.strays = 0;
    s = g.update(s, 1/30, false);     % the banner ends: level L starts
end
end
