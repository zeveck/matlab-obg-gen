% Find a seed and a clean solution for each of Ninefold's 9 levels.
% Run in batch:  matlab -batch "solveAll"  from this folder.
here = fileparts(mfilename('fullpath'));
gameFile = fullfile(here, '..', '..', 'game.m');
solDir = fullfile(here, '..', 'solutions');
if ~isfolder(solDir), mkdir(solDir); end
logFile = fullfile(solDir, 'solve-log.txt');
lg = @(varargin) fprintf2(logFile, varargin{:});
src = fileread(gameFile);
cur = regexp(src, 'z = ''([^'']{9})'';', 'tokens', 'once');
cur = cur{1};
lg('start %s, seeds now %s\n', char(datetime('now')), cur);
tmp = fullfile(tempdir, 'nf_solve');
if ~isfolder(tmp), mkdir(tmp); end
pool = ['lmnopqrstuvwxyzabcdefghijkABCDEFGHIJKLMNOPQRSTUVWXYZ' '0123456789'];
seeds = cur;
for L = 1:9   % seeds already proven (so new picks can avoid them)
    f = fullfile(solDir, sprintf('level-%d.mat', L));
    if isfile(f), S = load(f); seeds(L) = S.seed; end
end
for L = 1:9
    if isfile(fullfile(solDir, sprintf('level-%d.mat', L)))
        S = load(fullfile(solDir, sprintf('level-%d.mat', L)));
        seeds(L) = S.seed;
        lg('L%d: already solved with seed %s\n', L, S.seed);
        continue
    end
    tries = [cur(L) pool(pool ~= cur(L))];
    if L > 2   % every generated level gets its own seed (same seed = same rooms)
        tries = tries(~ismember(tries, seeds([3:L-1 L+1:9])));
    end
    solved = false;
    for c = tries(1:min(12, end))
        z = seeds; z(L) = c;
        fid = fopen(fullfile(tmp, 'game.m'), 'w');
        fwrite(fid, strrep(src, ['z = ''' cur ''';'], ['z = ''' z ''';']));
        fclose(fid);
        [s0, g, fg] = nfLevelStart(tmp, L);
        t0 = tic;
        [taps, ok, msg] = nfSolve(g, s0, 12, 250);
        close(fg);
        lg('L%d seed %s: %s (%.0f s)\n', L, c, msg, toc(t0));
        if ok   % solvable; now is it doable with human timing?
            hits = 0;
            for r = 1:3
                hits = hits + nfHuman(tmp, L, r);
            end
            lg('L%d seed %s: human-timing player %d/3 clean\n', L, c, hits);
            ok = hits >= 2;
        end
        if ok
            seed = c;
            save(fullfile(solDir, sprintf('level-%d.mat', L)), 'taps', 'seed', 'L');
            seeds(L) = c;
            solved = true;
            break
        end
    end
    if ~solved, lg('L%d: NO SOLUTION FOUND in 12 seeds\n', L); end
end
lg('done %s, seeds %s\n', char(datetime('now')), seeds);
% keep game.m in step with the proven seeds
if ~strcmp(seeds, cur)
    fid = fopen(gameFile, 'w');
    fwrite(fid, strrep(src, ['z = ''' cur ''';'], ['z = ''' seeds ''';']));
    fclose(fid);
    lg('game.m seeds updated: %s -> %s\n', cur, seeds);
end

function fprintf2(file, varargin)
fid = fopen(file, 'a'); fprintf(fid, varargin{:}); fclose(fid);
fprintf(varargin{:});
end
