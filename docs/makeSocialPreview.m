% Builds docs/images/social-preview.png (1280x640), the GitHub repo's social
% preview: the name, then "describe it -> play it": a speech bubble with a
% game idea, an arrow, and a one-button console playing that game.
% Everything is drawn in MATLAB.
%
% Link previews crop. Teams shows a 120x96 (5:4) thumbnail: it fits the
% full height and keeps only the centre 800 px of width (x 240-1040,
% measured from a real Teams chat). So everything sits inside x 270-1010,
% nothing straddles the crop lines, and the sides are only a dot grid.
here = fileparts(mfilename('fullpath'));
navy = [.06 .07 .14]; cyan = [.3 .95 1]; amber = [1 .7 .2];
violet = [.65 .45 1]; teal = [.2 .9 .8]; gold = [1 .85 .25]; grey = [.75 .8 .92];
body = [.16 .19 .33];

f = uifigure('Visible', 'off', 'Units', 'pixels', 'Position', [50 50 1280 640]);
ax = uiaxes(f, 'Units', 'pixels');
ax.InnerPosition = [1 1 1280 640];   % the plot area itself, not its outer box
ax.YDir = 'reverse';
ax.XTick = []; ax.YTick = []; ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off';
ax.Toolbar.Visible = 'off'; disableDefaultInteractivity(ax); hold(ax, 'on');
patch(ax, [-100 1380 1380 -100], [-100 -100 740 740], navy, 'EdgeColor', 'none');
[gx, gy] = meshgrid(20:40:1260, 20:40:620);   % a faint dot grid to the edges
plot(ax, gx(:), gy(:), '.', 'Color', navy + .12, 'MarkerSize', 7);

text(ax, 640, 80, 'matlab-obg-gen', 'FontSize', 48, 'FontWeight', 'bold', 'Color', 'w', ...
    'HorizontalAlignment', 'center');

% describe it: a speech bubble with an idea
rectangle(ax, 'Position', [275 245 265 215], 'Curvature', .25, 'FaceColor', [.9 .93 1], 'EdgeColor', 'none');
patch(ax, [318 360 298], [455 455 505], [.9 .93 1], 'EdgeColor', 'none');   % its tail
text(ax, 407, 352, sprintf('"A ball that\njumps the\nspikes when\nI tap"'), 'FontSize', 21, ...
    'FontWeight', 'bold', 'Color', navy, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

% -> play it
patch(ax, 553 + [0 34 34 54 34 34 0], 350 + [-5 -5 -16 0 16 5 5], cyan, 'EdgeColor', 'none');

% the console, playing that game
P = @(x, y) deal(615 + (x - 445), 150 + (y - 160));   % placed at x 615-1005, y 150-555
[x, y] = P(445, 160);
rectangle(ax, 'Position', [x y 390 405], 'Curvature', .16, 'FaceColor', body, ...
    'EdgeColor', cyan*.7, 'LineWidth', 3);
[x, y] = P(475, 185);
rectangle(ax, 'Position', [x y 330 210], 'Curvature', .06, ...
    'FaceColor', [.04 .05 .1], 'EdgeColor', [.08 .1 .2], 'LineWidth', 3);
[x, y] = P([479 801 801 479], [360 360 389 389]);
patch(ax, x, y, [.13 .3 .36], 'EdgeColor', 'none');
[x, y] = P([479 801], [360 360]);
plot(ax, x, y, '-', 'Color', teal, 'LineWidth', 3);
[x, y] = P([690 708 726 744 762], [360 326 360 326 360]);
patch(ax, x, y, amber, 'EdgeColor', 'none');   % spikes
arc = @(x) 346 - 105*sin(pi*(x - 540)/260);   % the jump, over the spikes
u = linspace(540, 800, 15); u = u(u < 790 & abs(u - 650) > 20);
[x, y] = P(u, arc(u));
plot(ax, x, y, '.', 'Color', grey, 'MarkerSize', 9);
[x, y] = P(650, arc(650));
plot(ax, x, y, 'o', 'MarkerSize', 24, 'MarkerFaceColor', violet, 'Color', violet/2, 'LineWidth', 2.5);
[x, y] = P([575 765], [245 225]);
plot(ax, x, y, 'o', 'MarkerSize', 9, 'MarkerFaceColor', gold, 'Color', gold*.6);
[x, y] = P(489, 205);
text(ax, x, y, 'SCORE 120', 'FontSize', 10, 'FontWeight', 'bold', 'Color', grey);
% its one button, just pressed
[x, y] = P(640, 480); b = x + 1i*y; t = (0:179)*2*pi/180;
for r = [74 64]   % press ripples
    z = b + r*exp(1i*[t t(1:3)]);   % overlap the ends so there's no cap at the join
    plot(ax, real(z), imag(z), '-', 'LineWidth', 3, 'Color', body + (.25 + .25*(r == 64))*(cyan - body));
end
z = b + 54*exp(1i*t);
patch(ax, real(z), imag(z), cyan*.55, 'EdgeColor', 'none');
z = b + 3i + 50*exp(1i*t);
patch(ax, real(z), imag(z), cyan, 'EdgeColor', 'none');
z = b - 12 - 14i + 18*exp(1i*t);   % highlight
patch(ax, real(z), imag(z), 'w', 'EdgeColor', 'none', 'FaceAlpha', .35);

ax.XLim = [0 1280]; ax.YLim = [0 640];   % drawing can re-fit the limits: lock them
ax.XLimMode = 'manual'; ax.YLimMode = 'manual';
drawnow;

tmp = [tempname '.png'];
exportgraphics(f, tmp, 'Resolution', 96, 'Padding', 'figure');   % the whole 1280x640 figure, no trimming
A = imread(tmp); delete(tmp);
% centre it on an exact 1280x640 navy canvas (trimming or padding a few px,
% never stretching)
B = repmat(reshape(uint8(255*navy), 1, 1, 3), 640, 1280);
h = min(640, size(A, 1)); w = min(1280, size(A, 2));
ra = floor((size(A, 1) - h)/2) + (1:h); ca = floor((size(A, 2) - w)/2) + (1:w);
rb = floor((640 - h)/2) + (1:h); cb = floor((1280 - w)/2) + (1:w);
B(rb, cb, :) = A(ra, ca, :);
A = B;
out = fullfile(here, 'images', 'social-preview.png');
imwrite(A, out);
close(f);
% what Teams shows: full height, centre 800 px, at thumbnail size (4x, to look at)
T = imresize(A(:, 241:1040, :), [96 120]);
imwrite(imresize(T, 4, 'nearest'), fullfile(tempdir, 'social-preview-teams.png'));
d = dir(out);
fprintf('%s: %dx%d, %.0f KB\n', out, size(A, 2), size(A, 1), d.bytes/1024);
