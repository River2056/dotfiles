---
description: Inspect CPU and memory usage without changing the machine
argument-hint: "[symptom or focus]"
---
Investigate this computer's current performance.
Focus: ${@:-general slowdown during normal use}.

- Take several bounded CPU/memory samples over a stated interval. Report CPU normalization and how memory percentages are calculated.
- List programs exceeding 5% CPU or physical RAM, with consumption, identity, and plain-language purpose. Treat 5% as an inventory filter, not proof of a fault.
- Examine overall memory pressure, swap, and load using available read-only tools.
- Distinguish transient work from sustained pressure; account for normal development/build workloads and limitations of short samples.
- Rank plausible bottlenecks and recommend the smallest next diagnostic or change, without applying it.

## Safety and reporting

This request authorizes read-only inspection only. Do not stop processes, delete or modify files, disable startup items/extensions, install tools, change settings, or initiate backups/restores. Do not use sudo, open credential stores, print secrets, or upload private data. Ask before any change or any inspection that requires additional privileges. If access is unavailable, report the gap rather than bypassing it.

Use bounded, low-impact checks; avoid exhaustive disk scans or expensive hashing without approval. Identify the OS and available tools first. Separate measured observations from hypotheses, cite commands/paths and observation times, and state uncertainties. Redact sensitive identifiers.

Return a concise summary and a prioritized evidence table: finding, evidence, interpretation/confidence, proposed action, expected benefit, risks, and reversal approach where applicable. Stop before changes and request item-specific approval; a recommendation is not authorization.

## Provenance

Adapted from the workspace note `00_Inbox/Claude Computer Use - Five Computer Checkup Prompts (DfjebRHHSv3).md`; these are original English adaptations, not verbatim source prompts.
