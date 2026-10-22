module Main (main) where

import Control.Monad (forM_, unless)
import Diagnostic
import Input (readProblem)
import Model
import Parser (parseProblem)
import Source
import System.Exit (exitFailure)

main :: IO ()
main = do
  primary <- readProblem "input/problema.txt"
  alternate <- readProblem "test/fixtures/alternate-valid.txt"
  malformed <- readProblem "test/fixtures/malformed-records.txt"
  duplicate <- readProblem "test/fixtures/duplicate-entity.txt"
  undeclared <- readProblem "test/fixtures/undeclared-reference.txt"
  missing <- readProblem "test/fixtures/missing-section.txt"
  unsupported <- readProblem "test/fixtures/unsupported-rule.txt"
  let checks =
        [ ("Primary input counts and section order", counts primary == (3, 4, 3, 2)
            && null (problemDiagnostics primary)
            && values (problemSections primary) == [EntitiesSection, RelationsSection, RulesSection])
        , ("Primary entity values", values (problemEntities primary) ==
            [Person (name "Alice"), Person (name "Bob"), Course (name "ProgrammingParadigms"), Teacher (name "Morgan")])
        , ("Primary relation values", values (problemRelations primary) ==
            [Enrolled (name "Alice") (name "ProgrammingParadigms"), Enrolled (name "Bob") (name "ProgrammingParadigms"),
             Teaches (name "Morgan") (name "ProgrammingParadigms")])
        , ("Physical source lines include blanks", map (sourceLineNumber . sourceLine) (problemRelations primary) == [8,9,10])
        , ("Second input uses independent names", counts alternate == (3,5,4,2)
            && null (problemDiagnostics alternate)
            && map (entityName . locatedValue) (problemEntities alternate) == map name ["Casey","Jordan","Logic","Algebra","Riley"])
        , ("Malformed records accumulate diagnostics in source order", diagnosticLines malformed == [2,7,10]
            && map diagnosticCode (problemDiagnostics malformed) == replicate 3 MalformedRecord)
        , ("Valid records survive malformed lines", values (problemEntities malformed) == [Person (name "Bob"),Course (name "Logic")])
        , ("Duplicate declarations remain for stage 5", length (problemEntities duplicate) == 3 && null (problemDiagnostics duplicate))
        , ("Undeclared references remain for stage 5", values (problemRelations undeclared) == [Enrolled (name "Taylor") (name "Logic")]
            && null (problemDiagnostics undeclared))
        , ("Absent sections remain for stage 5", counts missing == (2,2,1,0) && null (problemDiagnostics missing))
        , ("Unknown rule retains source for stage 5", problemRules unsupported ==
            [Located (SourceLine 9 "grandparents") (UnknownRule "grandparents")] && null (problemDiagnostics unsupported))
        , ("Empty input produces an empty model", parseProblem "" == emptyProblem)
        , ("Blank lines do not create records", parseProblem "\n \t\n" == emptyProblem)
        , ("BOM and CRLF are accepted", values (problemEntities bomInput) == [Person (name "Alice")]
            && null (problemDiagnostics bomInput))
        , ("Source text retains whitespace", problemEntities whitespaceInput ==
            [Located (SourceLine 3 "  person : Alice  ") (Person (name "Alice"))])
        , ("Case-sensitive names remain distinct", values (problemEntities (entities "person: Alice\nperson: alice")) ==
            [Person (name "Alice"),Person (name "alice")])
        , ("Unknown entity type is a vocabulary error", codes (entities "student: Alice") == [UnknownVocabulary])
        , ("Unknown relation type is a vocabulary error", codes (relations "knows: Alice, Bob") == [UnknownVocabulary])
        , ("Case-sensitive vocabulary", codes (entities "Person: Alice") == [UnknownVocabulary])
        , ("Section order and forward references are preserved", counts reordered == (3,2,1,1) && null (problemDiagnostics reordered))
        , ("Repeated headers are retained for stage 5", values (problemSections repeated) == [EntitiesSection,EntitiesSection]
            && length (problemEntities repeated) == 2)
        , ("Unknown header resets section context", codes unknown == [UnknownSection,RecordOutsideSection]
            && values (problemEntities unknown) == [Person (name "Alice"),Person (name "Casey")])
        , ("Content before a header is diagnosed", codes (parseProblem "person: Alice") == [RecordOutsideSection])
        , ("Headers must match exactly", codes (parseProblem "[entidades]\nperson: Alice") == [UnknownSection,RecordOutsideSection])
        , ("BOM is ignored only on the first physical line", codes (parseProblem "\n\xfeff[ENTIDADES]") == [UnknownSection])
        , ("Empty required sections are representable", counts emptySections == (3,0,0,0) && null (problemDiagnostics emptySections))
        , ("Repeated rules and relations retain their order", values (problemRules repeatedRecords) == [Classmates,Classmates]
            && length (problemRelations repeatedRecords) == 2 && null (problemDiagnostics repeatedRecords))
        , ("All malformed entity shapes are rejected", all ((== [MalformedRecord]) . codes . entities)
            ["person:","person: Alice: Bob","person: Alice, Bob","person: First Last","person: 1Alice","person: \193na","person: _Alice","person: Alice # comment"])
        , ("All malformed relation shapes are rejected", all ((== [MalformedRecord]) . codes . relations)
            ["enrolled: Alice","enrolled: Alice,","enrolled: ,Logic","enrolled: Alice, Logic, Bob","enrolled:: Alice, Logic"])
        , ("Malformed rule shapes are rejected", all ((== [MalformedRecord]) . codes . rules)
            ["classmates: Alice","classmates()","two rules","_rule"])
        , ("Wrong argument kinds remain for stage 5", null (problemDiagnostics (relations "enrolled: Logic, Morgan")))
        , ("Identifier digits and underscores are accepted", values (problemEntities (entities "person: Alice_2")) == [Person (name "Alice_2")])
        , ("Diagnostics include original source and severity", problemDiagnostics (entities " person Alice ") ==
            [Diagnostic Error MalformedRecord "Expected an entity record: type: Name."
              (LineLocation (SourceLine 2 " person Alice ")) []])
        ]
  forM_ checks $ \(label, condition) -> unless condition $ do
    putStrLn ("FAIL: " ++ label)
    exitFailure
  putStrLn ("All " ++ show (length checks) ++ " parser checks passed.")
  where
    name = EntityName
    values = map locatedValue
    entities text = parseProblem ("[ENTIDADES]\n" ++ text)
    relations text = parseProblem ("[RELACIONES]\n" ++ text)
    rules text = parseProblem ("[REGLAS_SOLICITADAS]\n" ++ text)
    codes = map diagnosticCode . problemDiagnostics
    diagnosticLines problem = [sourceLineNumber origin | diagnostic <- problemDiagnostics problem,
      LineLocation origin <- [diagnosticLocation diagnostic]]
    bomInput = parseProblem "\xfeff[ENTIDADES]\r\nperson: Alice\r\n"
    whitespaceInput = parseProblem " [ENTIDADES] \n\n  person : Alice  \n"
    reordered = parseProblem "[RELACIONES]\nenrolled: Alice, Logic\n[REGLAS_SOLICITADAS]\nclassmates\n[ENTIDADES]\nperson: Alice\ncourse: Logic"
    repeated = entities "person: Alice\n[ENTIDADES]\nperson: Bob"
    unknown = entities "person: Alice\n[OTHER]\nperson: Bob\n[ENTIDADES]\nperson: Casey"
    emptySections = parseProblem "[ENTIDADES]\n[RELACIONES]\n[REGLAS_SOLICITADAS]"
    repeatedRecords = parseProblem "[RELACIONES]\nenrolled: Alice, Logic\nenrolled: Alice, Logic\n[REGLAS_SOLICITADAS]\nclassmates\nclassmates"

counts :: Problem -> (Int, Int, Int, Int)
counts problem = (length (problemSections problem), length (problemEntities problem),
  length (problemRelations problem), length (problemRules problem))
