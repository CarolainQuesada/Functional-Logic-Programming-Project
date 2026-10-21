# Functional-Logic-Programming-Project
An integrated project using Haskell, Prolog, and a web interface to automatically generate, validate, and visualize logical knowledge bases.

## Current stage

Stage 1: initial repository and development environment setup. No application logic has been implemented.

## Planned pipeline

`problema.txt -> Haskell -> intermediate model -> Prolog + queries + HTML + validation report`

The input format and academic domain must be checked against the official assignment before implementation. Assignment-required filenames and section names will be preserved; source code, documentation, UI text, and commit messages will be written in English.

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

## Proposed directory structure

Directories will be added when their first files are needed:

```text
app/       Haskell application entry point
src/       Pure data types, parsing, validation, and generation modules
input/     Assignment input files
test/      Test cases and fixtures
docs/      Architecture, assignment notes, and Doxygen configuration
output/    Generated Prolog, queries, HTML, and validation reports
```

Generated output and local build artifacts are excluded from version control.

## Git workflow

- Use one descriptive branch per task, such as `chore/initial-setup` or `feat/input-parser`.
- Keep each commit focused and write its message in English.
- Review existing files before editing and coordinate changes to a teammate's work.
- Validate each stage and wait for approval before starting the next stage.
- Pushes, merges, destructive resets, and file deletions require explicit authorization.

## Setup status

The initial check on Windows found Git 2.44.0. GHC, GHCi, SWI-Prolog, and Doxygen were not available in `PATH`. Their installation or executable locations still need to be verified before this stage can be considered complete.
