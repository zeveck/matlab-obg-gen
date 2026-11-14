# check-setup.ps1 - what /matlab-obg-gen needs, and what's missing.
# Prints one line per item: OK / MISSING / WARN, plus a hint. Read-only.
# Usage (PowerShell):  & "<skill>/tools/check-setup.ps1" [-Project <folder>]
param([string]$Project = (Get-Location).Path)

function Say($state, $what, $hint) {
    $line = "{0,-8} {1}" -f $state, $what
    if ($hint) { $line += "  -> $hint" }
    Write-Output $line
}

# 1. MATLAB installs (R2021a+ needed; newest wins)
$roots = @()
foreach ($base in @("C:\Program Files\MATLAB", "C:\MATLAB", "$env:LOCALAPPDATA\MATLAB")) {
    if (Test-Path $base) {
        $roots += Get-ChildItem $base -Directory -ErrorAction SilentlyContinue |
            Where-Object { Test-Path (Join-Path $_.FullName "bin\matlab.exe") }
    }
}
$onPath = Get-Command matlab -ErrorAction SilentlyContinue
if ($onPath) { $roots += Get-Item (Split-Path (Split-Path $onPath.Source)) }
$roots = $roots | Sort-Object Name -Unique
if (-not $roots) {
    Say "MISSING" "MATLAB" "install R2021a or later (references/setup.md: 'Installing MATLAB')"
} else {
    $best = $roots | Sort-Object Name | Select-Object -Last 1
    $rel = $best.Name
    $state = if ($rel -match 'R20(\d\d)') { if ([int]$Matches[1] -ge 21) { "OK" } else { "MISSING" } } else { "WARN" }
    Say $state "MATLAB $rel at $($best.FullName)" $(if ($state -ne "OK") { "need R2021a or later" })
    # the mpm-without-admin install can miss pathdef.m (MATLAB then can't find its own functions)
    if (-not (Test-Path (Join-Path $best.FullName "toolbox\local\pathdef.m"))) {
        Say "WARN" "no toolbox\local\pathdef.m in $rel" "see references/setup.md: 'Repairing the MATLAB path'"
    }
    Write-Output "MATLABROOT $($best.FullName)"
}

# 2. MATLAB MCP server registered with Claude Code
$mcp = & claude mcp list 2>$null | Select-String -Pattern "matlab" -SimpleMatch
if ($mcp) {
    $ok = $mcp -match "Connected"
    Say $(if ($ok) { "OK" } else { "WARN" }) "MATLAB MCP server: $($mcp.ToString().Trim())" $(if (-not $ok) { "restart Claude Code; see setup.md" })
} else {
    Say "MISSING" "MATLAB MCP server for Claude Code" "install the Agentic Toolkit (setup.md: 'Connecting Claude to MATLAB'), then restart Claude Code"
}

# 3. Agentic Toolkit files
$atk = Join-Path $HOME ".matlab\agentic-toolkits"
if (Test-Path (Join-Path $atk "bin\matlab-mcp-server.exe")) { Say "OK" "Agentic Toolkit at $atk" }
else { Say "MISSING" "Agentic Toolkit" "setup.md: 'Connecting Claude to MATLAB'" }

# 4. Contest toolkit add-on (installed by opening the starter project)
$addon = Get-ChildItem (Join-Path $env:APPDATA "MathWorks\MATLAB Add-Ons") -Directory -Filter "minihackContestToolkit*" -ErrorAction SilentlyContinue
if ($addon) { Say "OK" "contest toolkit $($addon.Name)" }
else { Say "MISSING" "contest toolkit (minihackContest)" "open the starter project's minihackContest.prj in MATLAB (setup.md)" }

# 5. Starter project in this folder
if (Test-Path (Join-Path $Project "minihackContest.prj")) { Say "OK" "starter project in $Project" }
else { Say "MISSING" "starter project (minihackContest.prj) in $Project" "download it from File Exchange #185098 (setup.md)" }

# 6. Machine headroom (each MATLAB is ~1.5-2 GB)
$os = Get-CimInstance Win32_OperatingSystem
$free = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$n = (Get-Process MATLAB -ErrorAction SilentlyContinue | Measure-Object).Count
$state = if ($free -lt 2) { "WARN" } else { "OK" }
Say $state "RAM free $free GB, MATLAB processes running: $n" $(if ($free -lt 2) { "close apps before batch runs; run one MATLAB job at a time" })
