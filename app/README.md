# Application entry point

This directory contains the command-line entry point. Parsing, validation, and generation logic belong in `src/`.

`Main.hs` runs the complete pipeline:

```powershell
runghc -Wall -Werror -isrc app/Main.hs [INPUT OUTPUT_DIRECTORY]
```

Without arguments it reads `input/problema.txt` and writes to `output`. It creates the output directory if needed and regenerates `conocimiento.pl`, `consultas.pl`, `index.html`, and `reporte_validacion.txt`.

The command returns 0 for valid or warning-only input. It returns 1 when the input has errors, after writing the report and the HTML and replacing both Prolog files with blocked-generation comments, and also for usage or IO errors. Cabal builds it as `knowledge-pipeline`.
