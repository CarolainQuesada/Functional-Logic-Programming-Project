# Functional-Logic-Programming-Project
An integrated project using Haskell, Prolog, and a web interface to automatically generate, validate, and visualize logical knowledge bases.

## Current stage

The complete academic pipeline is implemented: UTF-8 input, typed intermediate model, validation, Prolog knowledge, suggested queries, generated HTML, and a validation report. All 127 Haskell checks and 13 SWI-Prolog checks pass. Chrome desktop/mobile verification and Doxygen documentation generation are also complete. See [verification evidence](docs/verification.md) and the [requirements checklist](docs/requirements-checklist.md).

See the [model design](docs/intermediate-model.md) and [team handoff](docs/team-handoff.md) for the current API, verification commands, and suggested collaboration boundaries.

## Quick start

Run from the repository root with GHC/GHCi and SWI-Prolog in PATH:

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

## Checks

Run the current checks from the repository root:

```powershell
runghc -Wall -Werror -isrc test/ModelTest.hs
runghc -Wall -Werror -isrc test/ParserTest.hs
runghc -Wall -Werror -isrc test/ValidationTest.hs
runghc -Wall -Werror -isrc test/PrologTest.hs
runghc -Wall -Werror -isrc test/HtmlTest.hs
runghc -Wall -Werror -isrc test/PipelineTest.hs
```

Or use `cabal test all --test-show-details=direct`. On Windows, `powershell -ExecutionPolicy Bypass -File tools/test.ps1` runs the suites and regenerates the primary output. Cabal resolves only GHC-bundled libraries (`base`, `directory`, `filepath`, `bytestring`, and `process`); there are no third-party runtime packages.

## Focused inspection commands

The following earlier-stage tools are retained for focused checks. Use `app/Main.hs` for complete, synchronized regeneration.

For interactive input inspection, run `ghci -isrc src/Input.hs`, then `readProblem "input/problema.txt"`. This returns the parsed model, not generated outputs or a semantic validation result.

Validate the primary input and generate `output/reporte_validacion.txt`:

```powershell
runghc -Wall -Werror -isrc app/Validate.hs
```

To use different paths, pass both the input and report paths. The report directory must already exist:

```powershell
runghc -Wall -Werror -isrc app/Validate.hs test/fixtures/duplicate-entity.txt output/duplicate-report.txt
```

The command exits with code 0 for valid input, including warnings, and code 1 for validation errors or IO failures. See [validation behavior](docs/validation.md).

Generate `output/conocimiento.pl`, `output/consultas.pl`, and the validation report:

```powershell
runghc -Wall -Werror -isrc app/GenerateProlog.hs
swipl -q -s output/consultas.pl
```

In SWI-Prolog, try `classmate(First, Second).`, `course_with_teacher(Course).`, or `suggested_query(Query), call(Query).`. Names preserve input case and are quoted atoms, for example `'Alice'`.

For this focused Prolog-only command, pass `INPUT OUTPUT_DIRECTORY`; the directory must already exist. Errors block generation but leave existing Prolog untouched. Use the complete pipeline above for stale-output invalidation and synchronized HTML. See [Prolog generation](docs/prolog-generation.md).

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

After regenerating output and documentation, create the deliverable archive:

```powershell
python tools/package_submission.py
```

The archive includes repository source, inputs, generated results, technical documentation, and available browser evidence. See the [defense guide](docs/defense-guide.md) before presenting.

## Planned pipeline

`problema.txt -> Haskell -> intermediate model -> Prolog + queries + HTML + validation report`

The official assignment permits the academic domain. See the [input specification](docs/input-format-analysis.md) for the English record vocabulary, parsing conventions, validation policy, and source-line handling. Assignment-required filenames and section names are preserved; source code, documentation, UI text, and commit messages are written in English.

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

Generated output and local build artifacts are excluded from version control. Only the README in `output/` is tracked.

The build definition is `functional-logic-pipeline.cabal`. Generated Doxygen HTML and extracted API pages are also ignored; the submission archive includes them.

## Git workflow

- Use one descriptive branch per task, such as `chore/initial-setup` or `feat/input-parser`.
- Keep each commit focused and write its message in English.
- Review existing files before editing and coordinate changes to a teammate's work.
- Validate each stage and wait for approval before starting the next stage.
- Pushes, merges, destructive resets, and file deletions require explicit authorization.

## Setup status

Stage 1 is complete on this Windows workstation. Verified on October 21, 2026: Git 2.44.0, GHC and GHCi 9.10.3, Cabal 3.16.1.0, SWI-Prolog 10.1.17, and Doxygen 1.18.0.

GHCi evaluation, Haskell compilation and executable execution, and a Prolog arithmetic query passed. See [development environment](docs/development-environment.md) for setup and verification details. Restart existing terminals and editors to pick up the updated user PATH.
