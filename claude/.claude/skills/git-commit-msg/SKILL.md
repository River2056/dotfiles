---
name: git-commit-msg
description: Generate git commit messages following a predifined pattern
---

# Main Objective

Generate a git commit message following a predefined pattern.
Prompt the user and ask whether it starts with `FP` or `OVS`, followed by a digit, e.g. `FP-29780` or `OVS-29985`.
Prompt the user for the ticket number, and prefix it with `#`, e.g. `#9990`.
Finally prompt the user for a title.
Your final git commit message title should look something like this: 
`FP-29780 #9990 Fix some bugs related to NGNOT001-v1.0.0`
or
`OVS-29780 #9990 New module development OXXTR001-v1.0.0`.
If the user provided the completed title that follows the predifined pattern, use that instead and skip the previous prompts.

Prompt the user which branch to merge to,
then run :
```bash
git diff <branch-provided-by-user>..HEAD
```
to find out what changed.
Study the changes and generate a descriptions that describes this diffs, these messages will be the git commit message body.
Your message should be in a bulleted list style, with added diffs starting with `+`, and removed diffs `-`
