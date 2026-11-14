function showLevel(L, ticks, outFile)
%SHOWLEVEL Screenshot level L after its solution has run for `ticks` ticks
%   (0 = the very start), and print the tile grid.
here = fileparts(mfilename('fullpath'));
gameDir = fullfile(here, '..', '..');
S = load(fullfile(here, '..', 'solutions', sprintf('level-%d.mat', L)));
[s, g, fg] = nfLevelStart(gameDir, L);
close(fg);
f = uifigure('Visible', 'off', 'Position', [100 100 800 600]);
ax = uiaxes(f, 'Units', 'normalized', 'Position', [0 0 1 1]);
ax.XLim = [0 800]; ax.YLim = [0 600]; ax.XTick = []; ax.YTick = [];
ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off'; hold(ax, 'on');
s2 = g.init(ax);                       % fresh graphics in this figure
s = copyHandles(s, s2);
for k = 1:ticks
    s = g.update(s, 1/30, any(S.taps == k));
end
g.render([], s); drawnow;
exportgraphics(ax, outFile, 'Resolution', 72);
close(f);
disp(s.T);
fprintf('taps in the solution: %s\n', mat2str(S.taps));
end

function s = copyHandles(s, s2)
for n = {'bd', 'gl', 'bl', 'pl', 'hb', 'bn', 'fx', 'tx'}
    s.(n{1}) = s2.(n{1});
end
end
