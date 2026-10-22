# Tests and fixtures

This directory will contain tests and input fixtures for the parser, validation rules, generators, and complete pipeline.

Add valid and invalid cases alongside the corresponding implementation. Record actual execution results.

Stage 2 provides input examples and expected diagnostics in [fixtures](fixtures/README.md). Stages 4 and 5 execute them against the parser and semantic validator.

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

`ValidationTest.hs` checks all fixture outcomes, cross-type duplicates, both relation argument roles, forward references, missing/repeated sections, duplicate warnings, parser error retention, noncascading ambiguous-name diagnostics, repeated validation, and report content:

```powershell
runghc -Wall -Werror -isrc test/ValidationTest.hs
```

On October 22, 2026, the validation suite compiled with `ghc -Wall -Werror -isrc`; all 29 checks passed. All 45 existing model and parser checks passed again. The validation command also generated a successful report from the primary input, wrote an invalid duplicate-entity report with exit code 1, and rejected a report path alias pointing to the input file.
