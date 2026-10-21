# Input format specification

## Scope and evidence

Stage 2 defines the academic input contract. The official assignment supplied in chat permits adapting the domain and demonstrates `type: name`, `relation: source, target`, and bare requested-rule names. It requires the three section markers below, validation, source-line traceability, and automatic regeneration of all outputs.

The academic domain is explicitly listed in the assignment. English record vocabulary is a project choice, consistent with the requirement to write code in English. The Spanish vocabulary in the professor's example is illustrative, not a second supported dialect. If a defense input uses a different vocabulary, its compatibility must be agreed before the defense.

The conventions below fill gaps in the assignment; they are project decisions, not additional requirements attributed to the professor. No parser or model is implemented in this stage.

## Required sections

| Exact marker | Record form |
| --- | --- |
| `[ENTIDADES]` | `type: name` |
| `[RELACIONES]` | `relation: source, target` |
| `[REGLAS_SOLICITADAS]` | `rule_name` |

Preserve these markers and the required filenames `problema.txt`, `conocimiento.pl`, `consultas.pl`, `index.html`, and `reporte_validacion.txt`. All other project vocabulary is English.

Each section must occur exactly once. Sections may appear in any order and may be empty. Blank lines are ignored for parsing but count toward source line numbers. Nonblank content before a section, unknown headers, and repeated headers are errors. An unknown header ends the previous section context so following records cannot silently enter the wrong section.

## Lexical conventions

- Read UTF-8, accepting an optional BOM at the start of the file and both LF and CRLF line endings.
- Trim surrounding whitespace on headers, records, field names, and values. Preserve the original text separately.
- Match section markers, types, relations, rules, and entity names case-sensitively.
- Names use ASCII identifiers: `[A-Za-z][A-Za-z0-9_]*`. There are no quoted names, embedded spaces, accents, delimiters inside names, or comment syntax in the initial format.
- Entity records contain exactly one colon and one nonempty name. Relation records contain exactly one colon and exactly two nonempty comma-separated arguments. Rule records contain one supported rule identifier without a colon or arguments.
- Preserve entity name case in the model. Later Prolog generation must encode names as quoted atoms and escape them where needed, rather than lowercasing distinct names into the same atom.

## Academic vocabulary

| Record | Meaning |
| --- | --- |
| `person: Name` | A person who may enroll in a course |
| `course: Name` | A course |
| `teacher: Name` | A teacher |
| `enrolled: Person, Course` | A person is enrolled in a course |
| `teaches: Teacher, Course` | A teacher teaches a course |
| `classmates` | Request `classmate/2`: distinct people enrolled in a shared course |
| `course_with_teacher` | Request `course_with_teacher/1`: courses taught by at least one teacher |

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

Collect independent errors where possible. A malformed record must not produce cascading semantic errors based on invented values. The validation report and generated UI should show diagnostics. With errors, do not publish executable knowledge or suggested queries; the integration stage must prevent stale successful outputs from appearing current. Warnings alone permit generation. Implement this behavior in the relevant later stages, not in stage 2.

## Examples and review status

`input/problema.txt` is the primary valid academic example. `test/fixtures/alternate-valid.txt` uses different names to support the defense requirement. Other fixtures isolate required invalid cases; `test/fixtures/README.md` records expected source locations and outcomes.

The fixtures have been reviewed as examples of this contract. No automated parser, validation, Prolog generation, or browser test has run because those implementations do not exist yet. Future tests must also cover BOM/CRLF, whitespace, section order, repeated and unknown headers, empty sections, case sensitivity, argument types, and duplicate warnings.

Stage 2 is complete as a specification and fixture preparation task. Stage 3 will introduce the Haskell intermediate model after user approval.
