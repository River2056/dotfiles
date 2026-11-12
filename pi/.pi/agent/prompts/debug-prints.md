---
description: Add debug logging to a file method
argument-hint: "<file::method>"
---
Add print statements to `$ARGUMENTS` for debugging purposes. Use the project's existing logger to trace method entry, key branches, relevant values, and completion. Avoid logging sensitive data, preserve existing behavior, keep changes scoped to the target method, and run targeted validation. Distinguish existing validation issues from newly introduced ones.
