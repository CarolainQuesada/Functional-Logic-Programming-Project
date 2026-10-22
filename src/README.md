# Haskell modules

This directory contains the intermediate data model and functional parser. Validation and output generation modules will be added in their approved stages.

- `Source.hs`: physical source lines and located values.
- `Diagnostic.hs`: diagnostic severity, codes, locations, and error detection.
- `Model.hs`: academic entities, relations, requested rules, section occurrences, and the complete problem.
- `Parser.hs`: pure text-to-model parsing with syntax diagnostics and physical line preservation.
- `Input.hs`: UTF-8 file reading, kept separate from pure transformations.

Keep data transformations pure where possible and separate them from file input and output. Add modules incrementally as each development stage is approved.
