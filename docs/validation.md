# Semantic validation and reports

## API

`Validation.validateProblem :: Problem -> Problem` is pure. It retains all records and their source metadata, preserves parser diagnostics, and adds semantic diagnostics. Revalidating the same unchanged model does not duplicate diagnostics. If the input changes, parse it again before validation rather than editing a previously validated model with stale findings.

The validator checks required and repeated sections, globally duplicate entity names, undeclared references, relation argument kinds, unsupported requested rules, and repeated relations and rules. Names remain case-sensitive. References are resolved against all declarations, allowing section reordering and forward references.

Duplicate entities are errors even across different types. Every repeat points to the first declaration. References to ambiguous duplicate names do not receive additional type-mismatch diagnostics: the duplicate error already prevents generation. Repeated relations and requested rules are warnings. The validator preserves them so future generators can keep the first occurrence with its source information.

Malformed lines and unknown vocabulary remain the parser's responsibility. Missing sections use file-level diagnostics, not artificial source lines. Existing syntax errors do not stop independent semantic checks.

## Reports and command

`ValidationReport.renderValidationReport :: Problem -> String` renders a validated model as an English report with status, error/warning counts, diagnostic codes, source lines, and related declaration locations. Call it after validation; rendering alone does not discover errors.

`writeValidationReport :: FilePath -> Problem -> IO ()` writes UTF-8 to the supplied file in an existing directory. Reports are deterministic: parser diagnostics are followed by missing sections, repeated sections, duplicate entities, reference errors, unsupported rules, repeated relations, and repeated rules. Findings within a category retain record order.

Run `runghc -Wall -Werror -isrc app/Validate.hs` from the repository root. The default output is `output/reporte_validacion.txt`. Optional arguments are `INPUT REPORT`. The command returns 0 for valid input or warnings, and 1 for errors, bad arguments, or IO failures. Validation errors still produce a report; IO failures are printed to standard error. Canonical input/report paths are compared before writing to prevent ordinary aliases from overwriting the input.

The domain modules use `base`; the command also uses GHC's bundled `directory` and `filepath` libraries for path checking. No third-party packages or installation are required.

## Verification

On October 22, 2026, the compiled validation suite passed all 29 checks with `-Wall -Werror`. All 33 parser and 12 model checks passed again. Command checks verified a valid report, an invalid duplicate-entity report with exit code 1, and refusal of an input/report path alias.

The primary report was generated at `output/reporte_validacion.txt` with status `VALID`, zero errors, and zero warnings. Generated reports are ignored by Git and can be recreated with the command above.

This stage does not generate Prolog, queries, or HTML. Stage 6 must honor error severity before generating executable knowledge and deduplicate warning-only relation/rule requests. Safe management of stale output belongs to stage 8 integration.
