% Builds docs/images/social-preview.png (1280x640), the GitHub repo's social
% preview: the name over a little one-button game console, its screen
% showing a game mid-jump and its single big button just pressed.
% Everything is drawn in MATLAB.
%
% Link previews crop hard. Teams shows a small 5:4 thumbnail of only the
% centre of the image (measured: about x 333-948, y 77-569 of 1280x640), so
% the name and the console sit inside x 350-930, y 90-550, drawn big enough
% to read at thumbnail size. A dot grid runs to the edges, so any crop looks
% deliberate.
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

text(ax, 640, 100, 'matlab-obg-gen', 'FontSize', 46, 'FontWeight', 'bold', 'Color', 'w', ...
    'HorizontalAlignment', 'center');

% the pitch out to the sides (seen on GitHub; Teams crops it away)
text(ax, 180, 330, sprintf('Describe a\none-button\ngame'), 'FontSize', 26, 'FontWeight', 'bold', ...
    'Color', grey, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(ax, 1095, 330, sprintf('Play it\nin MATLAB'), 'FontSize', 26, 'FontWeight', 'bold', ...
    'Color', cyan, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
for x0 = [282 958]   % arrows: idea -> console -> play (outside the Teams crop)
    patch(ax, x0 + [0 30 30 46 30 30 0], 330 + [-3 -3 -11 0 11 3 3], grey*.7, 'EdgeColor', 'none');
end

% the console
t = (0:179)*2*pi/180;
rectangle(ax, 'Position', [445 160 390 405], 'Curvature', .16, 'FaceColor', body, ...
    'EdgeColor', cyan*.7, 'LineWidth', 3);

% its screen: a little game, mid-jump
sx = [475 805]; sy = [185 395];
rectangle(ax, 'Position', [sx(1) sy(1) diff(sx) diff(sy)], 'Curvature', .06, ...
    'FaceColor', [.04 .05 .1], 'EdgeColor', [.08 .1 .2], 'LineWidth', 3);
patch(ax, [sx(1)+4 sx(2)-4 sx(2)-4 sx(1)+4], [360 360 sy(2)-6 sy(2)-6], [.13 .3 .36], 'EdgeColor', 'none');
plot(ax, [sx(1)+4 sx(2)-4], [360 360], '-', 'Color', teal, 'LineWidth', 3);
patch(ax, [690 708 726 744 762], [360 326 360 326 360], amber, 'EdgeColor', 'none');   % spikes
arc = @(x) 346 - 105*sin(pi*(x - 540)/260);   % the jump, over the spikes
x = linspace(540, 800, 15); k = x < 790 & abs(x - 650) > 20;
plot(ax, x(k), arc(x(k)), '.', 'Color', grey, 'MarkerSize', 10);
plot(ax, 650, arc(650), 'o', 'MarkerSize', 26, 'MarkerFaceColor', violet, ...
    'Color', violet/2, 'LineWidth', 2.5);
plot(ax, [575 765], [245 225], 'o', 'MarkerSize', 10, 'MarkerFaceColor', gold, 'Color', gold*.6);
text(ax, sx(1) + 14, sy(1) + 20, 'SCORE 120', 'FontSize', 11, 'FontWeight', 'bold', 'Color', grey);

% its one button, just pressed
b = 640 + 480i;
for r = [74 64]   % press ripples
    z = b + r*exp(1i*[t t(1:3)]);
    plot(ax, real(z), imag(z), '-', 'LineWidth', 3, 'Color', body + (r == 64)*.5*(cyan - body) + (r == 74)*.25*(cyan - body));
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
% what Teams shows: the centre crop, at thumbnail size (3x, to look at)
T = imresize(A(77:569, 333:948, :), [96 120]);
imwrite(imresize(T, 3, 'nearest'), fullfile(tempdir, 'social-preview-teams.png'));
d = dir(out);
fprintf('%s: %dx%d, %.0f KB\n', out, size(A, 2), size(A, 1), d.bytes/1024);
