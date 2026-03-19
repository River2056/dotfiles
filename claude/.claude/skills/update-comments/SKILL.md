---
name: update-comments
description: study code and update comments if necessary
---

# Utilities
git command to get files to look through:
```bash
commit_id=$(git log --oneline | head -n 1 | awk '{print $1}')
git diff-tree --no-commit-id --name-only $commit_id -r
```
or if user provided a commit id, simply run: `git diff-tree --no-commit-id --name-only <commit-id> -r`

# Main Objective
Study files, usually from a codebase, and check it's comments. Update it if necessary.
If presented with a git commit id, use the command provided above to get files to look through.
If user didn't provide any arguments, and current directory is a git repository, use the command provided above to get files to look through.
