# Architecture and functional/logical boundaries

```text
UTF-8 input
    | Input.readProblem
    v
Parser.parseProblem -> Problem with located records and syntax diagnostics
    | Validation.validateProblem
    v
Validated Problem + errors/warnings
    |                         |                         |
    v                         v                         v
Prolog.generateProlog     Html.renderHtml       renderValidationReport
    |                         |                         |
knowledge + queries      complete HTML             text report
    +-------------------------+-------------------------+
                              |
                   Pipeline.runPipeline publishes files
                              |
                   SWI-Prolog / ordinary browser
```

## Data model

`EntityName` preserves identity and case. Algebraic data types distinguish people, courses, teachers, enrollment, teaching, and requested rules. `Located a` adds the physical source line and untouched record text. `Problem` retains declarations, relations, rule requests, section occurrences, and diagnostics. This model is constructed before any output is generated; no stage relies on a chain of text replacements.

The model intentionally accepts partial input. The parser recognizes syntax and known entity/relation vocabulary; the validator resolves references and academic semantics. Unknown rule names survive parsing so the validator can explain unsupported requests. Duplicate records remain available for diagnostics, while generators keep the first repeated relation or rule request.

## Functional core

Parsing, validation, report rendering, HTML rendering, atom escaping, and Prolog generation are pure functions. They use algebraic types, pattern matching, folds, immutable lists, and `Either` for generation failure. Pure tests can compare input/output without reading files or launching processes.

`Input`, `PrologFiles`, the report writer, and `Pipeline` form the IO boundary. The supported command is `app/Main.hs`; focused earlier-stage commands remain available for debugging. The pipeline guards path aliases, collects file-reading failures, and publishes complete individual files using temporary files and rename.

## Logical core

Generated entity and relation facts are the only domain knowledge. Requested Prolog rules infer classmates and courses with teachers. Names are quoted atoms, not variables. Base predicates are declared even with zero facts so empty inputs remain queryable. The browser displays generated knowledge and diagnostics but does not perform logical inference.

## Output and failure invariants

- Every successful run publishes all four required artifacts from the same input model.
- Changing input and rerunning changes knowledge, queries, HTML, and the report without hand-editing output.
- Errors block executable knowledge and hide knowledge download links.
- Missing or undecodable input is reported as a file-level IO diagnostic.
- Per-file publication is atomic, but the set of files is not a single disk transaction; use results only after the command finishes and run one writer per directory.
- Lists and linear lookups keep dependencies minimal and are suitable for course-scale inputs. Very large inputs could use indexed maps without changing the public model.

The project uses only GHC-bundled Haskell libraries. Browser and Doxygen helpers are separate development tooling.
