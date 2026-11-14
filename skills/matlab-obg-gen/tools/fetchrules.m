r = webread('https://www.mathworks.com/matlabcentral/communitycontests/api/v1/contests/current/rules_meta');
fprintf('max_length: %d\n', r.max_length);
fprintf('banned_operators: %s\n', strjoin(cellstr(r.banned_operators), ', '));
fprintf('banned_functions (%d):\n%s\n', numel(r.banned_functions), strjoin(sort(cellstr(r.banned_functions)), ', '));
