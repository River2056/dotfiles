---
name: code-review
description: Perform code review of a feature branch against a target branch. Trigger on /code-review.
allowed-tools: [Bash, Read, Write, Glob, Grep, Agent, AskUserQuestion]
---

# Code Review Skill

Perform a structured code review comparing a review branch against a target branch.

## Step 1: Gather Branches

Arguments are passed as: `/code-review <review-branch> <target-branch>`

- If both arguments are provided, use them directly — skip all prompts.
- If only one argument is provided, treat it as the review branch and prompt for the target branch.
- If no arguments are provided, prompt the user for both branches. Offer to run `git branch -r` to list available remote branches if they need help choosing.

## Step 2: Fetch, Worktree, Rebase, and Diff

### 2a. Fetch latest state

```bash
git fetch --all --prune
```

### 2b. Create a worktree

```bash
git worktree add /tmp/code-review-<review-branch> <review-branch>
cd /tmp/code-review-<review-branch>
```

All subsequent git commands in Step 2 run inside this worktree directory.

### 2c. Rebase onto target

```bash
git rebase <target-branch>
```

If the rebase encounters conflicts:
1. Abort the rebase: `git rebase --abort`
2. Fall back to the direct diff approach (use `<target-branch>..<review-branch>` for all commands below)
3. Inform the user that rebase had conflicts, so the diff may contain extra noise from diverged histories

### 2d. Collect diff data

1. **Diff stat** — `git diff --stat <target-branch>..HEAD`
2. **Full diff** — `git diff <target-branch>..HEAD`
3. **Commit log** — `git log --oneline <target-branch>..HEAD`

For large diffs, use `Read` to examine individual changed files for additional context beyond the raw diff.

### 2e. Cleanup — remove the worktree

```bash
cd <original-repo-dir>
git worktree remove /tmp/code-review-<review-branch> --force
```

Always clean up, even if earlier steps failed. Use `--force` to ensure removal.

## Step 3: Perform Review

Analyze all changes thoroughly. Use these severity tags for every finding:

| Tag | Meaning |
|-----|---------|
| `[BUG]` | Logic errors, crashes, null/undefined handling, race conditions |
| `[SECURITY]` | Vulnerabilities, auth gaps, data exposure, injection risks |
| `[PERF]` | Performance issues, unnecessary allocations, N+1 queries |
| `[MINOR]` | Style, naming, minor improvements, consistency |
| `[NOTICE]` | Observations, questions for the author, ambiguity |
| `[GOOD]` | Positive highlights — well-written code, good patterns |

**Review guidelines:**
- Always include `file:line` references
- Include relevant code snippets
- For `[BUG]`, `[SECURITY]`, and `[PERF]` findings, provide a **Problem** explanation and a **Recommendation** with suggested fix
- Look at the big picture (architecture, design) as well as line-level details
- Note commented-out code, TODOs without tracking references, and dead code

## Step 4: Output Format

Structure the review output exactly like this:

```
Here is the code review for `<review-branch>` → `<target-branch>`:
---
## Code Review: <brief description of what the changes do>
**Commits:** N commits, M files changed (+X/-Y)
---
### Summary of Changes

<table or bullet list summarizing the changes by ticket/feature>

---

### Issues Found

#### [SEVERITY] Title

**File:** `path:line`

\```<language>
<code snippet>
\```

**Problem:** <explanation>

**Recommendation:**
\```<language>
<suggested fix>
\```

---

<repeat for each finding>

### Verdict

| | |
|---|---|
| **Blocking** | <issues that should be fixed before merge> |
| **Non-blocking** | <issues that are suggestions/improvements> |

<final assessment and merge recommendation>
```

## Step 5: Save Output

Determine the repository name from the current directory (basename of the git root).

Save the review to:
```
/Users/kevintung/code/code_review_logs/claude/YYYYMMDD_<repo-name>.md
```

- Use today's date in `YYYYMMDD` format
- If the file already exists, append a random 5-digit numeric suffix: `YYYYMMDD_<repo-name>-<random>.md`
- Create the directory if it doesn't exist (`mkdir -p`)

After saving, tell the user where the file was saved.
