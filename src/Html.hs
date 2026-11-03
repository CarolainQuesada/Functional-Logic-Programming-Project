module Html (renderHtml, escapeHtml) where

import Data.List (elemIndex)
import Diagnostic
import HtmlStyle (stylesheet)
import Model
import Prolog
import Source
import Validation (validateProblem)

-- | Render a complete standalone page from the validated intermediate model.
-- Escape input-derived text and hide executable downloads when errors block generation.
renderHtml :: FilePath -> Problem -> String
renderHtml inputName input = concat
  [ "<!doctype html><html lang=\"es\"><head><meta charset=\"utf-8\">"
  , "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
  , "<meta name=\"description\" content=\"Conocimiento académico generado y resultados de validación.\">"
  , "<title>Cuaderno de lógica | Explorador de conocimiento</title><style>", stylesheet, "</style></head><body>"
  , "<a class=\"skip\" href=\"#main\">Saltar al contenido</a>"
  , "<header><div class=\"brand\"><span class=\"brand-mark\" aria-hidden=\"true\">c.</span> conocimiento<span class=\"brand-sub\"> / cuaderno</span></div>"
  , "<nav aria-label=\"Secciones\"><a href=\"#entities\">Entidades</a><a href=\"#relations\">Relaciones</a>"
  , "<a href=\"#knowledge\">Conocimiento</a><a href=\"#queries\">Consultas</a><a href=\"#validation\">Validación</a></nav></header>"
  , "<main id=\"main\"><div class=\"hero\"><div><div class=\"eyebrow\">CUADERNO DE LÓGICA <span> / 01</span></div>"
  , "<h1>Cada conexión<br>cuenta una <em>historia.</em></h1>"
  , "<p class=\"muted\">Explora las personas, los cursos y las ideas que conectan tus datos. "
  , "Sigue cada hecho desde su origen hasta su conclusión lógica.</p><p class=\"muted\">Archivo de entrada: <code>"
  , escapeHtml inputName, "</code></p></div><div class=\"hero-aside\"><span class=\"status ", statusClass, "\">", status, "</span>", connectionMap problem, "</div></div>"
  , "<div class=\"stats\">", stat (length (problemEntities problem)) "Entidades"
  , stat (length (problemRelations problem)) "Relaciones", stat (length (problemRules problem)) "Reglas solicitadas"
  , stat (length diagnostics) "Diagnósticos", "</div>"
  , "<div class=\"workspace-heading\"><div><div class=\"eyebrow\">ÁREA DE EXPLORACIÓN</div><h2>Tu conocimiento, al descubierto.</h2></div><div class=\"links\"><a href=\"reporte_validacion.txt\" download>Reporte de validación</a>"
  , if invalid then "" else "<a href=\"conocimiento.pl\" download>Archivo de conocimiento</a><a href=\"consultas.pl\" download>Archivo de consultas</a>"
  , "</div></div><div class=\"grid\">"
  , panel "entities" "Las personas y los cursos" "Cada entidad conserva su nombre original y su línea de origen."
      (table "Entidades declaradas" ["Nombre", "Tipo", "Línea"] (map entityRow (problemEntities problem)))
  , panel "relations" "Cómo se conectan" "Las relaciones conectan a las personas, los docentes y los cursos declarados."
      (table "Relaciones declaradas" ["Relación", "Origen", "Destino", "Línea"] (map relationRow (problemRelations problem)))
  , "</div><div class=\"wide\">"
  , panel "rules" "La lógica detrás de los datos" "Se generan únicamente las reglas solicitadas para el dominio."
      (table "Reglas solicitadas" ["Regla", "Línea"] (map ruleRow (problemRules problem)))
  , panel "knowledge" "Dentro de la base de conocimiento" "Hechos y reglas de conocimiento.pl, con referencias a sus líneas de origen."
      (case generated of
        Left _ -> blocked
        Right output -> codeBlock (knowledgeText output))
  , panel "queries" "Pregúntale a tus datos" "Carga consultas.pl en SWI-Prolog y ejecuta suggested_query(Query), call(Query)."
      (case generated of
        Left _ -> blocked
        Right output -> codeBlock (queriesText output))
  , panel "validation" "Una última revisión" (show errors ++ " errores / " ++ show warnings ++ " advertencias")
      (if null diagnostics then "<div class=\"notice\">Sin errores ni advertencias. Los datos están listos para Prolog.</div>"
       else concatMap diagnosticHtml diagnostics)
  , "</div><footer>Generado con Haskell a partir del archivo de entrada. El conocimiento lógico se puede ejecutar en SWI-Prolog. "
  , "Si cambias los datos de entrada, vuelve a ejecutar el programa para actualizar esta página.</footer></main></body></html>"
  ]
  where
    problem = validateProblem input
    generated = generateProlog problem
    diagnostics = problemDiagnostics problem
    invalid = hasErrors diagnostics
    errors = length (filter ((== Error) . diagnosticSeverity) diagnostics)
    warnings = length diagnostics - errors
    status | invalid = "Validación fallida"
           | warnings > 0 = "Válido con advertencias"
           | otherwise = "Validación correcta"
    statusClass | invalid = "invalid"
                | warnings > 0 = "warning"
                | otherwise = "valid"
    blocked = "<div class=\"notice error\">La generación está bloqueada por errores de validación. Revisa los diagnósticos más abajo.</div>"

stat :: Int -> String -> String
stat count label = "<div class=\"stat\"><strong>" ++ show count ++ "</strong><span>" ++ label ++ "</span></div>"

panel :: String -> String -> String -> String -> String
panel identifier title note body = "<section class=\"panel\" id=\"" ++ identifier ++ "\"><div class=\"panel-kicker\">" ++ sectionNumber identifier ++ " / " ++ sectionLabel identifier ++ "</div><h2>" ++ title
  ++ "</h2><p class=\"section-note\">" ++ escapeHtml note ++ "</p>" ++ body ++ "</section>"

table :: String -> [String] -> [[String]] -> String
table caption headers rows
  | null rows = "<p class=\"muted\">No hay registros en esta sección.</p>"
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
      PersonKind -> "Persona"
      CourseKind -> "Curso"
      TeacherKind -> "Docente"

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
codeBlock contents = "<div class=\"code-toolbar\"><span><i></i><i></i><i></i></span><span>PROLOG / CÓDIGO GENERADO</span></div><pre class=\"code\"><code>" ++ concatMap highlightLine (lines contents) ++ "</code></pre>"
  where
    highlightLine line = "<span class=\"code-line " ++ (if take 1 line == "%" then "comment" else "statement")
      ++ "\">" ++ escapeHtml line ++ "</span>\n"

diagnosticHtml :: Diagnostic -> String
diagnosticHtml diagnostic = "<article class=\"diagnostic\"><h3>" ++ (if diagnosticSeverity diagnostic == Error then "Error" else "Advertencia")
  ++ " <span class=\"tag\">" ++ show (diagnosticCode diagnostic) ++ "</span></h3><p>"
  ++ escapeHtml (diagnosticMessageEs diagnostic) ++ "</p>" ++ location
  ++ concatMap (\origin -> "<p class=\"muted\">Línea relacionada " ++ show (sourceLineNumber origin)
      ++ ": <code>" ++ escapeHtml (sourceLineText origin) ++ "</code></p>") (diagnosticRelatedLines diagnostic)
  ++ "</article>"
  where
    location = case diagnosticLocation diagnostic of
      FileLocation -> "<p class=\"muted\">Diagnóstico del archivo</p>"
      LineLocation origin -> "<p class=\"muted\">Línea " ++ show (sourceLineNumber origin)
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

-- | Give workspace sections stable editorial numbers independent of input size.
sectionNumber :: String -> String
sectionNumber identifier = case identifier of
  "entities" -> "01"
  "relations" -> "02"
  "rules" -> "03"
  "knowledge" -> "04"
  "queries" -> "05"
  _ -> "06"

-- | Draw the actual typed declarations and relationships without browser scripts.
-- Every label is escaped; node placement scales with the number of declarations.
connectionMap :: Problem -> String
connectionMap problem = "<div class=\"map-card\"><div class=\"map-heading\"><span>MAPA DE CONEXIONES</span><span>"
  ++ show (length nodes) ++ " NODOS</span></div>"
  ++ (if null nodes then "<p class=\"muted\">Tus conexiones aparecerán aquí.</p>"
      else "<div class=\"map-scroll\"><svg viewBox=\"0 0 480 " ++ show height
        ++ "\" role=\"img\" aria-label=\"Relaciones entre las entidades del archivo de entrada\">"
        ++ concatMap edge (problemRelations problem) ++ concatMap node nodes ++ "</svg></div>")
  ++ "<div class=\"map-legend\"><span>Personas y docentes</span><span>Cursos</span></div></div>"
  where
    nodes = map locatedValue (problemEntities problem)
    left = filter ((/= CourseKind) . entityKind) nodes
    right = filter ((== CourseKind) . entityKind) nodes
    height = max 200 (70 * max (length left) (length right) + 40)
    position :: Entity -> (Int, Int)
    position entity = let group = if entityKind entity == CourseKind then right else left
                          offset = maybe 0 id (elemIndex entity group)
                      in (if entityKind entity == CourseKind then 350 else 120,
                          45 + offset * 70 + (height - 40 - length group * 70) `div` 2)
    point name = case filter ((== name) . entityName) nodes of
      entity : _ -> Just (position entity)
      [] -> Nothing
    edge record = case relationReferences (locatedValue record) of
      [(first,_),(second,_)] -> case (point first, point second) of
        (Just (x1,y1), Just (x2,y2)) -> "<path class=\"map-edge\" d=\"M " ++ show x1 ++ " " ++ show y1
          ++ " C 240 " ++ show y1 ++ ", 240 " ++ show y2 ++ ", " ++ show x2 ++ " " ++ show y2 ++ "\"/>"
        _ -> ""
      _ -> ""
    node entity = let (x,y) = position entity
                      kind = if entityKind entity == CourseKind then "course" else "person"
                  in "<g class=\"map-node " ++ kind ++ "\"><title>" ++ escapeHtml (unEntityName (entityName entity))
                    ++ "</title><circle cx=\"" ++ show x ++ "\" cy=\"" ++ show y ++ "\" r=\"9\"/>"
                    ++ "<text x=\"" ++ show x ++ "\" y=\"" ++ show (y + 29) ++ "\" text-anchor=\"middle\">"
                    ++ escapeHtml (unEntityName (entityName entity)) ++ "</text></g>"

-- | Translate visible labels while keeping stable English section identifiers.
sectionLabel :: String -> String
sectionLabel identifier = case identifier of
  "entities" -> "entidades"
  "relations" -> "relaciones"
  "rules" -> "reglas"
  "knowledge" -> "conocimiento"
  "queries" -> "consultas"
  _ -> "validación"

-- | Explain validation errors in Spanish; source excerpts retain the input vocabulary.
-- Diagnostic codes remain available as technical identifiers.
diagnosticMessageEs :: Diagnostic -> String
diagnosticMessageEs diagnostic = case diagnosticCode diagnostic of
  InputFailure -> "No se pudo leer el archivo de entrada. Comprueba la ruta, los permisos y la codificación UTF-8."
  MalformedRecord -> "El formato de esta línea no es válido. Usa tipo: Nombre, relación: Origen, Destino o el nombre de una regla, según la sección."
  UnknownVocabulary -> "El tipo de entidad o relación no pertenece al vocabulario académico admitido."
  UnknownSection -> "La cabecera de sección es desconocida o tiene un formato incorrecto."
  MissingSection -> "Falta una sección obligatoria. El archivo debe incluir [ENTIDADES], [RELACIONES] y [REGLAS_SOLICITADAS]."
  RepeatedSection -> "Esta sección aparece más de una vez. Cada sección debe declararse una sola vez."
  RecordOutsideSection -> "Este registro está fuera de una sección reconocida."
  DuplicateEntity -> "Este nombre de entidad ya fue declarado. Los nombres deben ser únicos en todo el archivo."
  UndeclaredReference -> "La relación utiliza una entidad que no ha sido declarada."
  ArgumentTypeMismatch -> "El tipo de una entidad no corresponde al argumento de la relación. Revisa la declaración relacionada."
  UnsupportedRule -> "La regla solicitada no corresponde al dominio académico admitido."
  DuplicateRelation -> "Esta relación está repetida. Se conserva únicamente su primera aparición."
  DuplicateRule -> "Esta regla está repetida. Se conserva únicamente su primera solicitud."
