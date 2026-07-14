#!/usr/bin/env bash
# Stop hook: the leakage tests run before the session ends — a leaked split never rides out quietly.
#
# The split-leakage tests (see the testing skill's ML confidence checks) are cheap and decisive, but
# nothing runs them unless someone remembers to. This makes forgetting impossible: when the agent
# stops, any test matching "leakage" runs; a failure blocks the stop (exit 2) with the failing tail,
# so the leak is surfaced while the context that caused it is still loaded.
#
# Fail-open everywhere else: no tests/, no leakage tests, no uv, or a timeout — exit 0 silently.
# A verification hook that bricks sessions teaches people to delete it.
set -uo pipefail

payload="$(cat 2>/dev/null || true)"

# Loop guard: when a previous block already re-engaged the agent, stop_hook_active is true —
# blocking again would ping-pong forever. Let the stop through; the failure was already surfaced.
case "$payload" in
  *'"stop_hook_active": true'*|*'"stop_hook_active":true'*) exit 0 ;;
esac

dir="${CLAUDE_PROJECT_DIR:-.}"
[ -d "$dir/tests" ] || exit 0
grep -rlq "leakage" "$dir/tests" 2>/dev/null || exit 0
command -v uv >/dev/null 2>&1 || exit 0

out="$(cd "$dir" && timeout 120 uv run pytest -q -k leakage -x --no-header 2>&1)"
status=$?

# 124 = timeout, 127 = uv/pytest missing inside the env — infrastructure, not a leak; stay silent.
if [ "$status" -ne 0 ] && [ "$status" -ne 124 ] && [ "$status" -ne 127 ]; then
  {
    echo "[run-leakage-tests] Split-leakage tests FAILED — do not end the session on a leaked split:"
    echo "$out" | tail -15
  } >&2
  exit 2
fi
exit 0
