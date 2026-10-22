module Html (renderHtml, escapeHtml) where

import Diagnostic
import HtmlStyle (stylesheet)
import Model
import Prolog
import Source
import Validation (validateProblem)

-- | Generate all displayed data from the same validated model as Prolog.
renderHtml :: FilePath -> Problem -> String
renderHtml inputName input = concat
  [ "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
  , "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
  , "<meta name=\"description\" content=\"Generated academic knowledge and validation results.\">"
  , "<title>Knowledge Explorer | Academic Pipeline</title><style>", stylesheet, "</style></head><body>"
  , "<a class=\"skip\" href=\"#main\">Skip to content</a>"
  , "<header><div class=\"brand\">KNOWLEDGE<span> / EXPLORER</span></div>"
  , "<nav aria-label=\"Sections\"><a href=\"#entities\">Entities</a><a href=\"#relations\">Relations</a>"
  , "<a href=\"#knowledge\">Knowledge</a><a href=\"#queries\">Queries</a><a href=\"#validation\">Validation</a></nav></header>"
  , "<main id=\"main\"><div class=\"hero\"><div><div class=\"eyebrow\">Academic knowledge pipeline</div>"
  , "<h1>From structured text<br>to connected knowledge.</h1>"
  , "<p class=\"muted\">Explore the entities, relationships, and logical rules discovered in your input. "
  , "Every result below is regenerated from the source file.</p><p class=\"muted\">Source: <code>"
  , escapeHtml inputName, "</code></p></div><span class=\"status ", statusClass, "\">", status, "</span></div>"
  , "<div class=\"stats\">", stat (length (problemEntities problem)) "Entities"
  , stat (length (problemRelations problem)) "Relations", stat (length (problemRules problem)) "Rule requests"
  , stat (length diagnostics) "Diagnostics", "</div>"
  , "<div class=\"links\"><a href=\"reporte_validacion.txt\" download>Validation report</a>"
  , if invalid then "" else "<a href=\"conocimiento.pl\" download>Knowledge file</a><a href=\"consultas.pl\" download>Query file</a>"
  , "</div><div class=\"grid\">"
  , panel "entities" "Entities detected" "Declarations retain their original names and source lines."
      (table "Entity declarations" ["Name", "Type", "Line"] (map entityRow (problemEntities problem)))
  , panel "relations" "Relations detected" "References connect declared people, teachers, and courses."
      (table "Relation records" ["Relation", "Source", "Target", "Line"] (map relationRow (problemRelations problem)))
  , "</div><div class=\"wide\">"
  , panel "rules" "Logical rules" "Only requested domain rules are generated."
      (table "Requested rules" ["Rule", "Line"] (map ruleRow (problemRules problem)))
  , panel "knowledge" "Generated knowledge" "Facts and rule definitions in conocimiento.pl, including source traceability."
      (case generated of
        Left _ -> blocked
        Right output -> codeBlock (knowledgeText output))
  , panel "queries" "Suggested queries" "Load consultas.pl in SWI-Prolog, then use suggested_query(Query), call(Query)."
      (case generated of
        Left _ -> blocked
        Right output -> codeBlock (queriesText output))
  , panel "validation" "Validation results" (show errors ++ " errors / " ++ show warnings ++ " warnings")
      (if null diagnostics then "<div class=\"notice\">No errors or warnings. This input is ready for Prolog.</div>"
       else concatMap diagnosticHtml diagnostics)
  , "</div><footer>Generated from input data with Haskell. Logical knowledge is executable in SWI-Prolog. "
  , "Regenerate this page after changing the input; do not edit generated results manually.</footer></main></body></html>"
  ]
  where
    problem = validateProblem input
    generated = generateProlog problem
    diagnostics = problemDiagnostics problem
    invalid = hasErrors diagnostics
    errors = length (filter ((== Error) . diagnosticSeverity) diagnostics)
    warnings = length diagnostics - errors
    status | invalid = "Validation failed"
           | warnings > 0 = "Valid with warnings"
           | otherwise = "Validation passed"
    statusClass | invalid = "invalid"
                | warnings > 0 = "warning"
                | otherwise = "valid"
    blocked = "<div class=\"notice error\">Generation is blocked by validation errors. Review the diagnostics below.</div>"

stat :: Int -> String -> String
stat count label = "<div class=\"stat\"><strong>" ++ show count ++ "</strong><span>" ++ label ++ "</span></div>"

panel :: String -> String -> String -> String -> String
panel identifier title note body = "<section class=\"panel\" id=\"" ++ identifier ++ "\"><h2>" ++ title
  ++ "</h2><p class=\"section-note\">" ++ escapeHtml note ++ "</p>" ++ body ++ "</section>"

table :: String -> [String] -> [[String]] -> String
table caption headers rows
  | null rows = "<p class=\"muted\">No records in this section.</p>"
  | otherwise = "<div class=\"table-wrap\"><table><caption>" ++ caption ++ "</caption><thead><tr>"
      ++ concatMap (\header -> "<th scope=\"col\">" ++ header ++ "</th>") headers
      ++ "</tr></thead><tbody>" ++ concatMap row rows ++ "</tbody></table></div>"
  where
    row cells = "<tr>" ++ concatMap (\cell -> "<td>" ++ escapeHtml cell ++ "</td>") cells ++ "</tr>"

entityRow :: Located Entity -> [String]
entityRow record = [unEntityName (entityName value), kind, lineNumber record]
  where
    value = locatedValue record
    kind = case entityKind value of
      PersonKind -> "Person"
      CourseKind -> "Course"
      TeacherKind -> "Teacher"

relationRow :: Located Relation -> [String]
relationRow record = case locatedValue record of
  Enrolled person course -> ["enrolled", unEntityName person, unEntityName course, lineNumber record]
  Teaches teacher course -> ["teaches", unEntityName teacher, unEntityName course, lineNumber record]

ruleRow :: Located RequestedRule -> [String]
ruleRow record = [name, lineNumber record]
  where
    name = case locatedValue record of
      Classmates -> "classmates"
      CourseWithTeacher -> "course_with_teacher"
      UnknownRule value -> value

lineNumber :: Located a -> String
lineNumber = show . sourceLineNumber . sourceLine

codeBlock :: String -> String
codeBlock contents = "<pre class=\"code\"><code>" ++ escapeHtml contents ++ "</code></pre>"

diagnosticHtml :: Diagnostic -> String
diagnosticHtml diagnostic = "<article class=\"diagnostic\"><h3>" ++ show (diagnosticSeverity diagnostic)
  ++ " <span class=\"tag\">" ++ show (diagnosticCode diagnostic) ++ "</span></h3><p>"
  ++ escapeHtml (diagnosticMessage diagnostic) ++ "</p>" ++ location
  ++ concatMap (\origin -> "<p class=\"muted\">Related line " ++ show (sourceLineNumber origin)
      ++ ": <code>" ++ escapeHtml (sourceLineText origin) ++ "</code></p>") (diagnosticRelatedLines diagnostic)
  ++ "</article>"
  where
    location = case diagnosticLocation diagnostic of
      FileLocation -> "<p class=\"muted\">File-level diagnostic</p>"
      LineLocation origin -> "<p class=\"muted\">Line " ++ show (sourceLineNumber origin)
        ++ ": <code>" ++ escapeHtml (sourceLineText origin) ++ "</code></p>"

escapeHtml :: String -> String
escapeHtml = concatMap escape
  where
    escape '&' = "&amp;"
    escape '<' = "&lt;"
    escape '>' = "&gt;"
    escape '"' = "&quot;"
    escape '\'' = "&#39;"
    escape char = [char]
