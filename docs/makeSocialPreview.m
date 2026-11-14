% Builds docs/images/social-preview.png (1280x640), the GitHub repo's social
% preview: the name over one big button just tapped, its ripples spreading
% out to the edges of the image. Everything is drawn in MATLAB.
%
% Link previews crop hard. Teams shows a small 5:4 thumbnail of only the
% centre of the image (measured: about x 333-948, y 77-569 of 1280x640), so
% the name and the button sit inside x 350-930, y 90-550, drawn big enough to
% read at thumbnail size. The ripples fill the rest, so any crop just trims
% rings and still looks deliberate.
here = fileparts(mfilename('fullpath'));
navy = [.06 .07 .14]; cyan = [.3 .95 1];
violet = [.65 .45 1]; teal = [.2 .9 .8]; gold = [1 .85 .25];

f = uifigure('Visible', 'off', 'Units', 'pixels', 'Position', [50 50 1280 640]);
ax = uiaxes(f, 'Units', 'pixels');
ax.InnerPosition = [1 1 1280 640];   % the plot area itself, not its outer box
ax.YDir = 'reverse';
ax.XTick = []; ax.YTick = []; ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off';
ax.Toolbar.Visible = 'off'; disableDefaultInteractivity(ax); hold(ax, 'on');
patch(ax, [-100 1380 1380 -100], [-100 -100 740 740], navy, 'EdgeColor', 'none');

c = 640 + 365i; t = (0:179)*2*pi/180;   % no repeated end point (it shows as a seam)
R = [170 210 258 314 378 450 530 620 720];
for j = 1:numel(R)   % ripples, fading as they spread
    z = c + R(j)*exp(1i*[t t(1:3)]);   % overlap the ends so there's no cap at the join
    % a line, not a patch outline: patch edges show a seam where they close
    plot(ax, real(z), imag(z), '-', 'LineWidth', 4 - 2*j/numel(R), ...
        'Color', navy + .75*(1 - j/(numel(R) + 1))^1.3*(cyan - navy));   % opaque: no overlap tick at the join
end
% a few balls riding the ripples, in the game colours
b = c + [R(2)*exp(-2.5i) R(4)*exp(-.45i) R(3)*exp(.35i) R(5)*exp(-2.95i) R(6)*exp(-.2i)];
k = [violet; teal; gold; teal; violet];
for j = 1:numel(b)
    plot(ax, real(b(j)), imag(b(j)), 'o', 'MarkerSize', 20 - 2*j, ...
        'MarkerFaceColor', k(j, :), 'Color', k(j, :)/2, 'LineWidth', 2);
end
for j = 1:6   % soft glow
    z = c + (138 + 5*j)*exp(1i*t);
    patch(ax, real(z), imag(z), cyan, 'EdgeColor', 'none', 'FaceAlpha', .06);
end
z = c + 141*exp(1i*t);   % the rim as filled discs, not a thick outline (no corner at the join)
patch(ax, real(z), imag(z), cyan, 'EdgeColor', 'none');
z = c + 134*exp(1i*t);
patch(ax, real(z), imag(z), [.12 .16 .3], 'EdgeColor', 'none');
z = c + 110*exp(1i*t);
patch(ax, real(z), imag(z), cyan, 'EdgeColor', 'none', 'FaceAlpha', .92);
text(ax, real(c), imag(c), 'TAP', 'FontSize', 46, 'FontWeight', 'bold', 'Color', navy, ...
    'HorizontalAlignment', 'center');

% the name, on a soft dark glow so the ripples don't run through it
for j = 1:8
    z = 640 + 112i + (1 - j/9)*(330*cos(t) + 1i*75*sin(t));
    patch(ax, real(z), imag(z), navy, 'EdgeColor', 'none', 'FaceAlpha', .3);
end
text(ax, 640, 112, 'matlab-obg-gen', 'FontSize', 50, 'FontWeight', 'bold', 'Color', 'w', ...
    'HorizontalAlignment', 'center');

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
