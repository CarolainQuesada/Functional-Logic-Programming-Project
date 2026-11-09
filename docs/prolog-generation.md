# Prolog knowledge and queries

## API and output

`Prolog.generateProlog :: Problem -> Either [Diagnostic] PrologOutput` validates the supplied model again before generating output. Errors return diagnostics; warnings permit generation. The output contains pure `knowledgeText` and `queriesText` values. `PrologFiles.writePrologFiles` writes those strings as UTF-8 in an existing directory.

Entities become `persona/1`, `curso/1`, and `docente/1` facts. Relations become `lleva/2` and `imparte/2`. Names are quoted atoms with escaped quotes, backslashes, and common control characters; their case is preserved. Facts are grouped by predicate, retaining input order within each group. Every fact has a source-line comment containing its physical input line and original record. Requested rules also retain their request source line.

The five base predicates are declared dynamic so empty entity/relation categories remain defined and queries fail normally when no facts exist. Fact grouping avoids discontiguous-clause warnings. This follows SWI-Prolog's [predicate declaration syntax](https://www.swi-prolog.org/pldoc/man?section=declare); atom escaping follows its [source syntax](https://ww1.swi-prolog.org/pldoc/man?section=syntax).

## Requested rules

- `classmates` generates `companero/2`. It enumerates distinct declared people who share a course, with each ordered pair returned once even when multiple courses are shared. Both directions are valid; self-pairs are excluded.
- `course_with_teacher` generates `curso_con_docente/1`. It returns each declared course with a teacher once even when multiple teachers teach it.

Unrequested rules are absent. Exact repeated relations and rule requests keep the first occurrence and its provenance; the validation report retains duplicate warnings.

## Suggested queries

`consultas.pl` loads its sibling `conocimiento.pl` with `ensure_loaded/1` and contains `suggested_query/1` facts for the five base predicates plus requested rules. Merely loading the file does not run every query. Example interactive use:

```prolog
?- suggested_query(Query), call(Query).
?- companero(First, Second).
?- curso_con_docente(Course).
```

The latter two queries require the corresponding requested rule. Input names are atoms such as `'Alice'`, not unquoted uppercase variables.

## Generation command

Use `runghc -Wall -Werror -isrc app/Main.hs [INPUT OUTPUT_DIRECTORY]` to regenerate all four synchronized artifacts.

Default input is `input/problema.txt`; default output directory is `output`.
The pipeline creates the directory, writes all four synchronized artifacts, and
replaces executable Prolog with blocked markers when validation finds errors.
Warnings preserve generation. SWI-Prolog is invoked by tests, not by the pipeline.

## Additional requested rules

- `companeros_en_curso` / `classmates_in_course`: `companero/3` returns distinct students and their shared course.
- `estudiante_de` / `student_of`: `estudiante_de/2` joins enrollment and teaching through a shared course.
- `curso_sin_docente` / `course_without_teacher`: `curso_sin_docente/1` enumerates declared courses without teaching facts using negation as failure.

`consultas.pl` also contains concrete queries using actual entity names. Named
variables begin with an underscore to avoid singleton warnings when loading query facts.
The two original rule aliases remain supported in both languages.

## Verification

The Prolog suite passes 16 Haskell generation checks and 17 executable SWI-Prolog
checks, including the original 15 plus Unicode knowledge and suggested queries.
