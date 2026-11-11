# Semantic validation and reports

## API

`Validation.validateProblem :: Problem -> Problem` is pure. It retains all records and their source metadata, preserves parser diagnostics, and adds semantic diagnostics. Revalidating the same unchanged model does not duplicate diagnostics. If the input changes, parse it again before validation rather than editing a previously validated model with stale findings.

The validator checks required and repeated sections, globally duplicate entity names, undeclared references, relation argument kinds, unsupported requested rules, and repeated relations and rules. Names remain case-sensitive. References are resolved against all declarations, allowing section reordering and forward references.

Duplicate entities are errors even across different types. Every repeat points to the first declaration. References to ambiguous duplicate names do not receive additional type-mismatch diagnostics: the duplicate error already prevents generation. Repeated relations and requested rules are warnings. The validator preserves them so future generators can keep the first occurrence with its source information.

Malformed lines and unknown vocabulary remain the parser's responsibility. Missing sections use file-level diagnostics, not artificial source lines. Existing syntax errors do not stop independent semantic checks.

## Reports and command

`ValidationReport.renderValidationReport :: Problem -> String` renders a validated model as an English report with status, error/warning counts, diagnostic codes, source lines, and related declaration locations. Call it after validation; rendering alone does not discover errors.

Use `runghc -Wall -Werror -isrc app/Main.hs [INPUT OUTPUT_DIRECTORY]` to regenerate all four synchronized artifacts.

Use `runghc -Wall -Werror -isrc app/Main.hs [INPUT OUTPUT_DIRECTORY]` to regenerate all four synchronized artifacts.

The domain modules use `base`; the command also uses GHC's bundled `directory` and `filepath` libraries for path checking. No third-party packages or installation are required.

## Verification

On October 22, 2026, the compiled validation suite passed all 29 checks with `-Wall -Werror`. All 33 parser and 12 model checks passed again. Command checks verified a valid report, an invalid duplicate-entity report with exit code 1, and refusal of an input/report path alias.

The primary report was generated at `output/reporte_validacion.txt` with status `VALID`, zero errors, and zero warnings. This report is committed to the repository as evidence and can be recreated with the command above.

The validator itself does not generate output. The Prolog generator honors error severity and deduplicates warning-only relation/rule requests. The complete pipeline manages stale output and generates HTML diagnostics. An `InputFailure` bypasses domain checks because no input model was read, avoiding invented missing-section findings.

## Nonblocking coverage warnings

`CourseWithoutTeacherWarning`, `CourseWithoutStudents`, `PersonWithoutCourses`,
`TeacherWithoutCourses`, and `CaseSimilarEntity` identify incomplete relationships
or declarations differing only in case. Their location is the entity declaration;
case warnings also link the earlier declaration. Names remain case-sensitive.
Spanish messages appear in both the report and HTML. Revalidation is idempotent.
