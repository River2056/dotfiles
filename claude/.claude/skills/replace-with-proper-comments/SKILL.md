---
name: replace-with-proper-comments
description: Search a git repository for comments starting with `replace with...` and do as the comment says. Accepts an optional repository path and/or commit ID.
---

# Arguments

- **repo-path** (optional): Absolute filesystem path to a git repository. If omitted, assumes the current working directory.
- **commit-id** (optional): A specific git commit ID to inspect. If omitted, uses the latest commit (`HEAD`).

# Utilities

## validate repository
Confirm the target path is a valid git repository:
```bash
git -C <repo-path> rev-parse --git-dir
```
If this fails, inform the user that the path is not a valid git repository and stop.

## find committed files
Get the list of files changed in a specific commit:
```bash
git -C <repo-path> diff-tree --no-commit-id --name-only -r <commit-id>
```
- If `commit-id` is provided, use it directly.
- If `commit-id` is not provided, use `HEAD`.
- If `repo-path` is not provided, omit the `-C <repo-path>` flag (defaults to cwd).

## find unstaged and staged files
Get the list of modified files not yet committed:
```bash
git -C <repo-path> diff --name-only
git -C <repo-path> diff --cached --name-only
```
Combine the output of both commands into a single list.

## filter files
After gathering the file list, filter to only files with supported extensions:
`.java`, `.js`, `.ts`, `.jsx`, `.tsx`, `.kt`, `.py`, `.go`, `.cs`, `.rb`, `.swift`, `.rs`

Discard any files that do not match these extensions.

# Workflow

1. **Determine target repository**: Use `repo-path` if provided; otherwise use the current working directory.
2. **Validate**: Run `validate repository` to confirm the target is a git repository. If invalid, stop and inform the user.
3. **Gather file list**:
   - If a `commit-id` is provided, run `find committed files` with that commit ID.
   - If no `commit-id` is provided:
     1. Run `find unstaged and staged files` to collect uncommitted changes.
     2. Run `find committed files` with `HEAD` to collect the latest commit's changes.
     3. Merge both lists and **deduplicate**.
4. **Early exit**: If the file list is empty, inform the user that no files were found and stop.
5. **Filter**: Run `filter files` to keep only supported file types.
6. **Search and replace**: For each file in the filtered list, scan for comments starting with `replace with...` and perform the replacement according to the rules below.

# Rules

- Generated comments should be in **mandarin**.
- Any javadoc/jsdoc generated should follow **multi-line style**, except for inline comments.
- If a comment already uses `/** ... */` style, **preserve that style** — do not convert it to `// ...`.
- If the return type is not `void`, add a proper **return description** in the docs.
- **Ignore** comments containing `@implements`.
- Add proper javadocs/jsdocs/comments according to the file type and follow the language's conventions.
