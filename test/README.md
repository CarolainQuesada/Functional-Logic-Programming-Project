# Tests and fixtures

This directory will contain tests and input fixtures for the parser, validation rules, generators, and complete pipeline.

Add valid and invalid cases alongside the corresponding implementation. Record actual execution results.

Stage 2 provides input examples and expected diagnostics in [fixtures](fixtures/README.md). Stage 4 executes them against the parser; semantic outcomes remain pending stage 5 validation.

`ModelTest.hs` checks the stage 3 model, reference roles, source preservation, duplicate retention, and diagnostics. Run from the repository root:

```powershell
runghc -Wall -Werror -isrc test/ModelTest.hs
```

The stage 3 verification also compiled the suite with `ghc -Wall -Werror -isrc` into a temporary directory and executed it. All 12 checks passed. No external test framework is required.

`ParserTest.hs` checks both valid inputs, all invalid fixtures, error recovery, source locations, BOM/CRLF handling, lexical conventions, and retention of records awaiting semantic validation:

```powershell
runghc -Wall -Werror -isrc test/ParserTest.hs
```

On October 22, 2026, the parser suite compiled with `ghc -Wall -Werror -isrc` and its executable passed all 33 checks. The 12 model checks also passed again. Temporary compilation products were written outside the repository.
