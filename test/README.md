# Tests and fixtures

This directory contains the tests and input fixtures for the model, parser, validation rules, generators, and complete pipeline. Input examples and their expected diagnostics are listed in [fixtures](fixtures/README.md).

Run each suite from the repository root:

```powershell
runghc -Wall -Werror -isrc test/ModelTest.hs
runghc -Wall -Werror -isrc test/ParserTest.hs
runghc -Wall -Werror -isrc test/ValidationTest.hs
runghc -Wall -Werror -isrc test/PrologTest.hs
runghc -Wall -Werror -isrc test/HtmlTest.hs
runghc -Wall -Werror -isrc test/PipelineTest.hs
```

| Suite | Checks | Coverage |
| --- | ---: | --- |
| `ModelTest.hs` | 13 | Intermediate model, reference roles, source preservation, duplicate retention, and diagnostics |
| `ParserTest.hs` | 38 | Valid inputs, invalid fixtures, error recovery, source locations, BOM/CRLF, lexical conventions, and records kept for validation |
| `ValidationTest.hs` | 30 | Fixture outcomes, cross-type duplicates, argument roles, forward references, missing and repeated sections, duplicate warnings, repeated validation, and report content |
| `PrologTest.hs` | 16 + 17 | Pure generation checks, plus SWI-Prolog checks that load the generated files and run queries |
| `HtmlTest.hs` | 19 | Generated content, source lines, regeneration, warning/error/empty states, HTML escaping, and offline responsive styling |
| `PipelineTest.hs` | 22 | Real files, stale-output replacement, missing input, invalid UTF-8, BOM/CRLF, alias rejection, and recovery |

`PrologTest.hs` requires `swipl` in `PATH`. SWI-Prolog checks require a successful exit and empty standard error, so loading warnings fail the suite. Generated scenarios are written under `output/prolog-checks/` and `output/pipeline-checks/` and are not tracked. The suites use only GHC-bundled libraries.

Run all six suites with `cabal test all --test-show-details=direct` or `powershell -ExecutionPolicy Bypass -File tools/test.ps1`. `python test/PackageTest.py` checks the submission packager exclusions. Browser verification is separate; see [execution evidence](../docs/verification.md).
