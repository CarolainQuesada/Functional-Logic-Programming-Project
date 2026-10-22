# Application entry point

This directory contains executable entry points. Parsing, validation, and generation logic belong in `src/`.

`Validate.hs` runs the stage 5 input reader, validator, and report writer. Run it from the repository root with `runghc -Wall -Werror -isrc app/Validate.hs`. Optional arguments are the input path and report path, provided together.

The default paths are `input/problema.txt` and `output/reporte_validacion.txt`. Input and report must be different files, and the report directory must exist. Exit code 1 indicates validation errors or an IO failure; warnings alone return 0. Full pipeline orchestration remains stage 8 work.
