# Haskell modules

This directory contains the complete pipeline. Parsing, validation, and rendering remain pure; file IO is isolated in the reader, writers, and pipeline coordinator.

- `Source.hs`: physical source lines and located values.
- `Diagnostic.hs`: diagnostic severity, codes, locations, and error detection.
- `Model.hs`: academic entities, relations, requested rules, section occurrences, and the complete problem.
- `Parser.hs`: pure text-to-model parsing with syntax diagnostics and physical line preservation.
- `Input.hs`: UTF-8 file reading, kept separate from pure transformations.
- `Validation.hs`: pure semantic checks, preserving records and existing parser diagnostics.
- `ValidationReport.hs`: pure report rendering and a separate UTF-8 report writer.
- `Prolog.hs`: pure validated knowledge and suggested-query generation with source comments.
- `PrologFiles.hs`: UTF-8 output for the generated Prolog files.
- `Html.hs`: generated English interface, source tables, diagnostics, and HTML escaping.
- `HtmlStyle.hs`: self-contained responsive styles.
- `Pipeline.hs`: complete regeneration, file-level input errors, blocked output, and per-file publication.

Keep data transformations pure where possible and separate them from file input and output. Add modules incrementally as each development stage is approved.
