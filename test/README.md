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

`PrologTest.hs` checks the pure generator and executes generated files with SWI-Prolog. Ensure `swipl` is in PATH:

```powershell
runghc -Wall -Werror -isrc test/PrologTest.hs
```

On October 22, 2026, the suite compiled with `ghc -Wall -Werror -isrc`; all 16 generation checks and 13 SWI-Prolog checks passed. All 74 existing Haskell checks passed again. Coverage includes invalid-input rejection, traceability, case-sensitive atoms and escaping, duplicate warnings, absent rules, empty data, multiple shared courses and teachers, and loading/calling suggested queries. SWI-Prolog checks require successful exit and empty standard error, so loading warnings fail the suite.

Generated scenarios are written under `output/prolog-checks/` and are ignored by Git. The suite uses GHC's bundled `process`, `directory`, and `filepath` libraries; it requires no third-party Haskell packages. Command checks also verified primary output and report-only behavior for an invalid input in a fresh directory.

`HtmlTest.hs` adds 18 checks for generated content, source lines, regeneration, warning/error/empty states, HTML escaping, and offline responsive styling. `PipelineTest.hs` adds 19 actual-file integration checks, including stale-output replacement, missing input, invalid UTF-8, BOM/CRLF, alias rejection, and recovery.

Run all six suites with `cabal test all --test-show-details=direct` or `powershell -ExecutionPolicy Bypass -File tools/test.ps1`. The final total is 127 Haskell checks and 13 SWI-Prolog checks. Browser verification is separate: `node tools/browser_check.mjs` checks actual emulated desktop/mobile sizes, overflow, links, keyboard focus, navigation, and runtime exceptions. See [execution evidence](../docs/verification.md).
