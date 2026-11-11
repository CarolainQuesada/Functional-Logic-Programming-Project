# Functional-Logic-Programming-Project
An integrated project using Haskell, Prolog, and a web interface to automatically generate, validate, and visualize logical knowledge bases.

## Current stage

The complete academic pipeline is implemented: UTF-8 input, typed intermediate model, validation, Prolog knowledge, suggested queries, generated HTML, and a validation report. The Haskell suites include executable SWI-Prolog checks. Chrome desktop/mobile verification and Doxygen documentation generation are also complete. See [verification evidence](docs/verification.md) and the [requirements checklist](docs/requirements-checklist.md).

See the [model design](docs/intermediate-model.md) and [team handoff](docs/team-handoff.md) for the current API, verification commands, and suggested collaboration boundaries.

## Inicio rápido

Desde la raíz del repositorio, con GHC y SWI-Prolog en PATH:

```powershell
runghc -Wall -Werror -isrc app/Main.hs
```

Open `output/index.html` in a browser. The command regenerates `conocimiento.pl`, `consultas.pl`, `index.html`, and `reporte_validacion.txt`. Nothing in the HTML must be edited manually. To use the second example or the professor's replacement input:

```powershell
runghc -Wall -Werror -isrc app/Main.hs test/fixtures/alternate-valid.txt output/alternate
```

The output directory is created automatically. The input must follow the documented academic vocabulary and grammar. Invalid input returns exit code 1, shows errors in HTML and the report, and replaces previous Prolog with nonexecutable comment markers. Warning-only input returns 0. See [pipeline behavior and limits](docs/pipeline.md).

Alternatively, build and run the executable:

```powershell
cabal build all
cabal run knowledge-pipeline
cabal run knowledge-pipeline -- test/fixtures/alternate-valid.txt output/alternate
```

## Pruebas

Ejecuta las seis suites desde la raíz; PrologTest también ejecuta las comprobaciones de SWI-Prolog:

```powershell
runghc -Wall -Werror -isrc test/ModelTest.hs
runghc -Wall -Werror -isrc test/ParserTest.hs
runghc -Wall -Werror -isrc test/ValidationTest.hs
runghc -Wall -Werror -isrc test/PrologTest.hs
runghc -Wall -Werror -isrc test/HtmlTest.hs
runghc -Wall -Werror -isrc test/PipelineTest.hs
```

Or use `cabal test all --test-show-details=direct`. On Windows, `powershell -ExecutionPolicy Bypass -File tools/test.ps1` runs the suites and regenerates the primary output. Cabal resolves only GHC-bundled libraries (`base`, `directory`, `filepath`, `bytestring`, and `process`); there are no third-party runtime packages.

## Interactive inspection

Run `ghci -isrc src/Input.hs`, then `readProblem "input/problema.txt"` to inspect the model.
Load `swipl -q -s output/consultas.pl` and try `lleva('Ana', C).`,
`companero(X, Y).`, or `suggested_query(Query), call(Query).`.

## Documentation, browser checks, and submission

With Python 3.10+ and Doxygen installed, generate the technical documentation:

```powershell
python tools/build_docs.py
```

Open `docs/html/index.html`. The script extracts real Haskell type declarations and function signatures into Doxygen pages because Doxygen has no native Haskell parser. No synthetic C++ implementation is used. See [documentation generation](docs/documentation.md).

Optional real-browser verification requires Node 22+ and Chrome/Chromium (set `CHROME_BIN` for a custom executable):

```powershell
node tools/browser_check.mjs
```

Screenshots and machine-readable evidence are saved under `output/browser-checks/`. Python, Node, and Doxygen are development/documentation tools; the pipeline itself requires none of them.

Run the complete verification and delivery workflow (GHC, SWI-Prolog, Node, Chrome/Chromium, Python, and Doxygen must be installed):

```powershell
python tools/prepare_submission.py
```

This runs all suites, verifies primary, alternate, assignment, and invalid pages in desktop/mobile Chrome, rebuilds Doxygen, and creates the ZIP with a SHA-256 manifest. Any unexpected failure stops preparation.

To package already generated output:

```powershell
python tools/package_submission.py
```

The packager compares all four primary outputs with a fresh pipeline run and rejects stale results. It rebuilds documentation and includes tracked and nonignored new files, inputs, generated results, technical documentation, and available browser evidence. Review nonignored files before sharing the archive. See the [defense guide](docs/defense-guide.md) before presenting.

## Planned pipeline

`problema.txt -> Haskell -> intermediate model -> Prolog + queries + HTML + validation report`

The official assignment permits the academic domain. See the [input specification](docs/input-format-analysis.md) for the English and Spanish input vocabulary, parsing conventions, validation policy, and source-line handling. Assignment-required filenames and section names are preserved; source code, technical documentation, and commit messages are written in English; the generated user interface is in Spanish.

## Development requirements

- Git for version control.
- GHC and GHCi for Haskell compilation and interactive checks.
- SWI-Prolog for generated knowledge base validation.
- Doxygen for technical documentation.
- A modern browser for generated HTML validation.

Check the tools in PowerShell:

```powershell
git --version
ghc --version
ghci --version
swipl --version
doxygen --version
```

If a command is unavailable, install the corresponding tool and ensure its executable directory is in `PATH`. Open a new terminal after changing `PATH` and repeat the checks. The tested workstation versions are recorded in [development environment](docs/development-environment.md). GHCup, SWI-Prolog, and Doxygen should be obtained from their official distributions.

## Directory structure

The project separates pure transformations from executable entry points and tooling:

```text
app/       Haskell application entry point
src/       Pure data types, parsing, validation, and generation modules
input/     Assignment input files
test/      Test cases and fixtures
docs/      Architecture, assignment notes, and Doxygen configuration
output/    Generated Prolog, queries, HTML, and validation reports
tools/     Test runner, browser checks, documentation, and packaging
```

Generated demonstration output, browser evidence, and the submission ZIP are included in version control for teammates. Local build artifacts and temporary test output are excluded.

The build definition is `functional-logic-pipeline.cabal`. Generated Doxygen HTML and extracted API pages are tracked; open `docs/html/index.html` after downloading or pulling develop.

## Git workflow

- Trabajamos en una rama descriptiva por tarea y coordinamos los archivos compartidos.
- Guardamos cambios enfocados en commits con mensajes en inglés.
- Ejecutamos las pruebas antes de compartir la rama y describimos los resultados en el PR.
- Revisamos los cambios en equipo antes de fusionarlos.

## Setup status

Stage 1 is complete on this Windows workstation. Verified on October 21, 2026: Git 2.44.0, GHC and GHCi 9.10.3, Cabal 3.16.1.0, SWI-Prolog 10.1.17, and Doxygen 1.18.0.

GHCi evaluation, Haskell compilation and executable execution, and a Prolog arithmetic query passed. See [development environment](docs/development-environment.md) for setup and verification details. Restart existing terminals and editors to pick up the updated user PATH.


```text
problema.txt (UTF-8)
    -> Parser -> Problem + SourceLine
    -> Validation -> diagnostics (errors block; warnings continue)
    -> Prolog / Html / ValidationReport
    -> Pipeline -> conocimiento.pl + consultas.pl + index.html + reporte_validacion.txt
```

Names accept Unicode letters, digits, underscores and internal spaces. Types and rule
identifiers remain ASCII. Blank lines and lines beginning with # or % are ignored;
physical source line numbers are preserved. Both English and Spanish input aliases
produce Spanish Prolog predicates. Only requested rules are generated, including
companeros_en_curso, estudiante_de and curso_sin_docente.
