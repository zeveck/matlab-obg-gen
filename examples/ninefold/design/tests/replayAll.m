function replayAll()
% PROOF that every Ninefold level is fully beatable: replay each recorded
% solution and require a CLEAN clear (every ball home, no wrong exit).
% Then play one whole run through the harness: title -> L1..L9 -> win.
% Fails loudly if anything doesn't hold. Run after EVERY change to game.m.
here = fileparts(mfilename('fullpath'));
gameDir = fullfile(here, '..', '..');
solDir = fullfile(here, '..', 'solutions');
addpath(fullfile(here, '..', '..', '..', '..', 'skills', 'matlab-obg-gen', 'tools'));   % the skill's tools
allOk = true;
src = fileread(fullfile(gameDir, 'game.m'));
seeds = regexp(src, 'z = ''([^'']{9})'';', 'tokens', 'once');
seeds = seeds{1};
T = cell(1, numel(seeds));
for L = 1:numel(seeds)
    f = fullfile(solDir, sprintf('level-%d.mat', L));
    if ~isfile(f), fprintf('L%d: NO SOLUTION FILE\n', L); allOk = false; continue, end
    S = load(f);
    T{L} = S.taps;
    if S.seed ~= seeds(L)
        fprintf('L%d: solution is for seed %s but game.m has %s\n', L, S.seed, seeds(L));
        allOk = false; continue
    end
    if isempty(S.taps)   % a "clear" with no input proves nothing
        fprintf('L%d: EMPTY SOLUTION (no taps)\n', L);
        allOk = false; continue
    end
    [s, g, fg] = nfLevelStart(gameDir, L);
    k = 0;
    while s.mode == 1 && k < 30*120
        k = k + 1;
        s = g.update(s, 1/30, any(S.taps == k));
    end
    close(fg);
    ok = s.mode == 2 && contains(s.bb, 'CLEAN');
    allOk = allOk && ok;
    fprintf('L%d (seed %s): ended at %.1f s, %d taps, banner "%s / %s" -> %s\n', L, S.seed, ...
        k/30, numel(S.taps), s.ba, s.bb, pick(ok, 'CLEAN CLEAR', 'FAILED'));
    % human timing: a closed-loop player with 65-265 ms reactions (see nfHuman)
    hits = 0;
    for r = 1:3
        hits = hits + nfHuman(gameDir, L, r);
    end
    human = hits >= 2;
    allOk = allOk && human;
    fprintf('   human-timing player: %d/3 clean clears -> %s\n', hits, pick(human, 'DOABLE', 'TOO FIDDLY'));
end
if allOk
    % one full run from the title, through every level, to the win screen
    pol =@(s, k) fullRunPolicy(s, k, T);
    R = obgtest(fullfile(gameDir, 'game.m'), 'Frames', 30*60*9, 'Policy', pol, ...
        'Trace', @(s) [s.mode s.L s.strays s.score], 'StopWhen', @(s) s.mode == 3, ...
        'Shots', [], 'OutDir', fullfile(here, '..', 'shots'), 'Tag', 'fullrun');
    endState = R.trace(end, :);
    won = R.ok && endState(1) == 3 && endState(2) == numel(seeds) && endState(3) == 0;
    fprintf('Full run: %s (mode %d, level %d, strays %d, score %d, %.0f s)\n', ...
        pick(won, 'WON ALL NINE', 'FAILED'), endState, R.ticks/30);
    allOk = allOk && won;
    if ~R.ok, disp(R.err), end
end
fprintf('\nRESULT: %s\n', pick(allOk, 'ALL LEVELS PROVEN BEATABLE', 'NOT PROVEN'));
clear fullRunPolicy
end

function t = pick(c, a, b)
if c, t = a; else, t = b; end
end

function p = fullRunPolicy(s, k, T)
% replays each level's taps relative to that level's first tick
persistent L0 k0
if isempty(L0) || k == 1, L0 = -1; k0 = 0; end
if s.mode == 0, p = k == 2; return, end   % tap on the title (any tick works)
p = false;
if s.mode ~= 1, return, end
if s.L ~= L0, L0 = s.L; k0 = k; end
p = any(T{s.L} == k - k0 + 1);
end
