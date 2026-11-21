---
description: Review large files and cleanup candidates without deleting
argument-hint: "[directory or storage concern]"
---
Analyze storage usage on this computer.
Scope: ${@:-the user home directory and overall volume capacity; begin with a bounded top-level inventory}.

- Report capacity, available space, scope, exclusions, and permission gaps. Distinguish logical file size from allocated disk space where possible.
- Identify the 20 largest files/folders within a practical bounded scan. Label incomplete coverage; do not silently expand to other volumes or cloud-only content.
- Avoid following symlinks outside scope or downloading cloud placeholders.
- Identify old downloads, installers, temporary/build artifacts, and possible duplicate photos/files from metadata first. State age criteria; do not equate old with unused.
- Label duplicates as candidates unless content equality is verified. Ask before bulk hashing or opening private content.
- Show size, path, purpose, uncertainty, and risk for each cleanup candidate. Do not assume caches, app data, or generated files are safe to remove.
- Estimate potential savings without double-counting nested directories, duplicates, shared storage, or overlapping candidates; distinguish estimates from recoverable space.
- Separate likely low-risk candidates, items requiring review, and important files to retain. Do not delete anything.

## Safety and reporting

This request authorizes read-only inspection only. Do not stop processes, delete or modify files, disable startup items/extensions, install tools, change settings, or initiate backups/restores. Do not use sudo, open credential stores, print secrets, or upload private data. Ask before any change or any inspection that requires additional privileges. If access is unavailable, report the gap rather than bypassing it.

Use bounded, low-impact checks; avoid exhaustive disk scans or expensive hashing without approval. Identify the OS and available tools first. Separate measured observations from hypotheses, cite commands/paths and observation times, and state uncertainties. Redact sensitive identifiers.

Return a concise summary and a prioritized evidence table: finding, evidence, interpretation/confidence, proposed action, expected benefit, risks, and reversal approach where applicable. Stop before changes and request item-specific approval; a recommendation is not authorization.

## Provenance

Adapted from the workspace note `00_Inbox/Claude Computer Use - Five Computer Checkup Prompts (DfjebRHHSv3).md`; these are original English adaptations, not verbatim source prompts.
