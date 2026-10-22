module Parser (parseProblem) where

import Data.Char (isAsciiLower, isAsciiUpper, isSpace)
import Data.List (dropWhileEnd)
import qualified Data.List as List
import Diagnostic
import Model
import Source

-- | Parse physical lines without resolving references or validating the domain.
parseProblem :: String -> Problem
parseProblem input = restoreOrder problem
  where
    (_, problem) = List.foldl' parseLine (Nothing, emptyProblem)
      (zipWith SourceLine [1..] (map stripCarriageReturn (lines input)))

restoreOrder :: Problem -> Problem
restoreOrder problem = problem
  { problemSections = reverse (problemSections problem)
  , problemEntities = reverse (problemEntities problem)
  , problemRelations = reverse (problemRelations problem)
  , problemRules = reverse (problemRules problem)
  , problemDiagnostics = reverse (problemDiagnostics problem)
  }

parseLine :: (Maybe Section, Problem) -> SourceLine -> (Maybe Section, Problem)
parseLine (current, problem) origin
  | null text = (current, problem)
  | Just section <- lookup text sectionMarkers =
      (Just section, problem { problemSections = Located origin section : problemSections problem })
  | '[' `elem` text || ']' `elem` text =
      (Nothing, addDiagnostic origin UnknownSection "Unknown or malformed section header." problem)
  | otherwise = (current, case current of
      Nothing -> addDiagnostic origin RecordOutsideSection "Record outside a recognized section." problem
      Just EntitiesSection -> storeRecord origin parseEntity
        (\record value -> value { problemEntities = record : problemEntities value }) text problem
      Just RelationsSection -> storeRecord origin parseRelation
        (\record value -> value { problemRelations = record : problemRelations value }) text problem
      Just RulesSection -> storeRecord origin parseRule
        (\record value -> value { problemRules = record : problemRules value }) text problem)
  where
    text = trim (if sourceLineNumber origin == 1 then stripBom (sourceLineText origin)
                 else sourceLineText origin)

sectionMarkers :: [(String, Section)]
sectionMarkers =
  [ ("[ENTIDADES]", EntitiesSection)
  , ("[RELACIONES]", RelationsSection)
  , ("[REGLAS_SOLICITADAS]", RulesSection)
  ]

storeRecord :: SourceLine -> (String -> Either (DiagnosticCode, String) a)
  -> (Located a -> Problem -> Problem) -> String -> Problem -> Problem
storeRecord origin parse store text problem = case parse text of
  Left (code, message) -> addDiagnostic origin code message problem
  Right value -> store (Located origin value) problem

addDiagnostic :: SourceLine -> DiagnosticCode -> String -> Problem -> Problem
addDiagnostic origin code message problem = problem
  { problemDiagnostics = Diagnostic Error code message (LineLocation origin) []
      : problemDiagnostics problem
  }

parseEntity :: String -> Either (DiagnosticCode, String) Entity
parseEntity text = case fields ':' text of
  [kind, name] | identifier kind && identifier name ->
    case kind of
      "person" -> Right (Person (EntityName name))
      "course" -> Right (Course (EntityName name))
      "teacher" -> Right (Teacher (EntityName name))
      _ -> Left (UnknownVocabulary, "Unknown entity type: " ++ kind)
  _ -> Left (MalformedRecord, "Expected an entity record: type: Name.")

parseRelation :: String -> Either (DiagnosticCode, String) Relation
parseRelation text = case fields ':' text of
  [kind, arguments] | identifier kind -> case fields ',' arguments of
    [source, target] | identifier source && identifier target ->
      case kind of
        "enrolled" -> Right (Enrolled (EntityName source) (EntityName target))
        "teaches" -> Right (Teaches (EntityName source) (EntityName target))
        _ -> Left (UnknownVocabulary, "Unknown relation type: " ++ kind)
    _ -> malformed
  _ -> malformed
  where
    malformed = Left (MalformedRecord, "Expected a relation record: relation: Source, Target.")

parseRule :: String -> Either (DiagnosticCode, String) RequestedRule
parseRule text
  | not (identifier text) = Left (MalformedRecord, "Expected a single rule identifier.")
  | text == "classmates" = Right Classmates
  | text == "course_with_teacher" = Right CourseWithTeacher
  | otherwise = Right (UnknownRule text)

identifier :: String -> Bool
identifier [] = False
identifier (first : rest) = asciiLetter first && all continuation rest
  where
    asciiLetter char = isAsciiLower char || isAsciiUpper char
    continuation char = asciiLetter char || (char >= '0' && char <= '9') || char == '_'

fields :: Char -> String -> [String]
fields delimiter text = case break (== delimiter) text of
  (field, []) -> [trim field]
  (field, _ : remaining) -> trim field : fields delimiter remaining

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

stripBom :: String -> String
stripBom ('\xfeff' : rest) = rest
stripBom text = text

stripCarriageReturn :: String -> String
stripCarriageReturn = dropWhileEnd (== '\r')
