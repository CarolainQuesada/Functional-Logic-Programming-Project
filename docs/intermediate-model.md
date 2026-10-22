# Intermediate model

## Scope

Stage 3 provides a pure Haskell representation of the academic input contract using only `base`. It does not read files, parse text, validate the domain, or generate output.

## Modules

| Module | Responsibility |
| --- | --- |
| `Source` | `SourceLine` stores a one-based physical line number and unmodified source text; `Located a` attaches it to any record |
| `Diagnostic` | Structured severity, code, message, primary location, and related source lines |
| `Model` | Academic entities, relations, requested rules, sections, and the complete `Problem` |

Dependencies flow from `Model` to `Diagnostic` and `Source`, and from `Diagnostic` to `Source`. There is no file IO in these modules.

## Representation decisions

- `EntityName` distinguishes references from arbitrary strings and preserves case.
- `Entity` has `Person`, `Course`, and `Teacher` constructors.
- `Relation` has `Enrolled` and `Teaches` constructors, each containing two entity names.
- `RequestedRule` distinguishes `Classmates`, `CourseWithTeacher`, and `UnknownRule String`. Unknown names remain available for stage 5 domain validation.
- `Problem` retains located section occurrences, entities, relations, requested rules, and accumulated diagnostics.
- Lists preserve source order and duplicates. Later validation can diagnose duplicates before generation removes repeated relations and rules.
- `FileLocation` represents missing sections without assigning them a fictional source line. `LineLocation` and related lines support duplicate diagnostics and traceability.

Constructors are intentionally available for the parser to build partially valid input models. `EntityName` does not itself enforce identifier syntax, and `SourceLine` does not itself enforce positive numbering. Stage 4 must assign real one-based physical line numbers and check record syntax; stage 5 must resolve names, argument kinds, duplicates, missing sections, and unsupported rules. The current model must not be mistaken for a validated problem.

## Pure operations

- `emptyProblem` creates an empty intermediate model.
- `entityName` and `entityKind` inspect an entity.
- `relationReferences` returns references in argument order with their required entity kinds; it does not check whether declarations exist.
- `mapLocated` transforms a record while preserving its source metadata.
- `hasErrors` checks diagnostic severity; it does not discover errors on its own.

## Verification

`test/ModelTest.hs` covers case-sensitive identity, argument roles, source preservation, duplicate retention, unknown rules, file-level diagnostics, and the difference between errors and warnings.

The suite compiled with `ghc -Wall -Werror -isrc` and all 12 checks passed when the compiled executable ran. Build products were written to a temporary directory outside the repository. The same suite can be interpreted with `runghc -Wall -Werror -isrc test/ModelTest.hs`.

The implemented parser, validator, and generators consume this model. Generators do not reparse original input strings. See [complete architecture](architecture.md).
