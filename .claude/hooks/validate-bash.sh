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

# 2) Secrets guard: block shell reads of .env files (the Read-tool deny in settings.json
#    doesn't cover the shell path). `.env.example` ships empty values and stays readable —
#    strip its mentions first, then test what's left for a read command aimed at a .env file.
#    Best-effort like everything here: this stops the accident, not a determined bypass
#    (see .claude/memory/policy/security.md for the threat model).
stripped="${cmd//.env.example/}"
if printf '%s' "$stripped" | grep -Eq '(^|[;&|`([:space:]])(cat|less|more|head|tail|bat|strings|xxd|od|grep|egrep|fgrep|awk|cut|paste|sort|uniq|source)[[:space:]][^;|&]*\.env([^A-Za-z0-9_-]|$)'; then
  echo "BLOCKED: refusing a shell read of a .env file — secrets stay out of the transcript. Read .env.example for the expected keys, or ask the user for the value you need." >&2
  exit 2
fi

# ─────────────────────────────────────────────────────────────────────────────
# 3) Project-specific rules go here. Pattern: match the command, echo a reason to
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
