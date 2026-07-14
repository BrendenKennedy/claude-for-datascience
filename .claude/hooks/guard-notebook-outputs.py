#!/usr/bin/env python3
"""PreToolUse(Edit|Write) hook: notebooks commit clean — block writing .ipynb with baked outputs.

Enforces the notebooks skill's rule (strip outputs before committing) at write time, where it's
cheap: an .ipynb landing on disk with cell outputs or execution counts is one `git add` away from a
bloated, unreviewable diff. The pre-commit template (nbstripout) covers human commits; this covers
the agent's own writes.

Scope note: only Write|Edit — NotebookEdit edits cell *source* and cannot introduce outputs, so
matching it would be dead code. Fail-open on unparseable payloads/JSON (never brick the session);
Write of a full notebook is parsed properly, Edit falls back to a string heuristic because an edit
fragment isn't valid JSON on its own.
"""

import json
import re
import sys

# An Edit fragment that carries a non-empty outputs array or a numbered execution_count.
OUTPUT_FRAGMENT = re.compile(r'"outputs"\s*:\s*\[\s*[^\]\s]|"execution_count"\s*:\s*\d')

BLOCK_MSG = (
    "[guard-notebook-outputs] Blocked: this .ipynb write carries cell outputs / execution counts. "
    "Notebooks commit clean here (see the notebooks skill) — strip outputs first "
    "(nbstripout, or clear outputs), then write.\n"
)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    tool = payload.get("tool_name", "")
    tool_input = payload.get("tool_input", {})
    if not tool_input.get("file_path", "").endswith(".ipynb"):
        return 0

    if tool == "Write":
        try:
            nb = json.loads(tool_input.get("content") or "")
        except Exception:
            return 0
        for cell in nb.get("cells", []):
            if cell.get("outputs") or cell.get("execution_count") is not None:
                sys.stderr.write(BLOCK_MSG)
                return 2

    elif tool == "Edit":
        if OUTPUT_FRAGMENT.search(tool_input.get("new_string") or ""):
            sys.stderr.write(BLOCK_MSG)
            return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
