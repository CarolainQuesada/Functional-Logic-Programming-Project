module Main (main) where

import Control.Monad (forM_, unless)
import Data.List (isInfixOf)
import Diagnostic
import Input (readProblem)
import Model
import Parser (parseProblem)
import Source
import System.Exit (exitFailure)
import Validation (validateProblem)
import ValidationReport (renderValidationReport)

main :: IO ()
main = do
  primary <- validateProblem <$> readProblem "input/problema.txt"
  alternate <- validateProblem <$> readProblem "test/fixtures/alternate-valid.txt"
  duplicate <- validateProblem <$> readProblem "test/fixtures/duplicate-entity.txt"
  undeclared <- validateProblem <$> readProblem "test/fixtures/undeclared-reference.txt"
  malformed <- validateProblem <$> readProblem "test/fixtures/malformed-records.txt"
  missing <- validateProblem <$> readProblem "test/fixtures/missing-section.txt"
  unsupported <- validateProblem <$> readProblem "test/fixtures/unsupported-rule.txt"
  let checks =
        [ ("Primary input is valid", null (diagnostics primary))
        , ("Alternate input is valid", null (diagnostics alternate))
        , ("Duplicate fixture identifies original and repeated lines", codes duplicate == [DuplicateEntity]
            && locations duplicate == [LineLocation (SourceLine 3 "person: Alice")]
            && map diagnosticRelatedLines (diagnostics duplicate) == [[SourceLine 2 "person: Alice"]])
        , ("Undeclared fixture identifies relation source", codes undeclared == [UndeclaredReference]
            && locations undeclared == [LineLocation (SourceLine 6 "enrolled: Taylor, Logic")])
        , ("All malformed parser diagnostics survive validation", codes malformed == replicate 3 MalformedRecord)
        , ("Missing section has a file-level location", codes missing == [MissingSection] && locations missing == [FileLocation])
        , ("Unknown rule is a domain error", codes unsupported == [UnsupportedRule])
        , ("Empty file reports all required sections", codes (validated "") == replicate 3 MissingSection)
        , ("Empty sections are valid", null (diagnostics (academic "" "" "")))
        , ("Cross-type duplicate names are errors", codes (academic "person: Alice\nteacher: Alice" "" "") == [DuplicateEntity])
        , ("Case-sensitive names are distinct", null (diagnostics (academic "person: Alice\nperson: alice" "" "")))
        , ("Every repeated declaration references the first", map diagnosticRelatedLines (diagnostics tripleDuplicate)
            == replicate 2 [SourceLine 2 "person: Alice"])
        , ("Repeated sections are errors", codes repeatedSection == [RepeatedSection])
        , ("Both absent relation arguments are diagnosed", codes (academic "" "enrolled: Alice, Logic" "")
            == replicate 2 UndeclaredReference)
        , ("Both wrong argument kinds are diagnosed", codes wrongKinds == replicate 2 ArgumentTypeMismatch)
        , ("Type mismatch points to the declaration", map diagnosticRelatedLines (diagnostics wrongKinds)
            == [[SourceLine 2 "course: Alice"],[SourceLine 3 "teacher: Logic"]])
        , ("Teaching requires teacher and course roles", codes (academic "person: Alice\ncourse: Logic" "teaches: Alice, Logic" "")
            == [ArgumentTypeMismatch])
        , ("Forward references and reordered sections are valid", null (diagnostics forward))
        , ("Ambiguous names do not produce cascading type errors", codes ambiguous == [DuplicateEntity])
        , ("Malformed declarations are not invented", codes (academic "person Alice" "enrolled: Alice, Logic" "")
            == [MalformedRecord,UndeclaredReference,UndeclaredReference])
        , ("Repeated relations and rules are warnings", codes warnings == [DuplicateRelation,DuplicateRule]
            && all ((== Warning) . diagnosticSeverity) (diagnostics warnings) && not (hasErrors (diagnostics warnings)))
        , ("Validation preserves duplicate records", length (problemRelations warnings) == 2 && length (problemRules warnings) == 2)
        , ("Mixed syntax and domain errors accumulate", codes mixed == [MalformedRecord,UndeclaredReference,UnsupportedRule])
        , ("Revalidation does not duplicate diagnostics", validateProblem mixed == mixed && validateProblem duplicate == duplicate)
        , ("Success report has counts", all (`isInfixOf` renderValidationReport primary)
            ["Status: VALID","Errors: 0","Warnings: 0","No errors or warnings."])
        , ("Error report retains original and related source", all (`isInfixOf` renderValidationReport duplicate)
            ["Status: INVALID","Errors: 1","Location: line 3","Source: person: Alice","Related line 2: person: Alice"])
        , ("File diagnostic does not invent line zero", "Location: file" `isInfixOf` renderValidationReport missing
            && not ("line 0" `isInfixOf` renderValidationReport missing))
        , ("Warnings report remains valid", all (`isInfixOf` renderValidationReport warnings)
            ["Status: VALID WITH WARNINGS","Errors: 0","Warnings: 2"])
        , ("All model records and metadata survive", let parsed = parseProblem sample in
            (validateProblem parsed) { problemDiagnostics = [] } == parsed { problemDiagnostics = [] })
        ]
  forM_ checks $ \(label, condition) -> unless condition $ do
    putStrLn ("FAIL: " ++ label)
    exitFailure
  putStrLn ("All " ++ show (length checks) ++ " validation checks passed.")
  where
    diagnostics = problemDiagnostics
    codes = map diagnosticCode . diagnostics
    locations = map diagnosticLocation . diagnostics
    validated = validateProblem . parseProblem
    academic entities relations rules = validated (unlines
      ["[ENTIDADES]", entities, "[RELACIONES]", relations, "[REGLAS_SOLICITADAS]", rules])
    tripleDuplicate = academic "person: Alice\nperson: Alice\nperson: Alice" "" ""
    repeatedSection = academic "person: Alice\n[ENTIDADES]\ncourse: Logic" "" ""
    wrongKinds = academic "course: Alice\nteacher: Logic" "enrolled: Alice, Logic" ""
    forward = validated "[RELACIONES]\nenrolled: Alice, Logic\n[REGLAS_SOLICITADAS]\nclassmates\n[ENTIDADES]\nperson: Alice\ncourse: Logic"
    ambiguous = academic "person: Alice\nteacher: Alice\ncourse: Logic" "teaches: Alice, Logic" ""
    warnings = academic "person: Alice\ncourse: Logic" "enrolled: Alice, Logic\nenrolled: Alice, Logic" "classmates\nclassmates"
    mixed = academic "person: Alice\ncourse: Logic\nperson Bob" "enrolled: Bob, Logic" "grandparents"
    sample = "[ENTIDADES]\nperson: Alice\nperson: Alice\n[RELACIONES]\n[REGLAS_SOLICITADAS]\nclassmates"
