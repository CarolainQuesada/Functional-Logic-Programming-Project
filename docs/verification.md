# Verification evidence

Executed locally on Windows on October 22, 2026. This is execution evidence, not a list of unrun test plans.

## Automated results

| Suite | Passing checks |
| --- | ---: |
| Intermediate model | 12 |
| Functional parser | 33 |
| Semantic validation and reports | 29 |
| Pure Prolog generation | 16 |
| Generated HTML | 18 |
| Complete pipeline | 19 |
| SWI-Prolog loading and query results | 13 |
| Total | 140 |

All six Cabal test suites passed with `-Wall -Werror`. `cabal build all --offline` also completed. The pipeline test suite uses actual files for BOM/CRLF, invalid UTF-8, missing input, and output replacement, not just in-memory examples. It proves that each existing invalid fixture replaces prior valid executable knowledge with blocked markers, and that valid input recovers afterward.

SWI-Prolog tests require an exit code of 0 and empty standard error. Scenarios include both valid inputs, empty data, absent rules, repeated relations/rules, multiple shared courses and teachers, case-sensitive names, executable query suggestions, and quoted-atom round trips.

## Browser execution

Chrome 156.0.8078.47 loaded the actual generated HTML for the primary input, alternate input, and duplicate-entity error. Each was checked with exact emulated viewports of 1440x1200 and 390x1100. Checks cover all six required data sections, links to real files, internal anchors, keyboard skip-link focus, absence of browser runtime exceptions, and no page-level horizontal overflow.

Screenshots, full-page screenshots, rendered DOM, and machine-readable browser results are generated under:

- `output/browser-checks/`: primary valid input.
- `output/browser-alternate/`: second valid input.
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
