---
description: Run a code review in a background subagent and save the report
agent: code-reviewer
subtask: true
---

Run a background code review using these optional arguments: `$ARGUMENTS`.

Interpret arguments as:
- `$1`: git repository location
- `$2`: review branch
- `$3`: target branch

If argument count is less than 3, ask the user for the git repository location, then proceed to use defaults defined in the subagent.
