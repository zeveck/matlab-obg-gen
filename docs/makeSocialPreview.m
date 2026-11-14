% Builds docs/images/social-preview.png (1280x640), the GitHub repo's social
% preview: the name and pitch on the left; on the right, one big button just
% tapped, surrounded by little sketches of what a tap can do in a game.
% Everything is drawn in MATLAB.
here = fileparts(mfilename('fullpath'));
navy = [.06 .07 .14]; cyan = [.3 .95 1]; amber = [1 .7 .2];
violet = [.65 .45 1]; teal = [.2 .9 .8]; gold = [1 .85 .25]; grey = [.75 .8 .92];

f = uifigure('Visible', 'off', 'Units', 'pixels', 'Position', [50 50 1280 640]);
ax = uiaxes(f, 'Units', 'pixels');
ax.InnerPosition = [1 1 1280 640];   % the plot area itself, not its outer box
ax.YDir = 'reverse';
ax.XTick = []; ax.YTick = []; ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off';
ax.Toolbar.Visible = 'off'; disableDefaultInteractivity(ax); hold(ax, 'on');
patch(ax, [-2000 3000 3000 -2000], [-2000 -2000 3000 3000], navy, 'EdgeColor', 'none');

% the button, just tapped: glow, ripple rings, the cap
c = 930 + 330i; t = linspace(0, 2*pi, 120);
for r = [250 205 165]   % ripples fading outwards
    z = c + r*exp(1i*t);
    patch(ax, real(z), imag(z), cyan, 'FaceColor', 'none', 'EdgeColor', cyan, ...
        'EdgeAlpha', .9 - r/320, 'LineWidth', 3);
end
for k = 1:6             % soft glow
    z = c + (120 + 6*k)*exp(1i*t);
    patch(ax, real(z), imag(z), cyan, 'EdgeColor', 'none', 'FaceAlpha', .05);
end
z = c + 120*exp(1i*t);
patch(ax, real(z), imag(z), [.12 .16 .3], 'EdgeColor', cyan, 'LineWidth', 6);
z = c + 92*exp(1i*t);
patch(ax, real(z), imag(z), cyan, 'EdgeColor', 'none', 'FaceAlpha', .9);
text(ax, real(c), imag(c), 'TAP', 'FontSize', 34, 'FontWeight', 'bold', 'Color', navy, ...
    'HorizontalAlignment', 'center');

% around it: what one tap can do
% a jump: a dotted arc and a ball
x = linspace(640, 760, 9); y = 520 - 160*sin(linspace(0, pi, 9));
plot(ax, x, y, '.', 'Color', grey, 'MarkerSize', 12);
plot(ax, 700, 360, 'o', 'MarkerSize', 22, 'MarkerFaceColor', violet, 'Color', violet/2, 'LineWidth', 2);
% a turn: a square mid-rotation with a curved arrow
q = 1180 + 140i; a = pi/7; s = 38*exp(1i*(a + pi/4 + (0:3)*pi/2));
patch(ax, real(q + s), imag(q + s), amber, 'EdgeColor', 'none');
w = q + 70*exp(1i*linspace(-2.4, -.6, 30));
plot(ax, real(w), imag(w), '-', 'Color', amber, 'LineWidth', 4);
h = w(end) + 14*exp(1i*([.7 2.6] + angle(w(end) - w(end-1))));
patch(ax, real([w(end) h]), imag([w(end) h]), amber, 'EdgeColor', 'none');
% a rhythm: a bar with beats and a marker on the beat
rectangle(ax, 'Position', [1060 520 190 14], 'FaceColor', [.15 .17 .28], 'EdgeColor', 'none', 'Curvature', 1);
plot(ax, 1080:38:1240, 527*ones(1, 5), 'o', 'MarkerSize', 7, 'MarkerFaceColor', grey, 'Color', grey);
plot(ax, [1194 1194], [505 549], '-', 'Color', gold, 'LineWidth', 5);
% a burst: particles from a ball
rng(3); p = 720 + 120i + 60*exp(1i*2*pi*rand(1, 22)).*(.4 + .6*rand(1, 22));
plot(ax, real(p), imag(p), '.', 'Color', 'w', 'MarkerSize', 13);
plot(ax, 720, 120, 'o', 'MarkerSize', 18, 'MarkerFaceColor', teal, 'Color', teal/2, 'LineWidth', 2);
% the whole game in one file
rectangle(ax, 'Position', [1110 250 120 46], 'FaceColor', [.12 .14 .25], 'EdgeColor', grey, 'LineWidth', 1.5, 'Curvature', .3);
text(ax, 1170, 273, 'game.m', 'FontName', 'FixedWidth', 'FontSize', 17, 'FontWeight', 'bold', ...
    'Color', grey, 'HorizontalAlignment', 'center');

% the words
text(ax, 60, 175, 'matlab-obg-gen', 'FontSize', 50, 'FontWeight', 'bold', 'Color', 'w');
text(ax, 62, 280, sprintf('Describe a one-button game.\nPlay it in MATLAB.'), ...
    'FontSize', 29, 'FontWeight', 'bold', 'Color', cyan, 'VerticalAlignment', 'middle');
text(ax, 62, 420, sprintf(['A Claude Code plugin that designs, builds\n' ...
    'and play-tests one-button MATLAB games,\nand makes sure every level can be beaten.']), ...
    'FontSize', 18, 'Color', grey, 'VerticalAlignment', 'middle');
% Link previews (Teams, Slack, ...) crop the image to their own card shape,
% so shrink the whole picture by sh about the centre: everything that
% matters sits in the middle ~1000x500 and only background reaches the edges.
sh = .78;
for o = findobj(ax, '-property', 'FontSize')', o.FontSize = o.FontSize*sh; end
for o = findobj(ax, 'Type', 'line')', o.MarkerSize = o.MarkerSize*sh; end
for o = findobj(ax, '-property', 'LineWidth')', o.LineWidth = o.LineWidth*sh; end
ax.XLim = 640 + [-640 640]/sh; ax.YLim = 320 + [-320 320]/sh;   % lock the zoomed-out limits
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
d = dir(out);
fprintf('%s: %dx%d, %.0f KB\n', out, size(A, 2), size(A, 1), d.bytes/1024);
