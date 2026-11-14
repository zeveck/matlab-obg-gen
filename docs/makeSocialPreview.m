% Builds docs/images/social-preview.png (1280x640), the GitHub repo's social
% preview: the name, one big button just tapped, and the pitch, with little
% sketches of what a tap can do in a game out to the sides.
% Everything is drawn in MATLAB.
%
% Link previews crop hard. Teams shows a small 5:4 thumbnail of only the
% centre of the image (measured: about x 333-948, y 77-569 of 1280x640), so
% everything that matters sits in a centred safe box, x 350-930, y 90-550.
% The side sketches are decoration that may be cropped away.
here = fileparts(mfilename('fullpath'));
navy = [.06 .07 .14]; cyan = [.3 .95 1]; amber = [1 .7 .2];
violet = [.65 .45 1]; teal = [.2 .9 .8]; gold = [1 .85 .25]; grey = [.75 .8 .92];

f = uifigure('Visible', 'off', 'Units', 'pixels', 'Position', [50 50 1280 640]);
ax = uiaxes(f, 'Units', 'pixels');
ax.InnerPosition = [1 1 1280 640];   % the plot area itself, not its outer box
ax.YDir = 'reverse';
ax.XTick = []; ax.YTick = []; ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off';
ax.Toolbar.Visible = 'off'; disableDefaultInteractivity(ax); hold(ax, 'on');
patch(ax, [-100 1380 1380 -100], [-100 -100 740 740], navy, 'EdgeColor', 'none');

% the safe box: name, button, pitch
text(ax, 640, 118, 'matlab-obg-gen', 'FontSize', 44, 'FontWeight', 'bold', 'Color', 'w', ...
    'HorizontalAlignment', 'center');
c = 640 + 322i; t = (0:119)*2*pi/120;   % no repeated end point (it shows as a seam)
for r = [138 116 97]   % ripples fading outwards
    z = c + r*exp(1i*t);
    patch(ax, real(z), imag(z), cyan, 'FaceColor', 'none', 'EdgeColor', cyan, ...
        'EdgeAlpha', 1.25 - r/130, 'LineWidth', 3);
end
for k = 1:5            % soft glow
    z = c + (78 + 4*k)*exp(1i*t);
    patch(ax, real(z), imag(z), cyan, 'EdgeColor', 'none', 'FaceAlpha', .06);
end
z = c + 78*exp(1i*t);
patch(ax, real(z), imag(z), [.12 .16 .3], 'EdgeColor', cyan, 'LineWidth', 5);
z = c + 60*exp(1i*t);
patch(ax, real(z), imag(z), cyan, 'EdgeColor', 'none', 'FaceAlpha', .9);
text(ax, real(c), imag(c), 'TAP', 'FontSize', 26, 'FontWeight', 'bold', 'Color', navy, ...
    'HorizontalAlignment', 'center');
text(ax, 640, 518, sprintf('Describe a one-button game.\nPlay it in MATLAB.'), ...
    'FontSize', 25, 'FontWeight', 'bold', 'Color', cyan, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

% out to the sides: what one tap can do
% a burst: particles from a ball
rng(3); p = 210 + 170i + 55*exp(1i*2*pi*rand(1, 22)).*(.4 + .6*rand(1, 22));
plot(ax, real(p), imag(p), '.', 'Color', 'w', 'MarkerSize', 12);
plot(ax, 210, 170, 'o', 'MarkerSize', 17, 'MarkerFaceColor', teal, 'Color', teal/2, 'LineWidth', 2);
% a jump: a dotted arc and a ball
x = linspace(110, 250, 9); y = 500 - 150*sin(linspace(0, pi, 9));
plot(ax, x, y, '.', 'Color', grey, 'MarkerSize', 12);
plot(ax, 180, 350, 'o', 'MarkerSize', 22, 'MarkerFaceColor', violet, 'Color', violet/2, 'LineWidth', 2);
% a turn: a square mid-rotation with a curved arrow
q = 1080 + 170i; a = pi/7; s = 36*exp(1i*(a + pi/4 + (0:3)*pi/2));
patch(ax, real(q + s), imag(q + s), amber, 'EdgeColor', 'none');
w = q + 66*exp(1i*linspace(-2.4, -.6, 30));
plot(ax, real(w), imag(w), '-', 'Color', amber, 'LineWidth', 4);
h = w(end) + 14*exp(1i*([.7 2.6] + angle(w(end) - w(end-1))));
patch(ax, real([w(end) h]), imag([w(end) h]), amber, 'EdgeColor', 'none');
% the whole game in one file
rectangle(ax, 'Position', [1020 312 120 46], 'FaceColor', [.12 .14 .25], 'EdgeColor', grey, ...
    'LineWidth', 1.5, 'Curvature', .3);
text(ax, 1080, 335, 'game.m', 'FontName', 'FixedWidth', 'FontSize', 17, 'FontWeight', 'bold', ...
    'Color', grey, 'HorizontalAlignment', 'center');
% a rhythm: a bar with beats and a marker on the beat
rectangle(ax, 'Position', [985 470 190 14], 'FaceColor', [.15 .17 .28], 'EdgeColor', 'none', 'Curvature', 1);
plot(ax, 1005:38:1165, 477*ones(1, 5), 'o', 'MarkerSize', 7, 'MarkerFaceColor', grey, 'Color', grey);
plot(ax, [1119 1119], [455 499], '-', 'Color', gold, 'LineWidth', 5);

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
% what Teams shows: the centre crop, at thumbnail size
T = imresize(A(77:569, 333:948, :), [96 120]);
imwrite(imresize(T, 3, 'nearest'), fullfile(tempdir, 'social-preview-teams.png'));
d = dir(out);
fprintf('%s: %dx%d, %.0f KB\n', out, size(A, 2), size(A, 1), d.bytes/1024);
