#!/usr/bin/env bash
# install.sh — drop the claude-scaffold skeleton into a target project.
#
# Usage:
#   ./install.sh [TARGET_DIR]        # default TARGET_DIR is the current directory
#
# Copies .claude/ and CLAUDE.md into TARGET. NEVER overwrites an existing file —
# already-present files are reported and skipped, so it's safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"

if [ ! -d "$TARGET" ]; then
  echo "error: target dir '$TARGET' does not exist" >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

if [ "$TARGET" = "$SCRIPT_DIR" ]; then
  echo "error: refusing to install the scaffold into itself" >&2
  exit 1
fi

echo "Scaffolding Claude config into: $TARGET"
echo

copied=0
skipped=0

# Source set: every file under .claude/, plus the root CLAUDE.md.
while IFS= read -r src; do
  rel="${src#"$SCRIPT_DIR"/}"
  dest="$TARGET/$rel"
  if [ -e "$dest" ]; then
    printf '  skip (exists): %s\n' "$rel"
    skipped=$((skipped + 1))
    continue
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  printf '  add:           %s\n' "$rel"
  copied=$((copied + 1))
done < <(
  find "$SCRIPT_DIR/.claude" -type f
  echo "$SCRIPT_DIR/CLAUDE.md"
)

# Make hooks/scripts executable in the target (they're invoked directly).
find "$TARGET/.claude/hooks" "$TARGET/.claude/scripts" -type f \
  \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} + 2>/dev/null || true

echo
echo "Done: $copied added, $skipped skipped (already present)."
echo "Next (the first two are the setup, in order):"
echo "  1. In Claude Code, run /intake — it interviews you for your stack (tracker/config/data"
echo "     versioning), writes .claude/settings.json skillOverrides, and fills the stack placeholders."
echo "  2. Run /bootstrap — it builds the project skeleton the skills describe (conf/ tree, train.py,"
echo "     eval.py, seed helper) and back-fills the placeholders that need that code to exist."
echo "     Until this runs, the skills document a project you don't have."
echo "  3. Fill any remaining <PLACEHOLDER>s the two commands list (architecture doc, policy domains,"
echo "     data-remote URL) — those need your decisions, not an agent's guess."
echo "  4. Edit .claude/settings.json permissions for this project's tools."
echo "  5. Rename .claude/skills/_example and the *_TEMPLATE.md files as you build real ones."
