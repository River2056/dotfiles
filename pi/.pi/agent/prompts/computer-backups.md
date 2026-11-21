---
description: Audit backup coverage and completion without changing settings
argument-hint: "[important folders or backup concern]"
---
Audit this computer's backup readiness.
Focus: ${@:-backup destinations, last successful completion, and coverage of important user files}.

- Identify configured backup tools/destinations and distinguish backup with recoverable history from ordinary synchronization.
- Inspect read-only status/log metadata for the latest successful completion, schedule, destination availability, retention, and reported errors.
- Do not mount or unlock unavailable storage, start backup jobs, access recovery secrets, or initiate restore tests.
- Compare included/excluded paths with the user's stated important folders; if unspecified, identify likely categories from metadata and label coverage assumptions for confirmation.
- Flag missing/offline destinations, stale successful runs, exclusions, and gaps in device-loss or accidental-deletion recovery.
- State whether restore-test evidence exists. A configured tool, recent sync, or completed job does not prove restorability.
- Recommend the simplest reliable improvement using existing tools/storage, noting uncertainty about capacity, encryption, off-device copies, and retention.
- Describe an optional small restore-test plan with scope, destination, risks, and approval needed, but do not execute it or change backup settings.

## Safety and reporting

This request authorizes read-only inspection only. Do not stop processes, delete or modify files, disable startup items/extensions, install tools, change settings, or initiate backups/restores. Do not use sudo, open credential stores, print secrets, or upload private data. Ask before any change or any inspection that requires additional privileges. If access is unavailable, report the gap rather than bypassing it.

Use bounded, low-impact checks; avoid exhaustive disk scans or expensive hashing without approval. Identify the OS and available tools first. Separate measured observations from hypotheses, cite commands/paths and observation times, and state uncertainties. Redact sensitive identifiers.

Return a concise summary and a prioritized evidence table: finding, evidence, interpretation/confidence, proposed action, expected benefit, risks, and reversal approach where applicable. Stop before changes and request item-specific approval; a recommendation is not authorization.

## Provenance

Adapted from the workspace note `00_Inbox/Claude Computer Use - Five Computer Checkup Prompts (DfjebRHHSv3).md`; these are original English adaptations, not verbatim source prompts.
