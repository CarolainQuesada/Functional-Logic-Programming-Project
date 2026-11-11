module Parser (parseProblem) where

import Data.Char (isAlphaNum, isAsciiLower, isAsciiUpper, isSpace)
import Data.List (dropWhileEnd)
import qualified Data.List as List
import Diagnostic
import Model
import Source

-- | Parse sectioned text into typed records and syntax diagnostics without IO.
-- Physical source lines survive parsing; semantic checks belong to Validation.
parseProblem :: String -> Problem
parseProblem input = restoreOrder problem
  where
    (_, problem) = List.foldl' parseLine (Nothing, emptyProblem)
      (zipWith SourceLine [1..] (map stripCarriageReturn (lines input)))

-- | Given an accumulated problem, return records and diagnostics in physical input order.
restoreOrder :: Problem -> Problem
restoreOrder problem = problem
  { problemSections = reverse (problemSections problem)
  , problemEntities = reverse (problemEntities problem)
  , problemRelations = reverse (problemRelations problem)
  , problemRules = reverse (problemRules problem)
  , problemDiagnostics = reverse (problemDiagnostics problem)
  }

-- | Given the current section and problem plus a physical source line, return updated parser state.
parseLine :: (Maybe Section, Problem) -> SourceLine -> (Maybe Section, Problem)
parseLine (current, problem) origin
  | null text || take 1 text `elem` ["#", "%"] = (current, problem)
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

-- | Return the supported exact section headers and their model tags.
sectionMarkers :: [(String, Section)]
sectionMarkers =
  [ ("[ENTIDADES]", EntitiesSection)
  , ("[RELACIONES]", RelationsSection)
  , ("[REGLAS_SOLICITADAS]", RulesSection)
  ]

-- | Given origin, parser, insertion function, text and model, return a stored record or syntax diagnostic.
storeRecord :: SourceLine -> (String -> Either (DiagnosticCode, String) a)
  -> (Located a -> Problem -> Problem) -> String -> Problem -> Problem
storeRecord origin parse store text problem = case parse text of
  Left (code, message) -> addDiagnostic origin code message problem
  Right value -> store (Located origin value) problem

-- | Given origin, code, message and model, return the model with a syntax error attached.
addDiagnostic :: SourceLine -> DiagnosticCode -> String -> Problem -> Problem
addDiagnostic origin code message problem = problem
  { problemDiagnostics = Diagnostic Error code message (LineLocation origin) []
      : problemDiagnostics problem
  }

-- | Parse one English or Spanish entity declaration into the shared model.
parseEntity :: String -> Either (DiagnosticCode, String) Entity
parseEntity text = case fields ':' text of
  [kind, name] | identifier kind && entityIdentifier name ->
    case kind of
      "person" -> Right (Person (EntityName name))
      "persona" -> Right (Person (EntityName name))
      "course" -> Right (Course (EntityName name))
      "curso" -> Right (Course (EntityName name))
      "teacher" -> Right (Teacher (EntityName name))
      "docente" -> Right (Teacher (EntityName name))
      _ -> Left (UnknownVocabulary, "Unknown entity type: " ++ kind)
  _ -> Left (MalformedRecord, "Expected an entity record: type: Name.")

-- | Parse two named references; normalize vocabulary without changing names.
parseRelation :: String -> Either (DiagnosticCode, String) Relation
parseRelation text = case fields ':' text of
  [kind, arguments] | identifier kind -> case fields ',' arguments of
    [source, target] | entityIdentifier source && entityIdentifier target ->
      case kind of
        "enrolled" -> Right (Enrolled (EntityName source) (EntityName target))
        "lleva" -> Right (Enrolled (EntityName source) (EntityName target))
        "teaches" -> Right (Teaches (EntityName source) (EntityName target))
        "imparte" -> Right (Teaches (EntityName source) (EntityName target))
        _ -> Left (UnknownVocabulary, "Unknown relation type: " ++ kind)
    _ -> malformed
  _ -> malformed
  where
    malformed = Left (MalformedRecord, "Expected a relation record: relation: Source, Target.")

-- | Normalize supported rule aliases and retain unknown names for validation.
parseRule :: String -> Either (DiagnosticCode, String) RequestedRule
parseRule text
  | not (identifier text) = Left (MalformedRecord, "Expected a single rule identifier.")
  | text == "classmates" = Right Classmates
  | text == "companeros" = Right Classmates
  | text == "course_with_teacher" = Right CourseWithTeacher
  | text == "curso_con_docente" = Right CourseWithTeacher
  | text `elem` ["companeros_en_curso", "classmates_in_course"] = Right ClassmatesInCourse
  | text `elem` ["estudiante_de", "student_of"] = Right StudentOf
  | text `elem` ["curso_sin_docente", "course_without_teacher"] = Right CourseWithoutTeacher
  | otherwise = Right (UnknownRule text)

-- | Given a type or rule token, return whether it follows the ASCII identifier grammar.
identifier :: String -> Bool
identifier [] = False
identifier (first : rest) = asciiLetter first && all continuation rest
  where
    asciiLetter char = isAsciiLower char || isAsciiUpper char
    continuation char = asciiLetter char || (char >= '0' && char <= '9') || char == '_'

-- | Given a delimiter and text, return trimmed fields, preserving empty arguments.
fields :: Char -> String -> [String]
fields delimiter text = case break (== delimiter) text of
  (field, []) -> [trim field]
  (field, _ : remaining) -> trim field : fields delimiter remaining

-- | Given text, return it without leading or trailing whitespace.
trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

-- | Given first-line text, return it without a leading Unicode BOM.
stripBom :: String -> String
stripBom ('\xfeff' : rest) = rest
stripBom text = text

-- | Given a physical line, return it without trailing carriage returns.
stripCarriageReturn :: String -> String
stripCarriageReturn = dropWhileEnd (== '\r')

-- | Check a trimmed entity name; accept Unicode letters, digits, underscores and internal spaces.
entityIdentifier :: String -> Bool
entityIdentifier text = not (null text) && any (/= ' ') text
  && all (\char -> isAlphaNum char || char == '_' || char == ' ') text
