function solutionGif(L, outFile)
%SOLUTIONGIF Animated GIF of level L's recorded solution (every 3rd tick).
here = fileparts(mfilename('fullpath'));
gameDir = fullfile(here, '..', '..');
S = load(fullfile(here, '..', 'solutions', sprintf('level-%d.mat', L)));
[s, g, fg] = nfLevelStart(gameDir, L);
close(fg);
f = uifigure('Visible', 'off', 'Position', [100 100 800 600]);
ax = uiaxes(f, 'Units', 'normalized', 'Position', [0 0 1 1]);
ax.XLim = [0 800]; ax.YLim = [0 600]; ax.XTick = []; ax.YTick = [];
ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off'; hold(ax, 'on');
s2 = g.init(ax);
for n = {'bd', 'gl', 'bl', 'pl', 'hb', 'bn', 'fx', 'tx'}
    s.(n{1}) = s2.(n{1});
end
k = 0; first = true;
tapText = text(ax, 300, 590, '', 'FontSize', 16, 'FontWeight', 'bold', ...
    'Color', [1 1 .3], 'HorizontalAlignment', 'center');
lastTap = -99;
while s.mode == 1 && k < 30*120
    k = k + 1;
    p = any(S.taps == k);
    if p, lastTap = k; end
    s = g.update(s, 1/30, p);
    if mod(k, 3) == 0 || p
        tapText.String = repmat('TAP', 1, k - lastTap < 6);
        g.render([], s); drawnow;
        fr = [tempname '.png'];
        exportgraphics(ax, fr, 'Resolution', 48);
        [A, map] = rgb2ind(imread(fr), 128);
        delete(fr);
        if first
            imwrite(A, map, outFile, 'gif', 'LoopCount', Inf, 'DelayTime', 0.1);
            first = false;
        else
            imwrite(A, map, outFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
        end
    end
end
close(f);
fprintf('%s: %d frames, level ended "%s / %s"\n', outFile, ceil(k/3), s.ba, s.bb);
end
