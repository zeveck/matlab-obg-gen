function R = obgtest(gameFile, varargin)
%OBGTEST Headless play-test for a One-Button Game Minihack game.m.
%
%   R = obgtest(gameFile, Name, Value, ...)
%
%   Mirrors minihackContest.play (800x600 uifigure + uiaxes configured the
%   same way) but in a hidden window, with a fixed dt and scripted input,
%   so a game can be played deterministically, measured and screenshotted.
%
%   Options:
%     Frames   number of update/render ticks to run        (default 300)
%     Dt       seconds per tick, as the harness passes it  (default 1/30)
%     Presses  vector of tick indices on which pressed=true (default [])
%     Policy   @(state, k) -> logical, a bot that decides each tick from
%              the game state. Overrides Presses when given.
%     Shots    tick indices to screenshot (0 = after init) (default [])
%     OutDir   folder for screenshots / gif                 (default tempdir)
%     Tag      filename prefix for outputs                  (default 'run')
%     Gif      [first last step] ticks to film into <Tag>.gif ([] = none)
%     Trace    @(state) -> numeric row, logged every tick   (default none)
%     Seed     rng seed set before init                     (default 1)
%     StopWhen @(state) -> logical, end the run early when true
%
%   R fields: ok, err (report text), errTick, ticks, presses (ticks fired),
%   shots (file list), gif, trace (matrix), msPerTick (update+render+drawnow
%   per tick), objInit / objEnd (graphics object counts: growth after init
%   means the game creates graphics outside init), state (final state).

p = inputParser;
p.addParameter('Frames', 300);
p.addParameter('Dt', 1/30);
p.addParameter('Presses', []);
p.addParameter('Policy', []);
p.addParameter('Shots', []);
p.addParameter('OutDir', tempdir);
p.addParameter('Tag', 'run');
p.addParameter('Gif', []);
p.addParameter('Trace', []);
p.addParameter('Seed', 1);
p.addParameter('StopWhen', []);
p.parse(varargin{:});
o = p.Results;

gameFile = char(gameFile);
if ~isfile(gameFile), error('obgtest:noFile', 'No such file: %s', gameFile); end
gameDir = fileparts(which(gameFile));
if isempty(gameDir), gameDir = fileparts(gameFile); end
if isempty(gameDir), gameDir = pwd; end
if ~isfolder(o.OutDir), mkdir(o.OutDir); end

oldPath = addpath(gameDir, '-begin');
cleanP = onCleanup(@() path(oldPath));
oldDir = cd(gameDir);   % the current folder outranks the path
cleanD = onCleanup(@() cd(oldDir));
clear game
rehash

R = struct('ok', false, 'err', '', 'errTick', NaN, 'ticks', 0, ...
    'presses', [], 'shots', {{}}, 'gif', '', 'trace', [], ...
    'msPerTick', [], 'objInit', NaN, 'objEnd', NaN, 'state', []);

warnState = warning('off', 'MATLAB:graphics:HardwareUnavailable');
cleanW = onCleanup(@() warning(warnState));

fig = uifigure('Visible', 'off', 'Units', 'pixels', ...
    'Position', [100 100 800 600], 'Resize', 'off');
cleanF = onCleanup(@() close(fig));
ax = uiaxes(fig, 'Units', 'normalized', 'Position', [0 0 1 1]);
ax.XLim = [0 800]; ax.YLim = [0 600];
ax.XTick = []; ax.YTick = [];
ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off';
ax.Toolbar.Visible = 'off';
disableDefaultInteractivity(ax);
hold(ax, 'on');

rng(o.Seed);
k = 0;
gifFrames = {};
try
    g = game();
    state = g.init(ax);
    g.render([], state);
    drawnow
    R.objInit = numel(findall(fig));
    if any(o.Shots == 0), R.shots{end+1} = shot(ax, o, 0); end
    if ~isempty(o.Gif) && o.Gif(1) == 0, gifFrames{end+1} = grab(ax); end

    ms = zeros(1, o.Frames);
    for k = 1:o.Frames
        if ~isempty(o.Policy)
            pressed = logical(o.Policy(state, k));
        else
            pressed = any(o.Presses == k);
        end
        if pressed, R.presses(end+1) = k; end
        t0 = tic;
        state = g.update(state, o.Dt, pressed);
        g.render([], state);
        drawnow
        ms(k) = 1000 * toc(t0);
        if ~isempty(o.Trace)
            R.trace(k, :) = double(o.Trace(state));
        end
        if any(o.Shots == k), R.shots{end+1} = shot(ax, o, k); end
        if ~isempty(o.Gif) && k >= o.Gif(1) && k <= o.Gif(2) && ...
                mod(k - o.Gif(1), o.Gif(3)) == 0
            gifFrames{end+1} = grab(ax); %#ok<AGROW>
        end
        R.ticks = k;
        if ~isempty(o.StopWhen) && o.StopWhen(state), break; end
    end
    R.msPerTick = ms(1:R.ticks);
    R.objEnd = numel(findall(fig));
    R.state = state;
    R.ok = true;
catch ME
    R.err = getReport(ME, 'extended', 'hyperlinks', 'off');
    R.errTick = k;
    try R.shots{end+1} = shot(ax, o, k); catch, end
end

if ~isempty(gifFrames)
    R.gif = fullfile(o.OutDir, [o.Tag '.gif']);
    writeGif(gifFrames, R.gif, o.Gif(3) * o.Dt);
end
end

function f = shot(ax, o, k)
f = fullfile(o.OutDir, sprintf('%s-t%04d.png', o.Tag, k));
exportgraphics(ax, f, 'Resolution', 96);
end

function im = grab(ax)
f = [tempname '.png'];
exportgraphics(ax, f, 'Resolution', 48);
im = imread(f);
delete(f);
end

function writeGif(frames, file, delay)
for i = 1:numel(frames)
    [A, map] = rgb2ind(frames{i}, 128);
    if i == 1
        imwrite(A, map, file, 'gif', 'LoopCount', Inf, 'DelayTime', delay);
    else
        imwrite(A, map, file, 'gif', 'WriteMode', 'append', 'DelayTime', delay);
    end
end
end
