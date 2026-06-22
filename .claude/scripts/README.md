# scripts — helper scripts for hooks & commands

Shell/Python helpers invoked by hooks (`../hooks/`), slash commands (`../commands/`), or run by
hand. Keeping them here (not in `hooks/`) separates *wiring* (a hook entry in `settings.json`) from
*logic* (the script it calls), so a command and a hook can share one script.

Conventions:
- Make scripts executable (`chmod +x`) and give them a `#!/usr/bin/env …` shebang.
- Reference them from `settings.json` / commands via `$CLAUDE_PROJECT_DIR/.claude/scripts/<name>`.
- Keep them fail-safe: a session-start or pre-tool script that errors shouldn't brick the session.

Example uses: a `preflight.sh` connectivity check, a `SessionStart` setup script, a release helper.
