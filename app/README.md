# Application entry point

This directory contains executable entry points. Parsing, validation, and generation logic belong in `src/`.

`Main.hs` is the supported complete pipeline command: `runghc -Wall -Werror -isrc app/Main.hs [INPUT OUTPUT_DIRECTORY]`. Omit both arguments for `input/problema.txt` and `output`. It creates the directory, regenerates all four required artifacts, invalidates stale knowledge on errors, and returns 0 for valid/warning-only input or 1 for errors. Cabal builds it as `knowledge-pipeline`.

The earlier-stage commands below are retained for focused inspection and do not synchronize the complete set of outputs.

Use `runghc -Wall -Werror -isrc app/Main.hs [INPUT OUTPUT_DIRECTORY]` to regenerate all four synchronized artifacts.

The default paths are `input/problema.txt` and `output/reporte_validacion.txt`. Input and report must be different files, and the report directory must exist. Exit code 1 indicates validation errors or an IO failure; warnings alone return 0.

Use `runghc -Wall -Werror -isrc app/Main.hs [INPUT OUTPUT_DIRECTORY]` to regenerate all four synchronized artifacts.

Invalid input returns code 1 after writing its report, without updating Prolog files. Existing Prolog output may be stale. IO failures return code 1 and print a message. The command does not invoke SWI-Prolog or generate HTML.
