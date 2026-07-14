#!/usr/bin/env python3
"""PreToolUse(Edit|Write) hook: keep dependency edits out of pyproject.toml — that's `uv add`'s job.

Enforces the always-on convention "deps via uv": hand-edited dependencies desync uv.lock from
pyproject.toml, and the drift only surfaces when someone else's `uv sync --frozen` fails. Blocking
(exit 2) is deliberate but narrow:

- Write to an EXISTING pyproject.toml: always blocked (a full rewrite can't be verified dep-safe).
  Creating one where none exists is allowed.
- Edit: blocked only when old_string/new_string touches a dependency table or a requirement-shaped
  line. Additive edits to other tables (pytest markers, tool config) pass — /bootstrap makes those.

Fail-open on anything unparseable: a guard that bricks the session is worse than a missed edit.
"""

import json
import re
import sys
from pathlib import Path

DEP_PATTERN = re.compile(
    r"(\bdependencies\b|optional-dependencies|dependency-groups"
    r"|['\"][A-Za-z0-9_.-]+\s*[><=!~]=)"  # a "pkg>=1.2"-shaped requirement line
)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    tool = payload.get("tool_name", "")
    tool_input = payload.get("tool_input", {})
    file_path = tool_input.get("file_path", "")
    if Path(file_path).name != "pyproject.toml":
        return 0

    if tool == "Write":
        if not Path(file_path).is_file():
            return 0  # creating a new pyproject is fine
        sys.stderr.write(
            "[guard-pyproject] Blocked: full Write over an existing pyproject.toml. "
            "Dependencies go through `uv add` / `uv remove` (keeps uv.lock in sync); "
            "for non-dependency tables use a targeted Edit.\n"
        )
        return 2

    if tool == "Edit":
        touched = (tool_input.get("old_string") or "") + (tool_input.get("new_string") or "")
        if DEP_PATTERN.search(touched):
            sys.stderr.write(
                "[guard-pyproject] Blocked: this Edit touches a dependency entry. "
                "Use `uv add <pkg>` / `uv remove <pkg>` so uv.lock stays in sync — "
                "never hand-edit dependencies (always-on convention).\n"
            )
            return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
