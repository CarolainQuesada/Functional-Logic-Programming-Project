# Functional input parser

## API and scope

`Parser.parseProblem :: String -> Problem` is pure. It recognizes sections, parses academic records, and accumulates syntax diagnostics without stopping at the first bad record. It does not resolve references, reject duplicate declarations, require all sections, or validate requested rules against the domain.

`Input.readProblem :: FilePath -> IO Problem` reads UTF-8 and delegates to the pure parser. It forces decoding before the file handle closes. Missing files, permission problems, and decoding errors remain IO exceptions for the application layer to handle later; they are not disguised as malformed input records.

## Parsing process

Physical lines receive one-based numbers before blank lines are ignored. CRLF terminators and a leading BOM are accepted. The original line text is retained, excluding line terminators; a BOM is ignored only for recognition on the first physical line.

The parser folds over lines with a current section and accumulated problem. Records are prepended and reversed once at the end to preserve input order without repeated list appends. An unknown or malformed header resets the current section. Later valid headers allow parsing to resume.

Known entity and relation types produce typed constructors. Unknown types produce `UnknownVocabulary` diagnostics, and malformed fields produce `MalformedRecord`. A well-formed unknown rule becomes `UnknownRule` for stage 5 domain validation. Repeated headers, declarations, relations, and rules remain in the model so later validation has the evidence it needs.

## Verification

On October 22, 2026, `test/ParserTest.hs` compiled with `ghc -Wall -Werror -isrc` and all 33 checks passed. The 12 model checks also passed again.

Coverage includes both valid files, all existing invalid fixtures, retained partial models, source locations, unknown vocabulary, empty input and sections, changed section order, forward references, unknown-header recovery, case sensitivity, BOM/CRLF, whitespace, invalid identifiers, malformed fields, and duplicate retention.

Run from the repository root:

```powershell
runghc -Wall -Werror -isrc test/ParserTest.hs
```

No Prolog files, HTML, or validation report are generated in this stage. See the input specification for the semantics to implement next.
