# Input format analysis

## Status and evidence

Stage 2 is in progress. The project brief identifies three input sections and required validation categories. The official assignment and a sample `problema.txt` have not been supplied. The record syntax, domain, and rule vocabulary are therefore not confirmed.

Do not treat this document as a complete input specification. Do not create supposedly valid records or implement the parser until the missing format is confirmed.

## Known section markers

| Marker | Purpose | Record syntax |
| --- | --- | --- |
| `[ENTIDADES]` | Declare entities | Pending official input |
| `[RELACIONES]` | Declare relations between entities | Pending official input |
| `[REGLAS_SOLICITADAS]` | Request logical rules | Pending official input |

These assignment-defined markers must retain their spelling even though implementation identifiers, documentation, and interface text are in English.

## Proposed section recognition

Subject to verification against the official assignment:

1. Read the input as numbered physical lines before filtering anything.
2. Preserve each original line and its one-based line number.
3. Use a separate trimmed view of each line to compare complete section markers.
4. Track the current section and attach each record to that section.
5. Retain unknown headers and malformed records as diagnostics rather than silently dropping them.

Case sensitivity, section ordering, repeated sections, blank lines, comments, text before the first section, and byte-order-mark handling need explicit decisions after reviewing the input specification. Do not lowercase entity names or record text during section recognition.

## Source line preservation

Line numbering must happen before blank lines or comments are skipped. For example, if a header occupies line 1, line 2 is blank, and a record occupies line 3, that record must retain source line 3.

Keep source location information with entities, relations, requested rules, and diagnostics. Later generators will use it for Prolog traceability comments and the validation report. Define the actual Haskell types in stage 3, not here.

## Validation categories

| Category | Required behavior | Details still needed |
| --- | --- | --- |
| Duplicate entities | Report duplicate declarations | Entity identity and case rules |
| Undeclared references | Report relations referencing undeclared entities | Relation syntax, argument roles, and forward-reference policy |
| Malformed lines | Report invalid records with source lines | Delimiters, identifiers, arity, quoting, and escaping |
| Missing sections | Report required sections that are absent | Whether empty sections are permitted |
| Unsupported rules | Report requested rules outside the selected domain | Approved domain and rule vocabulary |

Also clarify whether unknown or repeated section headers are errors, whether processing continues after each error, and whether invalid input prevents knowledge and HTML generation. Missing sections have no physical source line; diagnostics should identify the missing marker without inventing a line number.

## Planned examples and expected checks

Create concrete fixtures only after confirming the record grammar:

- A minimal valid input containing all required sections.
- A second valid input with different entity names to detect hardcoded assumptions.
- A duplicate entity declaration with both source locations identifiable.
- A relation containing an undeclared entity.
- A malformed record for each supported record type.
- An input missing a required section.
- An unsupported requested rule.
- A line-number case containing blank lines and, if supported, comments.
- Section recognition cases covering the confirmed whitespace, case, order, and repetition policies.

No parser tests have been executed because no parser exists. This stage currently records analysis only.

## Required material to finish stage 2

- The official assignment and rubric, including approved domains and mandatory predicate names.
- A representative `problema.txt`, preferably the professor's example.
- Any explicit rules for encoding, comments, delimiters, identifiers, and error handling.

After reviewing those materials, finalize this specification and add valid and invalid fixtures. Wait for approval before starting the intermediate Haskell model in stage 3.
