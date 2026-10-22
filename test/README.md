# Tests and fixtures

This directory will contain tests and input fixtures for the parser, validation rules, generators, and complete pipeline.

Add valid and invalid cases alongside the corresponding implementation. Record actual execution results.

Stage 2 provides input examples and expected diagnostics in [fixtures](fixtures/README.md). These examples are prepared for future tests; they have not been executed against a parser.

`ModelTest.hs` checks the stage 3 model, reference roles, source preservation, duplicate retention, and diagnostics. Run from the repository root:

```powershell
runghc -Wall -Werror -isrc test/ModelTest.hs
```

The stage 3 verification also compiled the suite with `ghc -Wall -Werror -isrc` into a temporary directory and executed it. All 12 checks passed. No external test framework is required.
