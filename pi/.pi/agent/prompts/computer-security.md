---
description: Triage unfamiliar programs, extensions, and connections read-only
argument-hint: "[program, extension, or concern]"
---
Triage potentially suspicious software on this computer.
Focus: ${@:-unfamiliar background programs, browser extensions, and unexpected network connections}.

- Inventory relevant running programs, installed browser extensions, and current connections using available read-only evidence.
- Verify executable paths, publisher/signature information, parent processes, extension identifiers/permissions, and connection ownership where accessible.
- Do not read browser history, cookies, credentials, or private page content. Do not run unknown executables or contact suspicious endpoints.
- Explain each item's likely purpose and distinguish verified facts, benign explanations, and unresolved concerns.
- Never label software malicious solely from its name, CPU usage, unsigned status, or an unfamiliar destination.
- If a known-threat claim needs external verification, use trustworthy sources and only non-sensitive public identifiers; never upload files, private hashes, or internal hostnames without approval.
- Prioritize evidence-backed concerns and propose safe next checks. State explicitly that this is triage, not a complete malware scan or proof of security.
- Do not remove software, disable extensions, kill processes, or change network/security settings.

## Safety and reporting

This request authorizes read-only inspection only. Do not stop processes, delete or modify files, disable startup items/extensions, install tools, change settings, or initiate backups/restores. Do not use sudo, open credential stores, print secrets, or upload private data. Ask before any change or any inspection that requires additional privileges. If access is unavailable, report the gap rather than bypassing it.

Use bounded, low-impact checks; avoid exhaustive disk scans or expensive hashing without approval. Identify the OS and available tools first. Separate measured observations from hypotheses, cite commands/paths and observation times, and state uncertainties. Redact sensitive identifiers.

Return a concise summary and a prioritized evidence table: finding, evidence, interpretation/confidence, proposed action, expected benefit, risks, and reversal approach where applicable. Stop before changes and request item-specific approval; a recommendation is not authorization.

## Provenance

Adapted from the workspace note `00_Inbox/Claude Computer Use - Five Computer Checkup Prompts (DfjebRHHSv3).md`; these are original English adaptations, not verbatim source prompts.
