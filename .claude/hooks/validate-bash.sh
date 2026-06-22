#!/usr/bin/env bash
# PreToolUse(Bash) guard. Reads the hook JSON on stdin and BLOCKS (exit 2) dangerous commands.
# Exit 0 = allow. Fail-open: if the command can't be parsed, it is allowed (a guard, not a gate).
set -uo pipefail

input="$(cat)"

# Extract the bash command from the hook payload (tool_input.command).
cmd="$(printf '%s' "$input" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)"

[ -z "$cmd" ] && exit 0

# 1) Universal guard: block recursive force-deletes aimed at a root / home path.
if printf '%s' "$cmd" | grep -Eq 'rm[[:space:]]+-[a-zA-Z]*(rf|fr)[a-zA-Z]*[[:space:]]+(/|~|/\*|\$HOME)([[:space:]]|;|$)'; then
  echo "BLOCKED: refusing a recursive force-delete of a root/home path. Narrow the target path." >&2
  exit 2
fi

# ─────────────────────────────────────────────────────────────────────────────
# 2) Project-specific rules go here. Pattern: match the command, echo a reason to
#    stderr, exit 2 to block. Delete this block if you have no extra rules.
#
# Example — forbid system-package ops on a protected host named in the command:
#   if printf '%s' "$cmd" | grep -Eq '(^|[^a-zA-Z])PROTECTED_HOST([^a-zA-Z]|$)' \
#      && printf '%s' "$cmd" | grep -Eq '(^|[^a-zA-Z])(apt|apt-get|dpkg|snap)([^a-zA-Z]|$)'; then
#     echo "BLOCKED: system-package operations on PROTECTED_HOST are forbidden." >&2
#     exit 2
#   fi
# ─────────────────────────────────────────────────────────────────────────────

exit 0
