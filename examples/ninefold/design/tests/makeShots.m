% README screenshots and GIFs for Ninefold, taken while replaying the proven
% full run (title -> nine levels -> win), so every image is real play.
here = fileparts(mfilename('fullpath'));
gameDir = fullfile(here, '..', '..');
out = fullfile(here, '..', 'media');
if ~isfolder(out), mkdir(out); end
T = cell(1, 9);
for L = 1:9
    S = load(fullfile(here, '..', 'solutions', sprintf('level-%d.mat', L)));
    T{L} = S.taps;
end
old = cd(gameDir); clear game; g = game(); cd(old);
f = uifigure('Visible', 'off', 'Position', [100 100 800 600]);
ax = uiaxes(f, 'Units', 'normalized', 'Position', [0 0 1 1]);
ax.XLim = [0 800]; ax.YLim = [0 600]; ax.XTick = []; ax.YTick = [];
ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off'; ax.Toolbar.Visible = 'off';
disableDefaultInteractivity(ax); hold(ax, 'on');
s = g.init(ax);
shot = @(name) exportgraphics(ax, fullfile(out, [name '.png']), 'Resolution', 96);
g.render([], s); drawnow; shot('title');
% the title GIF: 4 s of the demo behind the title screen
gifTitle = fullfile(out, 'title.gif'); first = true;
for k = 1:120
    s = g.update(s, 1/30, false);
    if mod(k, 3) == 0
        g.render([], s); drawnow;
        first = addFrame(ax, gifTitle, first);
    end
end
% start, then replay each level's solution
s = g.update(s, 1/30, true);
L0 = 0; k0 = 0; k = 0; took = struct();
gifPlay = fullfile(out, 'play.gif'); firstPlay = true;
while s.mode ~= 3 && k < 30*60*6
    k = k + 1;
    p = false;
    if s.mode == 1
        if s.L ~= L0, L0 = s.L; k0 = k; end
        p = any(T{s.L} == k - k0 + 1);
    end
    s = g.update(s, 1/30, p);
    g.render([], s);
    j = k - k0;   % ticks into the current level
    tag = sprintf('L%d', s.L);
    if s.mode == 1 && any(s.L == [1 4 7 8]) && j == 200 && ~isfield(took, tag)
        drawnow; shot(sprintf('level-%d', s.L)); took.(tag) = true;
    end
    if s.mode == 2 && contains(s.bb, 'CLEAN') && s.L == 4 && ~isfield(took, 'clear')
        drawnow; shot('level-clear'); took.clear = true;
    end
    if s.L == 7 && s.mode == 1 && j >= 90 && j < 90 + 30*8 && mod(j, 3) == 0
        drawnow; firstPlay = addFrame(ax, gifPlay, firstPlay);   % 8 s of level 7
    end
end
for k = 1:40, s = g.update(s, 1/30, false); end
g.render([], s); drawnow; shot('win');
close(f);
fprintf('ended in mode %d, banner "%s / %s"\n', s.mode, s.ba, s.bb);
disp(struct2table(dir(fullfile(out, '*.*'))).name(3:end)');

function first = addFrame(ax, file, first)
fr = [tempname '.png'];
exportgraphics(ax, fr, 'Resolution', 60);
[A, map] = rgb2ind(imread(fr), 128);
delete(fr);
if first
    imwrite(A, map, file, 'gif', 'LoopCount', Inf, 'DelayTime', 0.1);
else
    imwrite(A, map, file, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
end
first = false;
end
