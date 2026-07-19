# Agentic Tests universal installer/updater (PowerShell 5.1+).
#
# Installs the portable agentic-* Agent Skills for Codex, Claude Code,
# Google Antigravity, and Cline. Run from a project root:
#   irm https://raw.githubusercontent.com/jpbaking/agentic-tests/main/install.ps1 | iex
#
# Prefer the agent-guided install (AGENT-INSTALL.md) when an AI agent is
# available. Override the source with $env:AGENTIC_TESTS_REPO,
# $env:AGENTIC_TESTS_REF, or $env:AGENTIC_TESTS_SOURCE (local checkout).

$ErrorActionPreference = "Stop"

$Repo = if ($env:AGENTIC_TESTS_REPO) { $env:AGENTIC_TESTS_REPO } else { "jpbaking/agentic-tests" }
$Ref  = if ($env:AGENTIC_TESTS_REF)  { $env:AGENTIC_TESTS_REF }  else { "main" }
$Skills = @("agentic-unit-test", "agentic-mutation-check", "agentic-refactor",
            "agentic-test-update", "agentic-coverage-report", "agentic-test-clean")
$Staging = $null

function Has-Text {
    param([string]$Path, [string]$Text)
    return (Test-Path $Path -PathType Leaf) -and [bool](Select-String -Path $Path -SimpleMatch $Text -Quiet)
}

try {
    # Resolve the canonical skills/ tree: local checkout or one GitHub archive.
    if ($env:AGENTIC_TESTS_SOURCE) {
        if (-not (Test-Path (Join-Path $env:AGENTIC_TESTS_SOURCE "skills/shared") -PathType Container)) {
            throw "AGENTIC_TESTS_SOURCE has no skills/shared directory."
        }
        $Src = $env:AGENTIC_TESTS_SOURCE
        Write-Host "Agentic Tests install from local source $Src"
    } else {
        $Staging = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-tests-install-" + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $Staging -Force | Out-Null
        $Zip = Join-Path $Staging "src.zip"
        Write-Host "Agentic Tests install from $Repo@$Ref"
        Invoke-WebRequest -Uri "https://api.github.com/repos/$Repo/zipball/$([Uri]::EscapeDataString($Ref))" -OutFile $Zip -UseBasicParsing
        Expand-Archive -Path $Zip -DestinationPath (Join-Path $Staging "x")
        $Top = @(Get-ChildItem (Join-Path $Staging "x") -Directory)
        if ($Top.Count -ne 1) { throw "unexpected archive layout" }
        $Src = $Top[0].FullName
    }
    Write-Host "  into $(Get-Location)"

    # Skills: .agents/skills is shared by Codex, Antigravity, and current
    # Cline; Claude Code needs its own byte-identical copy. Whole skill
    # directories are replaced so retired bundled resources cannot linger.
    foreach ($skill in $Skills) {
        $SkillSrc = Join-Path $Src "skills/shared/$skill"
        if (-not (Test-Path $SkillSrc -PathType Container)) { throw "source is missing skills/shared/$skill" }
        foreach ($root in ".agents", ".claude") {
            $Dest = Join-Path "$root\skills" $skill
            New-Item -ItemType Directory -Path "$root\skills" -Force | Out-Null
            if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force }
            Copy-Item $SkillSrc $Dest -Recurse
            Write-Host "  + $Dest\"
        }
    }

    # Bridge pointers: append once, conditional wording so a fresh clone
    # (where the gitignored adapters are absent) still degrades safely.
    $Pointer = @"

## Agentic Tests

If ``.agents/skills/agentic-unit-test/`` exists, this project uses the Agentic
Tests skill suite (agentic-unit-test, agentic-mutation-check,
agentic-refactor, agentic-test-update, agentic-coverage-report,
agentic-test-clean): use the matching skill when its description applies, and
never edit main code or user-written tests while doing test work. If the
skills are missing (fresh clone -- they are gitignored), re-run the installer
from https://github.com/jpbaking/agentic-tests.
"@
    if (-not (Has-Text "AGENTS.md" "agentic-unit-test")) {
        if (-not (Test-Path "AGENTS.md")) { Set-Content -Path "AGENTS.md" -Value "# Project rules" }
        Add-Content -Path "AGENTS.md" -Value $Pointer
        Write-Host "  + AGENTS.md (appended Agentic Tests pointer)"
    } else {
        Write-Host "  = kept existing AGENTS.md (already mentions agentic-unit-test)"
    }
    if (-not (Test-Path "CLAUDE.md")) {
        Set-Content -Path "CLAUDE.md" -Value "@AGENTS.md"
        Write-Host "  + CLAUDE.md (@AGENTS.md import)"
    } elseif (-not (Has-Text "CLAUDE.md" "AGENTS.md") -and -not (Has-Text "CLAUDE.md" "agentic")) {
        Write-Host "  ! kept existing CLAUDE.md; add @AGENTS.md or an Agentic Tests pointer yourself"
    } else {
        Write-Host "  = kept existing CLAUDE.md"
    }

    # Generated adapters stay out of the target's git history; the root
    # bridges above remain committable.
    $GitignoreMark = "# Agentic Tests installer-managed agent adapters (generated; do not edit or commit)"
    if (Has-Text ".gitignore" $GitignoreMark) {
        Write-Host "  = kept existing .gitignore Agentic Tests block"
    } else {
        $entries = @($GitignoreMark)
        foreach ($skill in $Skills) {
            $entries += ".agents/skills/$skill/"
            $entries += ".claude/skills/$skill/"
        }
        $block = ($entries -join "`n") + "`n"
        if ((Test-Path ".gitignore") -and (Get-Item ".gitignore").Length -gt 0) { $block = "`n" + $block }
        Add-Content -Path ".gitignore" -Value $block -NoNewline
        Write-Host "  + .gitignore (adapter entries; AGENTS.md / CLAUDE.md stay tracked)"
    }

    Write-Host "Done. Installed skills: $($Skills -join ', ')"
    Write-Host "Next: ask your agent to use the agentic-unit-test skill."
    Write-Host 'Explicit syntax varies: Codex uses a $ skill mention; Claude, Antigravity, and Cline support /agentic-unit-test.'
} finally {
    if ($Staging -and (Test-Path $Staging)) { Remove-Item $Staging -Recurse -Force }
}
