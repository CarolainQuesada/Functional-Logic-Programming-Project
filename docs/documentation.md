# Doxygen documentation

Run from the repository root with Python 3.10+ and Doxygen in PATH:

```powershell
python tools/build_docs.py
```

Open `docs/html/index.html`. The documentation includes the README, architecture, input contract, stage explanations, executed verification, requirement checklist, defense guide, and an API page for each Haskell module and command.

Doxygen's [supported parser configuration](https://www.doxygen.nl/manual/config.html) does not include Haskell. `tools/build_docs.py` therefore extracts actual top-level Haskell function signatures and data declarations, original line numbers, and adjacent technical comments into `docs/api/haskell-api.dox`. These are native Doxygen documentation pages with literal Haskell code blocks. Doxygen does not compile Haskell or receive fabricated C++ function implementations.

The extractor is tailored to this repository's explicit signatures and column-zero declaration style. If that style changes, update the extractor and inspect the generated pages. The original `.hs` files remain the source of truth. Generated pages and HTML are excluded from Git; the configuration and extractor are tracked, and both generated reference data and HTML are included in the delivery archive.

`docs/Doxyfile` enables Markdown, English output, HTML navigation, and warning-as-error behavior. LaTeX and Graphviz are disabled to avoid extra tools. A successful documentation build has an empty `docs/api/doxygen-warnings.log`.

Python and Doxygen are documentation dependencies only. The application and Haskell test suites do not depend on them.
