# Functional-Logic-Programming-Project
An integrated project using Haskell, Prolog, and a web interface to automatically generate, validate, and visualize logical knowledge bases.

## Current stage

Stage 6: input parsing, validation, reports, Prolog knowledge generation, and suggested queries are implemented. All 90 Haskell checks and 13 SWI-Prolog checks pass. HTML generation and complete pipeline orchestration are not implemented yet.

See the [model design](docs/intermediate-model.md) and [team handoff](docs/team-handoff.md) for the current API, verification commands, and suggested collaboration boundaries.

Run the current checks from the repository root:

```powershell
runghc -Wall -Werror -isrc test/ModelTest.hs
runghc -Wall -Werror -isrc test/ParserTest.hs
runghc -Wall -Werror -isrc test/ValidationTest.hs
runghc -Wall -Werror -isrc test/PrologTest.hs
```

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

For another input, pass `INPUT OUTPUT_DIRECTORY`; the directory must already exist. Errors block Prolog generation and produce a report. Existing Prolog files are left unchanged on invalid input and may be stale. See [Prolog generation](docs/prolog-generation.md) for behavior and current limits.

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

If a command is unavailable, install the corresponding tool and ensure its executable directory is in `PATH`. Open a new terminal after changing `PATH` and repeat the checks. The validation command is available above; the complete pipeline is not implemented yet.

## Directory structure

Each directory includes a README describing its responsibility. Application modules will be added in later stages:

```text
app/       Haskell application entry point
src/       Pure data types, parsing, validation, and generation modules
input/     Assignment input files
test/      Test cases and fixtures
docs/      Architecture, assignment notes, and Doxygen configuration
output/    Generated Prolog, queries, HTML, and validation reports
```

Generated output and local build artifacts are excluded from version control. Only the README in `output/` is tracked.

## Git workflow

- Use one descriptive branch per task, such as `chore/initial-setup` or `feat/input-parser`.
- Keep each commit focused and write its message in English.
- Review existing files before editing and coordinate changes to a teammate's work.
- Validate each stage and wait for approval before starting the next stage.
- Pushes, merges, destructive resets, and file deletions require explicit authorization.

## Setup status

Stage 1 is complete on this Windows workstation. Verified on October 21, 2026: Git 2.44.0, GHC and GHCi 9.10.3, Cabal 3.16.1.0, SWI-Prolog 10.1.17, and Doxygen 1.18.0.

GHCi evaluation, Haskell compilation and executable execution, and a Prolog arithmetic query passed. See [development environment](docs/development-environment.md) for setup and verification details. Restart existing terminals and editors to pick up the updated user PATH.
