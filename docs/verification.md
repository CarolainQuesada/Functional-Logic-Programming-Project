# Verification evidence

This document records executed verification. The counts below are the current suite totals.

## Automated results

| Suite | Passing checks |
| --- | ---: |
| Intermediate model | 13 |
| Functional parser | 38 |
| Semantic validation and reports | 30 |
| Pure Prolog generation | 16 |
| Generated HTML | 19 |
| Complete pipeline | 22 |
| SWI-Prolog loading and query results | 17 |
| Total | 155 |

All six Cabal test suites passed with `-Wall -Werror`. `cabal build all --offline` also completed. The pipeline test suite uses actual files for BOM/CRLF, invalid UTF-8, missing input, and output replacement, not just in-memory examples. It proves that each existing invalid fixture replaces prior valid executable knowledge with blocked markers, and that valid input recovers afterward.

SWI-Prolog tests require an exit code of 0 and empty standard error. Scenarios include both valid inputs, empty data, absent rules, repeated relations/rules, multiple shared courses and teachers, case-sensitive names, executable query suggestions, and quoted-atom round trips.

## Browser execution

Chrome/Chromium loaded the actual generated HTML for the primary input, the alternate input, the exact assignment example, the Unicode example, and the duplicate-entity error. The browser version used for each scenario is recorded in its `results.json`. Each was checked with exact emulated viewports of 1440x1200 and 390x1100. Checks cover all six required data sections, links to real files, internal anchors, keyboard skip-link focus, absence of browser runtime exceptions, and no page-level horizontal overflow.

Screenshots, full-page screenshots, rendered DOM, and machine-readable browser results are generated under:

- `output/browser-checks/`: primary valid input.
- `output/browser-alternate/`: second valid input.
- `output/browser-assignment/`: exact assignment example.
- `output/browser-unicode/`: Unicode names and a nonblocking warning.
- `output/browser-invalid/`: invalid input and diagnostics.

Desktop and mobile captures were visually reviewed. The initial command-line screenshot method clipped a 390px image from a wider Chrome layout; it was replaced with explicit DevTools device metrics and a scroll-width assertion. Current evidence verifies actual viewport width rather than relying on the screenshot filename.

## Issues found and resolved

- Cabal requires the test `type` field in each suite rather than in a common stanza; the configuration was corrected before the successful build.
- Strict compilation found an unused test import; it was removed before the suite passed.
- A Windows file replacement briefly failed despite modify permission and succeeded on retry. Publication now retries permission-related rename failures for at most 800ms; persistent errors still fail the command. The integration suite passed after the change.

## Reproduction

```powershell
cabal test all --test-show-details=direct
runghc -Wall -Werror -isrc app/Main.hs
python tools/browser_check.py
python tools/build_docs.py
```

Browser verification uses Node 22+ and a local Chrome/Chromium executable, with no npm packages. Python is used only for tooling. `CHROME_BIN` can select the browser explicitly. Runtime pipeline execution does not require Python, Node, Doxygen, or a browser automation library.

## Assignment compatibility and delivery improvements

English and Spanish aliases normalize to the same model. The exact assignment fixture is exercised through parsing, the full pipeline, real SWI-Prolog queries, and desktop/mobile Chrome. Integration checks also force publication failure and verify temporary-file cleanup. Main functions document their inputs, output contracts, and error handling.

Use `python tools/prepare_submission.py` for the complete workflow. Packaging rejects stale primary artifacts, rebuilds Doxygen, includes nonignored new source files, and verifies archive contents with SHA-256 hashes in `submission-manifest.json`.

## Defense readiness verification (2026-11-09)

All commands ran from the repository root with `-Wall -Werror` unchanged:

| Command | Result |
| --- | --- |
| `runghc -Wall -Werror -isrc test/ModelTest.hs` | 13 passed |
| `runghc -Wall -Werror -isrc test/ParserTest.hs` | 38 passed |
| `runghc -Wall -Werror -isrc test/ValidationTest.hs` | 30 passed |
| `runghc -Wall -Werror -isrc test/PrologTest.hs` | 16 generation and 17 SWI-Prolog checks passed |
| `runghc -Wall -Werror -isrc test/HtmlTest.hs` | 19 passed |
| `runghc -Wall -Werror -isrc test/PipelineTest.hs` | 22 passed |
| `python test/PackageTest.py` | Cache and Git exclusion regression passed |
| `runghc -Wall -Werror -isrc app/Main.hs` | Four Spanish-input artifacts regenerated |
| `python tools/build_docs.py` | 13 modules; zero Doxygen warnings |
| `python tools/package_submission.py` | ZIP integrity and SHA-256 manifest verified |
| `node tools/browser_check.mjs output/index.html output/browser-checks` | Desktop and mobile passed |
| `node tools/browser_check.mjs output/unicode-example/index.html output/browser-unicode` | Unicode desktop and mobile passed |

Direct SWI-Prolog queries return `[Paradigmas]` for Ana's courses and
`[Ana-Luis,Luis-Ana]` for ordered classmate pairs. The Unicode example includes a
course without a teacher; its warning appears in the report and HTML and does not
block Prolog generation.
