# Team handoff

## Completed

1. Initial repository structure, ignore rules, and English documentation.
2. Local Windows tools verified: GHC/GHCi 9.10.3, Cabal 3.16.1.0, SWI-Prolog 10.1.17, Doxygen 1.18.0, and Git 2.44.0.
3. Academic domain confirmed against the supplied assignment; input conventions and valid/invalid fixtures documented.
4. Intermediate Haskell model implemented in `Source.hs`, `Diagnostic.hs`, and `Model.hs`.
5. All 12 model checks passed after compilation with `-Wall -Werror`.

## Feedback on the current work

The project now has a clear input contract and a model that separates domain data, source traceability, and diagnostics. It has no extra dependencies and no hardcoded sample names in production modules. Keeping source order and duplicate records supports the assignment's validation and traceability requirements.

The current result is a tested foundation, not an executable pipeline. Input fixtures have not been run through a parser. The English vocabulary and stricter lexical conventions are team decisions: both partners should review them, and confirm the expected input vocabulary before the professor supplies a second file.

## Remaining work, in stage order

| Stage | Deliverable |
| --- | --- |
| 4 | Functional parser, physical line numbering, section recognition, and parser checks |
| 5 | Semantic validation and `reporte_validacion.txt` |
| 6 | Prolog facts, rules, traceability comments, queries, and SWI-Prolog checks |
| 7 | HTML generated from the model or generated knowledge |
| 8 | File IO and orchestration, including safe regeneration after changed or invalid input |
| 9 | End-to-end checks, second input, and browser execution evidence |
| 10 | Doxygen configuration, generated documentation, and complete run instructions |
| 11 | Assignment checklist and oral defense preparation |

## Suggested collaboration boundaries

This is a proposal to agree together, not an assignment of ownership or permission to skip stages:

- Partner A can lead the Haskell parser, validation, and orchestration.
- Partner B can review the model and fixtures now, then lead Prolog generation and the generated UI when those stages are approved.
- Both partners should review each other's changes, contribute tests for their modules, and prepare the documentation and defense together.
- Agree on module APIs before implementation. Coordinate any changes to the shared model, input contract, fixtures, or root README instead of editing them concurrently.

Work uses one task branch and English commits. The current model branch is `feat/intermediate-model`. It includes the earlier local setup and specification commits by ancestry. No push or merge has been performed, so the teammate cannot assume this local work is available on GitHub yet. Publishing and merging require explicit authorization.

Do not start the next stage until the user approves it.
