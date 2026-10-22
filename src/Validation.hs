module Validation (validateProblem) where

import Data.List (nub)
import Diagnostic
import Model
import Source

-- | Retain parsed records and syntax diagnostics while adding semantic findings.
validateProblem :: Problem -> Problem
validateProblem problem
  | any ((== InputFailure) . diagnosticCode) (problemDiagnostics problem) = problem
  | otherwise = problem { problemDiagnostics = nub (problemDiagnostics problem ++ findings) }
  where
    findings = missingSections ++ repeatedSections ++ duplicateEntities
      ++ referenceErrors ++ unsupportedRules ++ repeatedRelations ++ repeatedRules
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
    checkRelation record = concatMap (checkReference (sourceLine record))
      (relationReferences (locatedValue record))
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
    repeatedRules = duplicates locatedValue Warning DuplicateRule
      "Repeated rule request; generation should keep the first occurrence." (problemRules problem)

duplicates :: Eq key => (Located a -> key) -> Severity -> DiagnosticCode
  -> String -> [Located a] -> [Diagnostic]
duplicates key severity code message = go []
  where
    go _ [] = []
    go seen (record : rest) = case lookup (key record) seen of
      Just original -> Diagnostic severity code message
        (LineLocation (sourceLine record)) [original] : go seen rest
      Nothing -> go ((key record, sourceLine record) : seen) rest

sectionMarker :: Section -> String
sectionMarker EntitiesSection = "[ENTIDADES]"
sectionMarker RelationsSection = "[RELACIONES]"
sectionMarker RulesSection = "[REGLAS_SOLICITADAS]"
