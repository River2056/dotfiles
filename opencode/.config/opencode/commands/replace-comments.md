---
description: Replace placeholder comments with proper docs in a git repo
agent: comment-replacer
subtask: true
---

Run the replace-with-proper-comments skill using these arguments: `$ARGUMENTS`.

Interpret arguments as:
- `$1`: git repository path (required)
- `$2`: commit id (optional)

If git repository path is missing, ask the user to provide it.
If commit id is not provided, the subagent will determine the appropriate files to scan using the skill's default behavior (check unstaged files first, then fall back to the latest commit).
