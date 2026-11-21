---
description: Audit startup apps and background services read-only
argument-hint: "[app or startup symptom]"
---
Inventory this computer's startup applications and background services.
Focus: ${@:-all user and system startup entries visible with current permissions}.

- Inspect OS-appropriate login items, launch agents/daemons or equivalent startup mechanisms.
- For each relevant item, record its name, executable/configuration path, owner/publisher where verifiable, enabled state, purpose, and available startup-impact evidence.
- Classify items as required, optional, or unresolved based on evidence and dependencies, not unfamiliar names.
- Explain effects and risks of disabling each optional candidate, including sync, backups, security, VPN, and developer services.
- Do not infer measured boot-time impact from an entry's existence or perform a reboot/timing experiment.
- Present candidates for individual approval, but do not disable anything.

## Safety and reporting

This request authorizes read-only inspection only. Do not stop processes, delete or modify files, disable startup items/extensions, install tools, change settings, or initiate backups/restores. Do not use sudo, open credential stores, print secrets, or upload private data. Ask before any change or any inspection that requires additional privileges. If access is unavailable, report the gap rather than bypassing it.

Use bounded, low-impact checks; avoid exhaustive disk scans or expensive hashing without approval. Identify the OS and available tools first. Separate measured observations from hypotheses, cite commands/paths and observation times, and state uncertainties. Redact sensitive identifiers.

Return a concise summary and a prioritized evidence table: finding, evidence, interpretation/confidence, proposed action, expected benefit, risks, and reversal approach where applicable. Stop before changes and request item-specific approval; a recommendation is not authorization.

## Provenance

Adapted from the workspace note `00_Inbox/Claude Computer Use - Five Computer Checkup Prompts (DfjebRHHSv3).md`; these are original English adaptations, not verbatim source prompts.
