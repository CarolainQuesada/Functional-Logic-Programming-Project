Ã¯Â»Â¿# Input format specification

## Scope and evidence

Stage 2 defines the academic input contract. The official assignment supplied in chat permits adapting the domain and demonstrates `type: name`, `relation: source, target`, and bare requested-rule names. It requires the three section markers below, validation, source-line traceability, and automatic regeneration of all outputs.

The academic domain is explicitly listed in the assignment. English record vocabulary is a project choice; the assignment does not require that language. The Spanish vocabulary in the assignment is also accepted: `persona`, `curso`, `docente`, `lleva`, `imparte`, `companeros`, and `curso_con_docente`. Both vocabularies may be mixed and normalize to the same typed model and canonical English Prolog predicates. Original source text is preserved.

The conventions below fill gaps in the assignment; they are project decisions, not additional requirements attributed to the professor. They are implemented by the parser, validator, generators, and complete pipeline.

## Required sections

| Exact marker | Record form |
| --- | --- |
| `[ENTIDADES]` | `type: name` |
| `[RELACIONES]` | `relation: source, target` |
| `[REGLAS_SOLICITADAS]` | `rule_name` |

Preserve these markers and the required filenames `problema.txt`, `conocimiento.pl`, `consultas.pl`, `index.html`, and `reporte_validacion.txt`. Source code and generated predicates use English; input also accepts the documented Spanish aliases.

Each section must occur exactly once. Sections may appear in any order and may be empty. Blank lines are ignored for parsing but count toward source line numbers. Nonblank content before a section, unknown headers, and repeated headers are errors. An unknown header ends the previous section context so following records cannot silently enter the wrong section.

## Lexical conventions

- Read UTF-8, accepting an optional BOM at the start of the file and both LF and CRLF line endings.
- Trim surrounding whitespace on headers, records, field names, and values. Preserve the original text separately.
- Match section markers, types, relations, rules, and entity names case-sensitively.
- Entity names accept Unicode letters, digits, underscores and internal spaces. Type and rule identifiers use `[A-Za-z][A-Za-z0-9_]*`. Lines starting with # or % are comments; source line numbers remain physical.
- Entity records contain exactly one colon and one nonempty name. Relation records contain exactly one colon and exactly two nonempty comma-separated arguments. Rule records contain one supported rule identifier without a colon or arguments.
- Preserve entity name case in the model. Prolog generation encodes names as quoted atoms and escapes them where needed, rather than lowercasing distinct names into the same atom.

## Academic vocabulary

| Record | Meaning |
| --- | --- |
| `person: Name` | A person who may enroll in a course |
| `course: Name` | A course |
| `teacher: Name` | A teacher |
| `enrolled: Person, Course` | A person is enrolled in a course |
| `teaches: Teacher, Course` | A teacher teaches a course |
| `classmates` | Request `companero/2`: distinct people enrolled in a shared course |
| `course_with_teacher` | Request `curso_con_docente/1`: courses taught by at least one teacher |

Entity names are globally unique across all types. References are resolved after collecting all entity declarations, so forward references and section reordering are supported. Relation arguments must reference the appropriate declared types. Never embed sample names in implementation logic.

An exact repeated relation or rule request is a warning; keep the first occurrence for generation. Repeated entity names are errors, including declarations using different types. Unused entities and empty sections are allowed without warnings.

## Section recognition and traceability

1. Enumerate physical lines from 1 before filtering blanks or classifying records.
2. Keep the source line number and original text with each parsed record and diagnostic.
3. Compare the trimmed line with complete section markers and update the current section.
4. Parse each remaining nonblank line according to its section.
5. Collect diagnostics and continue with later lines; do not silently drop malformed data.
6. Resolve references and semantic constraints against the complete model in the validation stage.

A record after a blank line retains its physical source line. Missing-section diagnostics are file-level and must not invent a line number. Duplicate-entity diagnostics identify both the first and repeated declaration. Preserve source information for later Prolog comments and validation reports.

The professor's illustrative Prolog comment line numbers differ from the physical positions in the pasted input. The original input's physical lines are the source of truth.

## Error and warning policy

Errors include malformed records, unknown vocabulary or headers, missing/repeated sections, records outside a section, duplicate entity names, undeclared references, and relation argument type mismatches. Unsupported rules are errors even when syntactically well formed.

Collect independent errors where possible. A malformed record must not produce cascading semantic errors based on invented values. The validation report and generated UI show diagnostics. With errors, the complete pipeline replaces executable knowledge and suggested queries with blocked markers so stale successful results are not presented as current. Warnings alone permit generation.

## Examples and review status

`input/problema.txt` is the primary valid academic example. `test/fixtures/alternate-valid.txt` uses different names to support the defense requirement. Other fixtures isolate required invalid cases; `test/fixtures/README.md` records expected source locations and outcomes.

The fixtures are exercised by parser, validation, generation, and integration tests. Coverage includes BOM/CRLF, whitespace, section order, repeated and unknown headers, empty sections, case sensitivity, argument types, duplicate warnings, and stale-output invalidation. Primary, alternate, and invalid generated pages were also loaded in Chrome at desktop and mobile sizes.

See [verification evidence](verification.md) for executed results and [pipeline behavior](pipeline.md) for the complete command.

## Assignment compatibility

`test/fixtures/assignment-valid.txt` reproduces the assignment example. The generated predicates remain `persona/1`, `curso/1`, `docente/1`, `lleva/2`, `imparte/2`, `companero/2`, and `curso_con_docente/1`; input aliases do not create additional predicates. Names retain their case and accept Unicode letters, digits, underscores and internal spaces.
