# Prolog knowledge and queries

## API and output

`Prolog.generateProlog :: Problem -> Either [Diagnostic] PrologOutput` validates the supplied model again before generating output. Errors return diagnostics; warnings permit generation. The output contains pure `knowledgeText` and `queriesText` values. `PrologFiles.writePrologFiles` writes those strings as UTF-8 in an existing directory.

Entities become `person/1`, `course/1`, and `teacher/1` facts. Relations become `enrolled/2` and `teaches/2`. Names are quoted atoms with escaped quotes, backslashes, and common control characters; their case is preserved. Facts are grouped by predicate, retaining input order within each group. Every fact has a source-line comment containing its physical input line and original record. Requested rules also retain their request source line.

The five base predicates are declared dynamic so empty entity/relation categories remain defined and queries fail normally when no facts exist. Fact grouping avoids discontiguous-clause warnings. This follows SWI-Prolog's [predicate declaration syntax](https://www.swi-prolog.org/pldoc/man?section=declare); atom escaping follows its [source syntax](https://ww1.swi-prolog.org/pldoc/man?section=syntax).

## Requested rules

- `classmates` generates `classmate/2`. It enumerates distinct declared people who share a course, with each ordered pair returned once even when multiple courses are shared. Both directions are valid; self-pairs are excluded.
- `course_with_teacher` generates `course_with_teacher/1`. It returns each declared course with a teacher once even when multiple teachers teach it.

Unrequested rules are absent. Exact repeated relations and rule requests keep the first occurrence and its provenance; the validation report retains duplicate warnings.

## Suggested queries

`consultas.pl` loads its sibling `conocimiento.pl` with `ensure_loaded/1` and contains `suggested_query/1` facts for the five base predicates plus requested rules. Merely loading the file does not run every query. Example interactive use:

```prolog
?- suggested_query(Query), call(Query).
?- classmate(First, Second).
?- course_with_teacher(Course).
```

The latter two queries require the corresponding requested rule. Input names are atoms such as `'Alice'`, not unquoted uppercase variables.

## Generation command

```powershell
runghc -Wall -Werror -isrc app/GenerateProlog.hs
swipl -q -s output/consultas.pl
```

Default input is `input/problema.txt`; default output directory is `output`. Optional arguments are `INPUT OUTPUT_DIRECTORY`, supplied together. The directory must exist. The command compares canonical input/output paths before writing, writes the validation report, then writes Prolog only when validation permits it. Exit code 0 indicates success; validation and IO errors return 1.

Invalid input does not update Prolog files. Previous files can therefore be stale; the command reports this explicitly. Output writes are sequential rather than transactional, and an IO error can leave partial output. Stale-output handling and complete publication coordination remain stage 8 work. This stage does not create HTML, invoke SWI-Prolog automatically during generation, or delete files.

## Executed verification

On October 22, 2026, all 16 generator checks and 13 SWI-Prolog checks passed after compilation with `-Wall -Werror`. The existing 74 Haskell checks also passed. Tests loaded knowledge and suggested queries for the primary input, alternate input, empty data, absent rules, repeated relations/rules, multiple shared courses/teachers, and case-sensitive names. A quoted-atom round trip was also checked in SWI-Prolog.

The generation command produced the primary knowledge, queries, and report. A separate invalid-input command returned 1, wrote its report, and produced neither Prolog file in a fresh output directory. Generated files and test scenarios are ignored by Git and can be regenerated using the documented commands.
