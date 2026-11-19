function S = obgsuite(gameFile, outDir, varargin)
%OBGSUITE Standard play-test suite for a One-Button Game game.m.
%
%   S = obgsuite(gameFile, outDir, Name, Value, ...)
%   S = obgsuite(gameFile, Name, Value, ...)   outDir: tempdir/obgsuite
%
%   Runs (each in a fresh hidden window, via obgtest):
%     idle     no input for 15 s; preview GIF of the first 5 s; shots
%     spam     a tap every tick for 20 s (mashing / auto-repeat)
%     random   random taps (p per tick) for 30 s, over 5 seeds
%     bot      the skilled bot for BotSeconds (if Bot given); shots + GIF
%     bad      one tap to start, then nothing for 10 s, then a tap every
%              2 s for 10 s (dies -> game over -> restart -> ...)
%   and writes outDir/summary.txt. Prints the summary too.
%
%   Options:
%     Bot         @(s,k)->logical skilled policy           (default none)
%     BotSeconds  length of the bot run                    (default 120)
%     Mode        @(s)->number, the game's state-machine mode, logged so
%                 the summary shows which modes each run visited
%     Trace       @(s)->numeric row, extra fields logged in the bot run
%                 (written to outDir/bot-trace.csv)
%     RandP       tap probability per tick for random runs (default 0.06)
%     Shots       extra tick indices to screenshot in the bot run
%     Dt          tick length (default 1/30)
%     Quick       true: shorter runs, 2 random seeds, no GIFs; for
%                 milestone checks. Run the full suite before reporting.

names = {'Bot', 'BotSeconds', 'Mode', 'Trace', 'RandP', 'Shots', 'Dt', 'Quick'};
if nargin < 2 || isempty(outDir)
    outDir = fullfile(tempdir, 'obgsuite');
elseif any(strcmpi(outDir, names))   % called as obgsuite(game, Name, Value, ...)
    varargin = [{outDir} varargin];
    outDir = fullfile(tempdir, 'obgsuite');
end
p = inputParser;
p.addParameter('Bot', []);
p.addParameter('BotSeconds', 120);
p.addParameter('Mode', []);
p.addParameter('Trace', []);
p.addParameter('RandP', 0.06);
p.addParameter('Shots', []);
p.addParameter('Dt', 1/30);
p.addParameter('Quick', false);
p.parse(varargin{:});
o = p.Results;
if ~isfolder(outDir), mkdir(outDir); end
fps = round(1 / o.Dt);
lines = {};
    function add(fmt, varargin), lines{end+1} = sprintf(fmt, varargin{:}); end

modeTrace = [];
if ~isempty(o.Mode), modeTrace = @(s) double(o.Mode(s)); end

runs = struct('name', {}, 'R', {});
    function R = go(name, varargin)
        R = obgtest(gameFile, 'OutDir', outDir, 'Tag', name, 'Dt', o.Dt, varargin{:});
        runs(end+1) = struct('name', name, 'R', R);
    end

% idle / attract
L = 1; if o.Quick, L = 0.4; end
go('idle', 'Frames', round(15*fps*L), 'Shots', [0 2*fps 5*fps], ...
    'Gif', iff(o.Quick, [], [0 5*fps 2]), 'Trace', modeTrace);
% mashing
go('spam', 'Frames', round(20*fps*L), 'Presses', 1:20*fps, ...
    'Shots', 5*fps, 'Trace', modeTrace);
% random tappers
for seed = 1:iff(o.Quick, 2, 5)
    rng(1000 + seed);
    pr = find(rand(1, 30*fps) < o.RandP);
    go(sprintf('random%d', seed), 'Frames', 30*fps, 'Presses', pr, ...
        'Seed', seed, 'Trace', modeTrace, 'Shots', iff(seed == 1, 29*fps, []));
end
% bad player: start, die, restart, repeatedly
badP = [fps, 11*fps:2*fps:20*fps];
go('bad', 'Frames', 21*fps, 'Presses', badP, 'Trace', modeTrace, ...
    'Shots', [10*fps 13*fps]);
% skilled bot
if ~isempty(o.Bot)
    n = round(o.BotSeconds * fps);
    tr = o.Trace;
    if isempty(tr), tr = modeTrace;
    elseif ~isempty(modeTrace), tr = @(s) [modeTrace(s) double(o.Trace(s))];
    end
    shots = unique([round(n*[0.05 0.25 0.5 0.75 0.99]) o.Shots]);
    R = go('bot', 'Frames', n, 'Policy', o.Bot, 'Trace', tr, 'Shots', shots, ...
        'Gif', iff(o.Quick, [], [round(n*0.4) round(n*0.4)+6*fps 2]));
    if ~isempty(R.trace)
        writematrix(R.trace, fullfile(outDir, 'bot-trace.csv'));
    end
end

% summary
add('obgsuite: %s  (%s)', gameFile, char(datetime('now')));
allOk = true;
for i = 1:numel(runs)
    R = runs(i).R; nm = runs(i).name;
    if ~R.ok
        allOk = false;
        add('%-8s FAIL at tick %d:\n%s', nm, R.errTick, indent(R.err));
        continue
    end
    grow = R.objEnd - R.objInit;
    if grow ~= 0, allOk = false; end
    ms = R.msPerTick;
    modes = '';
    if ~isempty(modeTrace) && ~isempty(R.trace)
        m = R.trace(:, 1);
        ch = [1; find(diff(m) ~= 0) + 1];
        seq = m(ch)';
        if numel(seq) > 12, seq = [seq(1:12) NaN]; end
        modes = ['  modes ' strrep(mat2str(seq), 'NaN', '...')];
    end
    add('%-8s ok  ticks %4d  taps %4d  ms med %5.1f p95 %5.1f max %6.1f  objs %d->%d%s%s', ...
        nm, R.ticks, numel(R.presses), median(ms), prctile(ms, 95), max(ms), ...
        R.objInit, R.objEnd, iff(grow ~= 0, '  <-- OBJECT GROWTH', ''), modes);
end
allMs = [];
for i = 1:numel(runs), if runs(i).R.ok, allMs = [allMs runs(i).R.msPerTick]; end, end %#ok<AGROW>
if ~isempty(allMs)
    add('overall  ms median %.1f  p95 %.1f  (budget 33 at 30 fps)', median(allMs), prctile(allMs, 95));
end
add('result   %s', iff(allOk, 'PASS (no errors, no object growth)', 'FAIL'));
shots = {};
for i = 1:numel(runs), shots = [shots runs(i).R.shots]; end %#ok<AGROW>
gifs = arrayfun(@(r) r.R.gif, runs, 'UniformOutput', false);
gifs = gifs(~cellfun(@isempty, gifs));
add('shots    %d files in %s', numel(shots), outDir);
for i = 1:numel(gifs), add('gif      %s', gifs{i}); end

txt = strjoin(lines, newline);
fprintf('%s\n', txt);
fid = fopen(fullfile(outDir, 'summary.txt'), 'w'); fprintf(fid, '%s\n', txt); fclose(fid);
S = struct('ok', allOk, 'runs', runs, 'summary', txt);
end

function v = iff(c, a, b), if c, v = a; else, v = b; end, end
function s = indent(t), s = ['    ' strrep(strtrim(t), newline, [newline '    '])]; end
