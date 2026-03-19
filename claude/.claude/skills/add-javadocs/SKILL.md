---
name: add-javadocs
description: Adds proper javadocs to methods
---

# Main Objective

Your main objective is to add proper javadocs to methods in a Java class.
Prompt the user for the absolute file path of the Java class and the method(s) to add javadocs.
If no specific methods is provided, default to all methods in that class.
Your priority should be:
- add javadocs to methods that are complete empty or missing.
- if there's already a existing javadoc, read it's contents and patch in missing details without changing the original.

Your javadocs should be in mandarin.
