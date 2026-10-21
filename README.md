# Functional-Logic-Programming-Project
An integrated project using Haskell, Prolog, and a web interface to automatically generate, validate, and visualize logical knowledge bases.

## Current stage

Stage 2: the academic input format and example fixtures are defined. No application logic has been implemented.

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

If a command is unavailable, install the corresponding tool and ensure its executable directory is in `PATH`. Open a new terminal after changing `PATH` and repeat the checks. No application build or run command is available yet.

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
