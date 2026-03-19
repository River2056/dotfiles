---
name: rearrange-fields
description: Rearrange class fields to match sql ddl schema order
---

# Main Objective

Your main objective is to rearrange the fields of the java class to match the order declared in a SQL DDL schema file.
Prompt the user for the absolute path of this SQL DDL schema file, or simply read from input.
Prompt the user for the absolute path of the java class file, or simply read from input.
After rearranging the fields, if the file contains getters and setters, rearrange those according to convention.
