#!/bin/sh
# Agentic Tests universal installer/updater.
#
# Installs the portable agentic-* Agent Skills for Codex, Claude Code,
# Google Antigravity, and Cline. Run from a project root:
#   curl -fsSL https://raw.githubusercontent.com/jpbaking/agentic-tests/main/install.sh | sh
#
# Prefer the agent-guided install (AGENT-INSTALL.md) when an AI agent is
# available — it merges with existing project files instead of colliding.
# Agentic-Tests-owned skill directories are replaced on update. Root
# AGENTS.md / CLAUDE.md files are appended to at most once, never
# overwritten. Override the source with AGENTIC_TESTS_REPO (owner/repo),
# AGENTIC_TESTS_REF (branch/tag), or AGENTIC_TESTS_SOURCE (local checkout).

set -eu

REPO="${AGENTIC_TESTS_REPO:-jpbaking/agentic-tests}"
REF="${AGENTIC_TESTS_REF:-main}"
SKILLS="agentic-unit-test agentic-mutation-check agentic-refactor agentic-test-update agentic-coverage-report agentic-test-clean"
STAGING=""

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
cleanup() { [ -z "$STAGING" ] || rm -rf "$STAGING"; }
trap cleanup EXIT HUP INT TERM

has_text() {
  [ -f "$1" ] && grep -F "$2" "$1" >/dev/null 2>&1
}

# Resolve the canonical skills/ tree: local checkout or one GitHub tarball.
if [ -n "${AGENTIC_TESTS_SOURCE:-}" ]; then
  [ -d "$AGENTIC_TESTS_SOURCE/skills/shared" ] || die "AGENTIC_TESTS_SOURCE has no skills/shared directory."
  SRC="$AGENTIC_TESTS_SOURCE"
  echo "Agentic Tests install from local source $SRC"
else
  STAGING="$(mktemp -d "${TMPDIR:-/tmp}/agentic-tests-install.XXXXXX")"
  url="https://codeload.github.com/$REPO/tar.gz/$REF"
  echo "Agentic Tests install from $REPO@$REF"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$STAGING/src.tar.gz"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$STAGING/src.tar.gz"
  else
    die "need curl or wget"
  fi
  mkdir "$STAGING/x"
  tar -xzf "$STAGING/src.tar.gz" -C "$STAGING/x"
  set -- "$STAGING/x"/*
  [ "$#" -eq 1 ] && [ -d "$1" ] || die "unexpected archive layout"
  SRC="$1"
fi
echo "  into $(pwd)"

# Skills: .agents/skills is shared by Codex, Antigravity, and current Cline;
# Claude Code needs its own byte-identical copy. Whole skill directories are
# replaced so retired bundled resources cannot linger.
for skill in $SKILLS; do
  [ -d "$SRC/skills/shared/$skill" ] || die "source is missing skills/shared/$skill"
  for root in .agents .claude; do
    mkdir -p "$root/skills"
    rm -rf "$root/skills/$skill"
    cp -R "$SRC/skills/shared/$skill" "$root/skills/$skill"
    echo "  + $root/skills/$skill/"
  done
done

# Bridge pointers: append once, conditional wording so a fresh clone (where
# the gitignored adapters are absent) still degrades safely.
if ! has_text "AGENTS.md" "agentic-unit-test"; then
  [ -f AGENTS.md ] || printf '# Project rules\n' > AGENTS.md
  cat >> AGENTS.md <<'EOF'

## Agentic Tests

If `.agents/skills/agentic-unit-test/` exists, this project uses the Agentic
Tests skill suite (agentic-unit-test, agentic-mutation-check,
agentic-refactor, agentic-test-update, agentic-coverage-report,
agentic-test-clean): use the matching skill when its description applies, and
never edit main code or user-written tests while doing test work. If the
skills are missing (fresh clone — they are gitignored), re-run the installer
from https://github.com/jpbaking/agentic-tests.
EOF
  echo "  + AGENTS.md (appended Agentic Tests pointer)"
else
  echo "  = kept existing AGENTS.md (already mentions agentic-unit-test)"
fi

if [ ! -f CLAUDE.md ]; then
  printf '@AGENTS.md\n' > CLAUDE.md
  echo "  + CLAUDE.md (@AGENTS.md import)"
elif ! has_text "CLAUDE.md" "AGENTS.md" && ! has_text "CLAUDE.md" "agentic"; then
  echo "  ! kept existing CLAUDE.md; add @AGENTS.md or an Agentic Tests pointer yourself"
else
  echo "  = kept existing CLAUDE.md"
fi

# Generated adapters stay out of the target's git history; the root bridges
# above remain committable.
GI_MARK="# Agentic Tests installer-managed agent adapters (generated; do not edit or commit)"
if has_text ".gitignore" "$GI_MARK"; then
  echo "  = kept existing .gitignore Agentic Tests block"
else
  {
    [ -s .gitignore ] && printf '\n'
    printf '%s\n' "$GI_MARK"
    for skill in $SKILLS; do
      printf '.agents/skills/%s/\n.claude/skills/%s/\n' "$skill" "$skill"
    done
  } >> .gitignore
  echo "  + .gitignore (adapter entries; AGENTS.md / CLAUDE.md stay tracked)"
fi

echo "Done. Installed skills: $SKILLS"
echo "Next: ask your agent to use the agentic-unit-test skill (e.g. \"use the agentic-unit-test skill on src/pricing.ts, branch 90 per-file\")."
echo "Explicit syntax varies: Codex uses a \$ skill mention; Claude, Antigravity, and Cline support /agentic-unit-test."
