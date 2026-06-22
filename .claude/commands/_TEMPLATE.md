---
description: <One line shown in the slash-command list. Start with a verb.>
# argument-hint: <arg>      # optional: shown after the command name as a usage hint
# allowed-tools: Bash, Read # optional: restrict tools for this command's run
---

<The prompt that runs when the user types /this-command. Write it as direct instructions to Claude.>

<!--
Notes:
- The filename is the command name: commands/deploy.md → /deploy.
- $ARGUMENTS expands to everything typed after the command; $1, $2, … are positional args.
  Example: "Fetch issue #$1 and implement a fix."
- Prefix a line with ! to run a bash command and inline its output (needs allowed-tools: Bash).
  Example: "Current diff:\n!`git diff`"
- Reference a file's contents with @path/to/file.
- Keep commands task-shaped and deterministic — they're for repeatable workflows.
-->
