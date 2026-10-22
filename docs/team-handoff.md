# Team handoff

## Completed

1. Initial repository structure, ignore rules, and English documentation.
2. Local Windows tools verified: GHC/GHCi 9.10.3, Cabal 3.16.1.0, SWI-Prolog 10.1.17, Doxygen 1.18.0, and Git 2.44.0.
3. Academic domain confirmed against the supplied assignment; input conventions and valid/invalid fixtures documented.
4. Intermediate Haskell model implemented in `Source.hs`, `Diagnostic.hs`, and `Model.hs`.
5. All 12 model checks passed after compilation with `-Wall -Werror`.
6. Functional parser and separate UTF-8 reader implemented in `Parser.hs` and `Input.hs`; all 33 parser checks passed and all 12 model checks passed again.
7. Semantic validator, UTF-8 report generator, and validation command implemented; all 29 validation checks and all 45 existing checks passed. Valid and invalid report command executions were also verified.
8. Prolog facts, requested rules, source comments, suggested queries, and generation command implemented. All 16 generator checks and 13 SWI-Prolog checks passed, along with the existing 74 checks.

## Feedback on the current work

The project now has a clear input contract and a model that separates domain data, source traceability, and diagnostics. It has no extra dependencies and no hardcoded sample names in production modules. Keeping source order and duplicate records supports the assignment's validation and traceability requirements.

The current result reads and validates input, then generates `reporte_validacion.txt`, `conocimiento.pl`, and `consultas.pl`. Generated knowledge and queries were loaded and checked in SWI-Prolog. HTML and complete pipeline orchestration remain pending. The English vocabulary and stricter lexical conventions are team decisions: both partners should review them, and confirm the expected input vocabulary before the professor supplies a second file.

## Remaining work, in stage order

| Stage | Deliverable |
| --- | --- |
| 7 | HTML generated from the model or generated knowledge |
| 8 | Output IO and orchestration, including safe regeneration after changed or invalid input |
| 9 | End-to-end checks, second input, and browser execution evidence |
| 10 | Doxygen configuration, generated documentation, and complete run instructions |
| 11 | Assignment checklist and oral defense preparation |

## Suggested collaboration boundaries

This is a proposal to agree together, not an assignment of ownership or permission to skip stages:

- Partner A can lead the Haskell parser, validation, and orchestration.
- Partner B can review the model and fixtures now, then lead Prolog generation and the generated UI when those stages are approved.
- Both partners should review each other's changes, contribute tests for their modules, and prepare the documentation and defense together.
- Agree on module APIs before implementation. Coordinate any changes to the shared model, input contract, fixtures, or root README instead of editing them concurrently.

Work uses one task branch and English commits. Stages 1-3 were pushed to `feat/intermediate-model`. Stages 4-6 are on successive local branches: `feat/input-parser`, `feat/input-validation`, and `feat/prolog-generation`. No merge has been performed. Publishing additional work and merging require explicit authorization.

Do not start the next stage until the user approves it.
