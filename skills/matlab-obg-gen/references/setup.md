# Setup: getting someone ready to make games

Run `tools/check-setup.ps1 -Project <project folder>` (Windows PowerShell).
Each MISSING/WARN line names the section below to follow. Fix items in
order, re-run the check, and only start the game work when everything is
OK. Walk the person through anything that needs them (sign-ins,
licenses, downloads behind a login); do everything else yourself. Explain
each step in a line or two.

On macOS/Linux there's no checker script yet: check the same items by
hand (`which matlab`, `/Applications/MATLAB_R20xx*.app`, `claude mcp list`,
`~/.matlab/agentic-toolkits`, the add-ons folder from
`matlab.addons.installedAddons` in MATLAB).

## Installing MATLAB

Needs R2021a or later (the newest release is best), MATLAB only; no
toolboxes needed.

- **The person's MathWorks account is required** (license). If they have
  none: a trial or the Home license at mathworks.com.
- **Without admin rights** (the usual case for an agent's shell): install
  with MathWorks Package Manager into a user-writable folder:
  1. Download `https://www.mathworks.com/mpm/win64/mpm` to a working folder
     (Linux: `/mpm/glnxa64/mpm`, Mac: `/mpm/maci64/mpm` or `maca64`).
  2. `mpm install --release=R2026b --destination="C:\MATLAB\R2026b" --products MATLAB`
     (run in the background; it's a few GB).
  3. mpm may print `Installation failed` at the very end, because
     `registerWithOS.exe` needs elevation. That step only adds Start menu
     entries and file associations; MATLAB works without it. Check the log
     (`%TEMP%\mathworks_<user>.log`) to be sure that was the only error.
  4. **The person activates it:** they start `<root>\bin\matlab.exe` once
     and sign in.
- Or they install it themselves with the normal installer from
  mathworks.com/downloads (needs their login; it can't be scripted).

## Repairing the MATLAB path

Symptom: MATLAB starts with `Initializing Java preferences failed` /
`Unrecognized function or variable 'initdesktoputils'`, and core functions
like `matlab.addons.install` are missing. Cause: the install never wrote
`toolbox\local\pathdef.m`. Fix (batch, from any folder, via a .m script):

```matlab
restoredefaultpath; rehash toolboxcache;
savepath(fullfile(matlabroot, 'toolbox', 'local', 'pathdef.m'));
```

Then check `which initdesktoputils` finds a file in a fresh `matlab -batch`.
(Never run `restoredefaultpath` inside the MCP session: it breaks the
connection.)

## Connecting Claude to MATLAB (Agentic Toolkit + MCP server)

1. Download the installer add-on (a public file):
   `https://github.com/matlab/simulink-agentic-toolkit/releases/latest/download/agenticToolkitInstaller.mltbx`
2. Install and configure it in batch MATLAB. Write a script, because quotes
   inside `-batch "..."` break from Git Bash:
   ```matlab
   matlab.addons.install('<path>\agenticToolkitInstaller.mltbx');
   ```
   then, in a NEW batch run (the add-on isn't on the path in the same one;
   `addpath` its folder under `%APPDATA%\MathWorks\MATLAB Add-Ons\` if needed):
   ```matlab
   setupAgenticToolkit("install", Toolkit="matlab", Agents="claude-code", Scope="global", ...
       SkillGroups=["matlab-app-building","matlab-programming","matlab-software-development"], Prompt=false);
   setupAgenticToolkit("configure", Toolkit="matlab", Agents="claude-code", Scope="global", ...
       SkillGroups=["matlab-app-building","matlab-programming","matlab-software-development"], Prompt=false);
   ```
   `install` only downloads; `configure` registers the MCP server with
   Claude Code (`claude mcp list` should then show `matlab ... Connected`).
3. **The person restarts Claude Code** so the MATLAB tools load. Tell them
   what to say when they're back ("run /matlab-obg-gen again").
4. Optional: in their own MATLAB, `shareMATLABSession` lets the tools drive
   the window they're looking at.

## The contest starter project and toolkit

- The starter project (File Exchange #185098, "MATLAB One-Button Game
  Minihack Starter Project") needs the person's sign-in to download. Ask
  them to download it and unzip it into the project folder.
- Opening it installs the contest toolkit (`minihackContest.*`):
  `openProject('<project>\minihackContest.prj')` (works in batch or MCP).
  Check with `~isempty(which('minihackContest.validate'))`.
- In an MCP session that started outside the project, open the project
  once per session before using `minihackContest.*`.

## Signed in (for submitting)

`minihackContest.submit` uses the MATLAB login. If it fails with an
authentication error, the person signs in to MATLAB (Home tab ->
sign in, or start MATLAB and sign in) and you retry.

## Machine headroom

Each MATLAB is ~1.5-2 GB of RAM plus heavy CPU. With under ~2 GB free,
run one MATLAB job at a time and suggest closing other apps. See
"Check the machine" in playtest.md.
