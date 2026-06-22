#!/usr/bin/env python3
"""PostToolUse(Edit|Write) hook: format + lint edited Python files with ruff.

Non-blocking by design — always exits 0. When an edited file is a `.py` under the project,
runs `uv run ruff format` then `uv run ruff check --fix` so style stays consistent without a
manual step. If uv/ruff isn't available, it quietly no-ops.

Generic across any uv + ruff Python project. For non-uv projects, drop the `"uv", "run"`
prefix below; for non-Python projects, remove this hook from settings.json.
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    file_path = payload.get("tool_input", {}).get("file_path", "")
    if not file_path or not file_path.endswith(".py"):
        return 0

    path = Path(file_path)
    if not path.is_file():
        return 0

    project_dir = payload.get("cwd") or os.environ.get("CLAUDE_PROJECT_DIR") or "."

    for args in (["ruff", "format", str(path)], ["ruff", "check", "--fix", str(path)]):
        try:
            subprocess.run(
                ["uv", "run", *args],
                cwd=project_dir,
                capture_output=True,
                text=True,
                timeout=60,
            )
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return 0  # uv/ruff unavailable or slow — non-blocking no-op

    print(f"[validate-python] ruff format + check --fix applied to {path.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
