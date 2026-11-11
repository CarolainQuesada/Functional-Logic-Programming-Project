module ValidationReport (renderValidationReport) where

import Diagnostic
import Model (Problem (problemDiagnostics))
import Source

-- | Render accumulated diagnostics, status, counts, and physical source locations.
-- The caller must validate the model first; this function performs no IO.
renderValidationReport :: Problem -> String
renderValidationReport problem = unlines
  ([ "Validation report"
   , "Status: " ++ status
   , "Errors: " ++ show (count Error)
   , "Warnings: " ++ show (count Warning)
   , ""
   ] ++ if null diagnostics then ["No errors or warnings."] else concatMap render diagnostics)
  where
    diagnostics = problemDiagnostics problem
    count severity = length (filter ((== severity) . diagnosticSeverity) diagnostics)
    status | hasErrors diagnostics = "INVALID"
           | count Warning > 0 = "VALID WITH WARNINGS"
           | otherwise = "VALID"
    render diagnostic =
      [ show (diagnosticSeverity diagnostic) ++ " [" ++ show (diagnosticCode diagnostic) ++ "]"
      , "Location: " ++ location (diagnosticLocation diagnostic)
      , diagnosticMessage diagnostic
      ] ++ primarySource (diagnosticLocation diagnostic)
        ++ concatMap relatedSource (diagnosticRelatedLines diagnostic) ++ [""]
    location FileLocation = "file"
    location (LineLocation origin) = "line " ++ show (sourceLineNumber origin)
    primarySource FileLocation = []
    primarySource (LineLocation origin) = ["Source: " ++ sourceLineText origin]
    relatedSource origin =
      ["Related line " ++ show (sourceLineNumber origin) ++ ": " ++ sourceLineText origin]
