#!/usr/bin/env bash
# check-scaffold.sh — the scaffold's self-consistency check. Run locally or from CI.
#
# A scaffold's product is internal consistency: the map (CLAUDE.md, README.md) must match the
# territory (.claude/). Both real bugs in this repo's history were drift of exactly that kind —
# a .gitignore that silently swallowed the datasets skill, and a README that missed /bootstrap
# and the pipelines skill. This script makes that class of bug fail loudly.
#
# Checks:
#   1. DRIFT      — every real skill / command / agent on disk is named in CLAUDE.md AND README.md
#   2. FRONTMATTER — every SKILL.md / agent has name: + description:; SKILL.md name matches its dir
#   3. CONFIG     — settings.json parses; every hook it wires exists, is executable, and compiles;
#                   every skillOverride set "on" has a skill directory backing it
#   4. INSTALL    — install.sh into a temp dir lands every file, re-run adds nothing (idempotent),
#                   and the <PLACEHOLDER> count survives the trip
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT" || exit 1

fails=0
fail() { printf 'FAIL  %s\n' "$1"; fails=$((fails + 1)); }
ok()   { printf 'ok    %s\n' "$1"; }

# ---- 1. DRIFT: disk -> docs -------------------------------------------------
for dir in .claude/skills/*/; do
  name="$(basename "$dir")"
  [ "$name" = "_example" ] && continue
  grep -q "$name" CLAUDE.md  || fail "skill '$name' exists on disk but is not in CLAUDE.md"
  grep -q "$name" README.md  || fail "skill '$name' exists on disk but is not in README.md"
done
for f in .claude/commands/*.md; do
  name="$(basename "$f" .md)"
  [ "$name" = "_TEMPLATE" ] && continue
  grep -q "/$name" CLAUDE.md || fail "command '/$name' exists on disk but is not in CLAUDE.md"
  grep -q "$name" README.md  || fail "command '/$name' exists on disk but is not in README.md"
done
for f in .claude/agents/*.md; do
  name="$(basename "$f" .md)"
  [ "$name" = "_TEMPLATE" ] && continue
  grep -q "$name" CLAUDE.md  || fail "agent '$name' exists on disk but is not in CLAUDE.md"
  grep -q "$name" README.md  || fail "agent '$name' exists on disk but is not in README.md"
done
ok "drift: skills/commands/agents on disk are all named in CLAUDE.md + README.md"

# ---- 2. FRONTMATTER ---------------------------------------------------------
for f in .claude/skills/*/SKILL.md; do
  dir_name="$(basename "$(dirname "$f")")"
  [ "$dir_name" = "_example" ] && continue
  head -1 "$f" | grep -q '^---$' || { fail "$f has no frontmatter"; continue; }
  fm_name="$(awk '/^name:/{print $2; exit}' "$f")"
  [ "$fm_name" = "$dir_name" ] || fail "$f frontmatter name '$fm_name' != dir '$dir_name'"
  grep -q '^description:' "$f" || fail "$f has no description: (skills surface by description)"
done
for f in .claude/agents/*.md; do
  [ "$(basename "$f")" = "_TEMPLATE.md" ] && continue
  grep -q '^name:' "$f"        || fail "$f has no name: frontmatter"
  grep -q '^description:' "$f" || fail "$f has no description: (agents dispatch by description)"
done
ok "frontmatter: every skill/agent has name + description; skill names match their dirs"

# ---- 3. CONFIG --------------------------------------------------------------
python3 - <<'PY' || fails=$((fails + 1))
import json, os, sys
root = os.getcwd()
try:
    cfg = json.load(open(".claude/settings.json"))
except Exception as e:
    sys.exit(f"FAIL  settings.json does not parse: {e}")

bad = 0
for event, entries in cfg.get("hooks", {}).items():
    for entry in entries:
        for hook in entry.get("hooks", []):
            path = hook["command"].replace("$CLAUDE_PROJECT_DIR", root)
            if not os.path.isfile(path):
                print(f"FAIL  hook wired for {event} does not exist: {path}"); bad += 1
            elif not os.access(path, os.X_OK):
                print(f"FAIL  hook is not executable: {path}"); bad += 1

for skill, state in cfg.get("skillOverrides", {}).items():
    if state == "on" and not os.path.isdir(f".claude/skills/{skill}"):
        print(f"FAIL  skillOverrides has '{skill}: on' but .claude/skills/{skill}/ does not exist"); bad += 1

sys.exit(bad)
PY
for f in .claude/hooks/*.sh; do bash -n "$f" || fail "$f does not parse (bash -n)"; done
for f in .claude/hooks/*.py; do python3 -m py_compile "$f" || fail "$f does not compile"; done
ok "config: settings.json parses; wired hooks exist, are executable, and compile; overrides are backed"

# ---- 4. INSTALL -------------------------------------------------------------
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
# The find filter here MUST mirror install.sh's — a mismatch shows up as a file-count failure below.
src_count="$(find .claude -type f ! -name '*.py[co]' ! -path '*/__pycache__/*' | wc -l)"
src_count=$((src_count + 2))  # + CLAUDE.md + the version stamp
src_ph="$(grep -rho --exclude-dir=__pycache__ '<PLACEHOLDER' .claude CLAUDE.md | wc -l)"

./install.sh "$tmp" >/dev/null || fail "install.sh exited nonzero"
dst_count="$(find "$tmp" -type f | wc -l)"
dst_ph="$(grep -rho '<PLACEHOLDER' "$tmp" | wc -l)"
[ "$dst_count" = "$src_count" ] || fail "install landed $dst_count files, expected $src_count"
[ "$dst_ph" = "$src_ph" ]       || fail "placeholders changed in transit: $src_ph -> $dst_ph"

rerun="$(./install.sh "$tmp" | grep -c '^  add:' || true)"
[ "$rerun" = "0" ] || fail "install.sh re-run added $rerun files — it must be idempotent"
ok "install: $dst_count files land, $dst_ph placeholders intact, re-run adds nothing"

# ---- verdict ----------------------------------------------------------------
echo
if [ "$fails" -gt 0 ]; then
  echo "check-scaffold: $fails failure(s)"; exit 1
fi
echo "check-scaffold: all checks passed"
