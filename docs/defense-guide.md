# Oral defense guide

## Demonstration sequence

1. Show `input/problema.txt` and explain its three section markers and English academic vocabulary.
2. Run `runghc -Wall -Werror -isrc app/Main.hs` and open `output/index.html`.
3. Show entity and relation tables, source-line comments, generated rules, suggested queries, and the validation report.
4. Load `swipl -q -s output/consultas.pl` and query `classmate(First, Second).` and `course_with_teacher(Course).` Use `;` to request further solutions and `halt.` to exit.
5. Run `runghc -Wall -Werror -isrc app/Main.hs test/fixtures/alternate-valid.txt output/alternate`. Show changed names and courses without editing any generated file.
6. Run the duplicate-entity fixture into a separate directory. Explain exit code 1, related source lines, blocked Prolog, and the current error UI.
7. Show `docs/html/index.html`, the test evidence, and the requirement checklist.

For the primary example, classmates are Alice/Bob and Bob/Alice; the course with a teacher is ProgrammingParadigms. For the alternate example, Casey/Jordan are classmates and Logic has a teacher; Algebra does not. Input names are case-sensitive Prolog atoms such as `'Alice'`.

## Design questions to prepare together

- **Why an intermediate model?** It separates input syntax from academic meaning and output syntax. Prolog, reports, and HTML share a typed representation rather than independently interpreting strings.
- **Where is functional programming used?** Pure folds, pattern matching, immutable structures, typed alternatives, and `Either` transform text to model and model to output. IO is explicit at file and process boundaries.
- **What differs between parsing and validation?** The parser checks record shape and sections; validation checks global constraints after all declarations exist. This permits forward references and reordered sections.
- **Why keep original lines?** Physical numbering before filtering blanks supports accurate errors and fact provenance. Duplicate errors identify both declarations.
- **How do errors affect generation?** Any error blocks executable knowledge. Warnings permit generation, while duplicate relation/rule output is reduced to its first occurrence. Missing files and invalid UTF-8 produce file-level errors.
- **Why quote Prolog names?** Unquoted uppercase names are variables. Quoted atoms preserve exact case and identity, with escaping for special characters.
- **How are logical rules defined?** Classmates are distinct declared people with a shared enrollment course. `dif/2` excludes self-pairs; `once/1` avoids repeated proofs for a fixed pair. Courses with a teacher enumerate each course once even with several teachers.
- **Does the browser run Prolog?** No. It visualizes the generated model/knowledge. SWI-Prolog executes the rules and queries.
- **Why Doxygen extraction?** Doxygen has no native Haskell parser. A tracked tool extracts real source declarations into Doxygen pages, which are regenerated with the technical Markdown documentation.
- **What are the limits?** The academic grammar uses case-sensitive ASCII identifiers and no comments or quoted input names. One writer should use each output directory. Per-file rename is atomic, but a whole multi-file run is not a disk transaction.

## Pair preparation

Both partners should be able to trace one record through `Parser`, `Model`, `Validation`, `Prolog`, and `Html`, then run the complete command independently. Review the agreed vocabulary before the professor provides a second file. Decide who introduces each part, but avoid preparing only the code one partner wrote.
