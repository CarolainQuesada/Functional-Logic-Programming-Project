# Assignment requirement checklist

This checklist maps the supplied assignment to implemented artifacts and executed evidence. The assignment permits adapting the academic domain; the exact accepted vocabulary is documented in the input contract.

| Requirement | Implementation and evidence |
| --- | --- |
| Read `problema.txt` | `Input.readProblem`; primary and alternate fixture tests |
| Separate input sections | `Parser.parseProblem`; 33 syntax checks |
| Use pure Haskell transformations | Parser, validation, Prolog, HTML, and report renderers |
| Define custom types and an intermediate model | `Source`, `Model`, `Diagnostic`; 12 model checks |
| Validate duplicates, references, formats, sections, and rules | `Validation` plus parser diagnostics; 29 validation checks |
| Generate error/warning report | `ValidationReport`; real report and exit-status checks |
| Generate valid Prolog facts, relations, and requested rules | `Prolog`; 16 generation and 13 real SWI-Prolog checks |
| Preserve original line traceability | Located records and generated source comments |
| Generate `consultas.pl` | Suggested query terms and sibling knowledge loader; executed queries |
| Generate HTML from model or knowledge | `Html` calls the same model/generator; no hardcoded entity data |
| Show entities, relations, facts, rules, queries, diagnostics, and knowledge | Six interface sections; 18 HTML checks and real Chrome verification |
| Regenerate outputs after changed input | `Pipeline`; primary-to-alternate integration scenario |
| Handle a second input during defense | Alternate fixture executed through the complete pipeline and in Chrome |
| Execute in Haskell, SWI-Prolog, and browser | Six Cabal suites, SWI-Prolog processes, Chrome desktop/mobile evidence |
| Doxygen documentation | Generated API pages and HTML; warning-as-error build |
| README with setup and execution | Root README and development-environment guide |
| Prepare final delivery | Reproducible ZIP with source, input, all required outputs, docs, and evidence |
| Explain design during defense | Architecture and defense guide |

All software tasks in the eleven-stage plan are complete. Team review, confirmation of the professor's expected input vocabulary, presentation practice, and uploading to the course platform remain human delivery activities. This checklist does not claim the oral defense or submission has happened.

Generated results are present locally and included in the submission archive, rather than tracked in Git. No push, merge, or course-platform submission is performed by the final implementation task.
