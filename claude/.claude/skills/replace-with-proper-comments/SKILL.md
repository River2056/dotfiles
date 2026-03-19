---
name: replace-with-proper-comments
description: search the codebase and look for comments starting with `replace with...` and do as the comment says
---

# Utilities
## find files
git command to get files to look through:
```bash
commit_id=$(git log --oneline | head -n 1 | awk '{print $1}')
git diff-tree --no-commit-id --name-only -r $commit_id
```
or if user provided a commit id, simply run: `git diff-tree --no-commit-id --name-only -r <commit-id>`

## find unstage files
git command to get unstaged files to look through:
```bash
git status
```

# Main Objective
If presented with a git commit id, use the command `find files` provided above to get files to look through.
If user didn't provide any arguments, and the current directory is a git repository, do the following:
1. check for unstaged files first using the `find unstaged files` command provided above.
2. use the command `find files` provided above to get files to look through.

Look for comments that starts with `replace with...` and do what the comment is asking.
Add proper javadocs/jsdocs/comments according to the filetype and follow the conventions while adding.
Generated comments should be in mandarin.
Any javadoc/jsdoc generated whould follow a multi-line style, except for comments.
If comments happen to start with `/** ... */`, keep this style instead of changing it into `// ...`.
If return type is not `void`, add proper description in the docs.
Ignore comments with `@implements`.
