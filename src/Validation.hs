module Validation (validateProblem) where

import Data.Char (toLower)
import Data.List (nub)
import Diagnostic
import Model
import Source

-- | Check required sections, uniqueness, typed references, and requested rules.
-- Return the model with accumulated diagnostics; repeated validation is idempotent.
-- Input failures bypass semantic checks to avoid cascading missing-section errors.
validateProblem :: Problem -> Problem
validateProblem problem
  | any ((== InputFailure) . diagnosticCode) (problemDiagnostics problem) = problem
  | otherwise = problem { problemDiagnostics = nub (problemDiagnostics problem ++ findings) }
  where
    findings = missingSections ++ repeatedSections ++ duplicateEntities
      ++ referenceErrors ++ unsupportedRules ++ repeatedRelations ++ repeatedRules ++ coverageWarnings ++ caseWarnings
    sections = problemSections problem
    entities = problemEntities problem
    missingSections =
      [ Diagnostic Error MissingSection ("Missing required section: " ++ sectionMarker section)
          FileLocation []
      | section <- [EntitiesSection, RelationsSection, RulesSection]
      , section `notElem` map locatedValue sections
      ]
    repeatedSections = duplicates locatedValue Error RepeatedSection
      "Repeated section." sections
    duplicateEntities = duplicates (entityName . locatedValue) Error DuplicateEntity
      "Entity names must be globally unique." entities
    referenceErrors = concatMap checkRelation (problemRelations problem)
    -- | Given a located relation, return diagnostics for both typed references.
    checkRelation record = concatMap (checkReference (sourceLine record))
      (relationReferences (locatedValue record))
    -- | Given relation origin and expected reference, return missing or wrong-type diagnostics.
    checkReference origin (name, expected) = case
      filter ((== name) . entityName . locatedValue) entities of
        [] -> [Diagnostic Error UndeclaredReference
          ("Undeclared entity: " ++ unEntityName name) (LineLocation origin) []]
        [declaration]
          | entityKind (locatedValue declaration) /= expected ->
              [Diagnostic Error ArgumentTypeMismatch
                ("Entity " ++ unEntityName name ++ " requires " ++ show expected
                  ++ " but was declared as " ++ show (entityKind (locatedValue declaration)) ++ ".")
                (LineLocation origin) [sourceLine declaration]]
        _ -> []
    unsupportedRules =
      [ Diagnostic Error UnsupportedRule ("Unsupported academic rule: " ++ name)
          (LineLocation (sourceLine record)) []
      | record <- problemRules problem
      , UnknownRule name <- [locatedValue record]
      ]
    repeatedRelations = duplicates locatedValue Warning DuplicateRelation
      "Repeated relation; generation should keep the first occurrence." (problemRelations problem)
    coverageWarnings = concatMap checkCoverage entities
    checkCoverage record =
      [ Diagnostic Warning code message (LineLocation (sourceLine record)) []
      | (code, message, present) <- checks (locatedValue record), not present ]
    relations = map locatedValue (problemRelations problem)
    checks entity = case entity of
      Course name ->
        [(CourseWithoutTeacherWarning, "Curso sin docente.", any (teaching name) relations),
         (CourseWithoutStudents, "Curso sin estudiantes.", any (studying name) relations)]
      Person name -> [(PersonWithoutCourses, "Persona que no lleva ningún curso.",
        any (\relation -> case relation of Enrolled who _ -> who == name; _ -> False) relations)]
      Teacher name -> [(TeacherWithoutCourses, "Docente que no imparte ningún curso.",
        any (\relation -> case relation of Teaches who _ -> who == name; _ -> False) relations)]
    teaching name relation = case relation of Teaches _ course -> course == name; _ -> False
    studying name relation = case relation of Enrolled _ course -> course == name; _ -> False
    caseWarnings =
      [ Diagnostic Warning CaseSimilarEntity "Entidades que solo difieren en mayúsculas/minúsculas."
          (LineLocation (sourceLine record)) [sourceLine original]
      | (index, record) <- zip [0 :: Int ..] entities
      , original <- take index entities
      , let name = unEntityName . entityName . locatedValue
      , name record /= name original
      , map toLower (name record) == map toLower (name original) ]
    repeatedRules = duplicates locatedValue Warning DuplicateRule
      "Repeated rule request; generation should keep the first occurrence." (problemRules problem)

-- | Given a key, severity, code, message and located records, return diagnostics linking repetitions to their first origin.
duplicates :: Eq key => (Located a -> key) -> Severity -> DiagnosticCode
  -> String -> [Located a] -> [Diagnostic]
duplicates key severity code message = go []
  where
    go _ [] = []
    go seen (record : rest) = case lookup (key record) seen of
      Just original -> Diagnostic severity code message
        (LineLocation (sourceLine record)) [original] : go seen rest
      Nothing -> go ((key record, sourceLine record) : seen) rest

-- | Given a section, return its required input header.
sectionMarker :: Section -> String
sectionMarker EntitiesSection = "[ENTIDADES]"
sectionMarker RelationsSection = "[RELACIONES]"
sectionMarker RulesSection = "[REGLAS_SOLICITADAS]"
