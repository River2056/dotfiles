---
description: A command to show all files modified or added in this git commit.
agent: build
---

Run the below bash command to retrieve a list of files that are modified, added or deleted in this commit id.
```bash
git diff-tree --no-commit-id --name-only <commit-id-provided-by-user> -r;
```
If the user didn't provide any commit-id, use the latest commit id of this git branch in the current directory.
