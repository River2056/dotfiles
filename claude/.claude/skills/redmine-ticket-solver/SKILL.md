---
name: redmine-ticket-solver
description: >
  Fetch a Redmine ticket by ID, analyze the reported problem, search the
  codebase for relevant code, and suggest a fix. Use this skill whenever the
  user mentions a Redmine ticket number, asks to investigate a Redmine issue,
  wants to solve a bug from Redmine, or references a ticket ID prefixed with
  # (e.g. #1234). Also trigger when the user says "look at ticket 1234",
  "fix the issue in Redmine", "check Redmine ticket", or "what does ticket
  5678 say".
---

# Redmine Ticket Solver

Fetch a Redmine ticket, understand the problem, find the relevant code, and
propose a fix.

## Input

This skill expects a single argument: the Redmine ticket ID (a number).
Example invocation: `/redmine-ticket-solver 1234`

If no ticket ID is provided, ask the user for one before proceeding.

## Step 1: Read Configuration

Read the config file at `~/.claude/skills/redmine-ticket-solver/config.json`.
It contains:

```json
{
  "redmine_url": "https://redmine.example.com",
  "username": "user",
  "password": "pass",
  "nanobankapp": "/absolute/path/to/nanobankapp",
  "aibank-ms": "/absolute/path/to/aibank-ms",
  "fbplus": "/absolute/path/to/fbplus",
  "looks-through": ["nanobankapp", "aibank-ms", "fbplus"],
  "output-path": "/absolute/path/to/output"
}
```

Field descriptions:

- `redmine_url`, `username`, `password` — Redmine server credentials.
- `nanobankapp`, `aibank-ms`, `fbplus` — Absolute paths to the corresponding repository roots.
- `looks-through` — An array of repository keys. Each entry must match one of the repo path keys above. These are the repositories that will be searched in Step 4.
- `output-path` — Absolute path to the directory where output markdown files are saved.

If the file is missing or any field is empty or still contains placeholder
values (including the new fields), stop and tell the user:

> The Redmine config file is missing or incomplete. Please edit
> `~/.claude/skills/redmine-ticket-solver/config.json` with your actual
> values for `redmine_url`, `username`, `password`, the repository paths,
> `looks-through`, and `output-path`.

Store all values for use in subsequent steps.

## Step 2: Fetch the Ticket

Use curl with HTTP Basic Auth to fetch the ticket. Include journals
(comments) for full context:

```
curl -s -u "<username>:<password>" \
  "<redmine_url>/issues/<ticket_id>.json?include=journals,attachments"
```

Parse the JSON response. If the HTTP status is not 200 or the response
contains an error, report the problem to the user:
- **401/403**: Credentials may be wrong.
- **404**: Ticket not found — confirm the ID and Redmine URL.
- **Connection error**: Check connectivity to the Redmine server.

Extract and present these fields as a **Ticket Summary**:

- **Project**: `issue.project.name`
- **Tracker**: `issue.tracker.name` (Bug, Feature, etc.)
- **Status**: `issue.status.name`
- **Priority**: `issue.priority.name`
- **Subject**: `issue.subject`
- **Description**: `issue.description`
- **Author**: `issue.author.name`
- **Assigned to**: `issue.assigned_to.name` (if present)
- **Comments**: From `issue.journals[]` entries with non-empty `notes` —
  show each comment's author and text.

## Step 3: Analyze the Problem

Based on the ticket subject, description, and comments, determine:

1. **What is the problem?** Summarize the bug, feature request, or task.
2. **What are the symptoms?** Error messages, incorrect behavior, stack
   traces, or user-reported observations.
3. **What are the clues?** File names, function names, module names, error
   codes, or line numbers mentioned anywhere in the ticket.
4. **What is the expected behavior?** What should happen instead.

Present this analysis to the user as a structured **Problem Analysis**
before searching the code.

## Step 4: Search the Codebase

Resolve the list of repositories to search:

1. Read the `looks-through` array from the configuration loaded in Step 1.
2. For each entry in the array, look up the corresponding key in the config
   to get its absolute path (e.g., if `looks-through` contains `"nanobankapp"`,
   use the value of `config["nanobankapp"]`).
3. Verify each resolved path exists and is a directory. If any path is
   invalid, warn the user about the specific entry and continue with the
   remaining repositories.

For **every** resolved repository path, apply these search strategies using
the clues from Step 3:

1. **Direct keyword search**: Grep for error messages, class names, function
   names, or identifiers mentioned in the ticket.
2. **File pattern search**: Use Glob to find files matching names or paths
   referenced in the ticket.
3. **Contextual search**: If the ticket mentions a module or feature area,
   search for related files (controllers, models, services, tests).
4. **Stack trace search**: If a stack trace is present, locate each file and
   line number referenced.

When presenting results, always prefix file paths with the repository name
so the user knows which repo each match belongs to (e.g.,
`[nanobankapp] src/main/java/Foo.java:42`).

Read the most relevant files to understand the current implementation. Focus
on the specific functions or code blocks that relate to the reported issue.

If no matching code is found in any of the repositories, report this and ask
the user for additional hints about where to look.

## Step 5: Suggest a Fix

Based on the code analysis, propose a solution:

1. **Root cause**: Explain what in the code causes the reported problem.
2. **Proposed fix**: Show the specific code changes needed with file paths
   and line numbers. Use before/after snippets or diff format. Include the
   repository name in every file path for clarity.
3. **Explanation**: Describe why the change resolves the issue and note any
   side effects to consider.
4. **Test suggestions**: Recommend test cases that verify the fix and
   prevent regression.

Ask the user if they would like you to apply the suggested changes.

## Output Format

Structure the final output with these sections:

### Ticket Summary
(Project, tracker, status, priority, subject, description, comments)

### Problem Analysis
(What the problem is, symptoms, clues, expected behavior)

### Relevant Code
(Repository name, file paths, and key code snippets found across all searched repositories)

### Suggested Fix
(Root cause, proposed changes with repo-qualified file paths, explanation, test suggestions)

## Output Destination

The output must be delivered to **two** destinations:

1. **Terminal**: Display the full output in the conversation as usual.
2. **Markdown file**: Save the same content as a markdown file.

To save the file:

1. Read `output-path` from the configuration.
2. If the directory does not exist, create it (including any intermediate
   directories) using `mkdir -p "<output-path>"`.
3. Generate the filename using the current timestamp and ticket ID:
   `yyyy-MM-dd_HH-MM-SS_redmine-<ticket_id>.md`
   For example: `2026-03-29_14-30-00_redmine-1234.md`
4. Write the full markdown output to `<output-path>/<filename>`.
5. Inform the user of the saved file path.
