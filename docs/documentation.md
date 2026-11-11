# Doxygen documentation

Run from the repository root with Python 3.10+ and Doxygen in PATH:

```powershell
python tools/build_docs.py
```

Open `docs/html/index.html`. The documentation includes the README, architecture, input contract, module explanations, executed verification, requirement checklist, defense guide, and an API page for each Haskell module and command.

Doxygen's [supported parser configuration](https://www.doxygen.nl/manual/config.html) does not include Haskell. `tools/build_docs.py` therefore extracts actual top-level Haskell function signatures and data declarations, original line numbers, and adjacent technical comments into `docs/api/haskell-api.dox`. These are native Doxygen documentation pages with literal Haskell code blocks. Doxygen does not compile Haskell or receive fabricated C++ function implementations.

The extractor is tailored to this repository's explicit signatures and column-zero declaration style. If that style changes, update the extractor and inspect the generated pages. The original `.hs` files remain the source of truth. The configuration, the extractor, the generated reference pages, and the generated HTML are all committed to the repository, and both generated reference data and HTML are included in the delivery archive. Rebuild and commit them together whenever the Haskell sources change.

The committed HTML was generated with Doxygen 1.18.0. Doxygen 1.9.8 fails on this configuration with a duplicate main page error, so use 1.18.0 or newer to rebuild it.

`docs/Doxyfile` enables Markdown, English output, HTML navigation, and warning-as-error behavior. LaTeX and Graphviz are disabled to avoid extra tools. A successful documentation build has an empty `docs/api/doxygen-warnings.log`.

Python and Doxygen are documentation dependencies only. The application and Haskell test suites do not depend on them.
