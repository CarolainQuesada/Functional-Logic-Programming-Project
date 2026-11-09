module Prolog (PrologOutput (..), generateProlog, quoteAtom, entityFact, relationFact, renderRule, unique) where

import Data.List (intercalate, nubBy)
import Diagnostic (Diagnostic, hasErrors)
import Model
import Source
import Validation (validateProblem)

data PrologOutput = PrologOutput
  { knowledgeText :: String
  , queriesText :: String
  } deriving (Eq, Show)

-- | Validate a model and return either diagnostics or executable knowledge and queries.
-- Preserve entity case, retain source comments, and deduplicate repeated requests.
-- Rule definitions use the canonical Spanish predicates for either input vocabulary.
generateProlog :: Problem -> Either [Diagnostic] PrologOutput
generateProlog input
  | hasErrors (problemDiagnostics problem) = Left (problemDiagnostics problem)
  | otherwise = Right (PrologOutput knowledge queries)
  where
    problem = validateProblem input
    entities = problemEntities problem
    relations = unique (problemRelations problem)
    rules = unique (problemRules problem)
    knowledge = unlines
      ([ "% Generated knowledge. Do not edit manually."
       , ":- encoding(utf8)."
       , ":- dynamic persona/1, curso/1, docente/1, lleva/2, imparte/2."
       , ""
       ] ++ concatMap entityGroup [PersonKind, CourseKind, TeacherKind]
         ++ concatMap relationGroup [False, True]
         ++ concatMap renderRule rules)
    entityGroup kind = concatMap (renderLocated entityFact)
      (filter ((== kind) . entityKind . locatedValue) entities)
    relationGroup teaching = concatMap (renderLocated relationFact)
      (filter ((== teaching) . isTeaching . locatedValue) relations)
    queries = unlines
      ([ "% Generated suggested queries. Load this file, then call suggested_query(Query), call(Query)."
       , ":- encoding(utf8)."
       , ":- ensure_loaded('conocimiento.pl')."
       , ""
       ] ++ map (\query -> "suggested_query(" ++ query ++ ").")
         (["persona(_Person)", "curso(_Course)", "docente(_Teacher)",
           "lleva(_Person, _Course)", "imparte(_Teacher, _Course)"]
          ++ concatMap (ruleQueries . locatedValue) rules
          ++ concatMap concreteQueries (map locatedValue entities)))

-- | Given located records, return the first occurrence of each value in input order.
unique :: Eq a => [Located a] -> [Located a]
unique = nubBy (\first second -> locatedValue first == locatedValue second)

-- | Given a value renderer and located record, return source comment, rendered value and separator.
renderLocated :: (a -> String) -> Located a -> [String]
renderLocated render record = [traceComment (sourceLine record), render (locatedValue record), ""]

-- | Given a physical source line, return a single-line Prolog provenance comment.
traceComment :: SourceLine -> String
traceComment origin = "% Source line " ++ show (sourceLineNumber origin) ++ ": "
  ++ map singleLine (sourceLineText origin)
  where
    singleLine '\n' = ' '
    singleLine '\r' = ' '
    singleLine char = char

-- | Given an entity, return its canonical Spanish Prolog fact with a quoted name.
entityFact :: Entity -> String
entityFact entity = term predicate [entityName entity] ++ "."
  where
    predicate = case entityKind entity of
      PersonKind -> "persona"
      CourseKind -> "curso"
      TeacherKind -> "docente"

-- | Given a typed relation, return its Spanish Prolog fact with quoted arguments.
relationFact :: Relation -> String
relationFact (Enrolled persona curso) = term "lleva" [persona, curso] ++ "."
relationFact (Teaches docente curso) = term "imparte" [docente, curso] ++ "."

-- | Given a relation, return whether it represents teaching.
isTeaching :: Relation -> Bool
isTeaching (Teaches _ _) = True
isTeaching _ = False

-- | Given a predicate and entity names, return a Prolog term with quoted atom arguments.
term :: String -> [EntityName] -> String
term predicate names = predicate ++ "(" ++ intercalate ", " (map (quoteAtom . unEntityName) names) ++ ")"

-- | Given a located request, return its source comment and executable Spanish rule lines.
renderRule :: Located RequestedRule -> [String]
renderRule record = traceComment (sourceLine record) : body ++ [""]
  where
    body = case locatedValue record of
      Classmates ->
        [ "companero(First, Second) :-"
        , "    persona(First),"
        , "    persona(Second),"
        , "    dif(First, Second),"
        , "    once((lleva(First, Course), lleva(Second, Course)))."
        ]
      CourseWithTeacher ->
        [ "curso_con_docente(Course) :-"
        , "    curso(Course),"
        , "    once(imparte(_, Course))."
        ]
      ClassmatesInCourse -> ["companero(First, Second, Course) :-", "    lleva(First, Course), lleva(Second, Course), dif(First, Second)."]
      StudentOf -> ["estudiante_de(Student, Teacher) :-", "    lleva(Student, Course), imparte(Teacher, Course)."]
      CourseWithoutTeacher -> ["curso_sin_docente(Course) :-", "    curso(Course), \\+ imparte(_, Course)."]
      UnknownRule _ -> []

-- | Given a requested rule, return open query terms for its generated predicate.
ruleQueries :: RequestedRule -> [String]
ruleQueries Classmates = ["companero(_First, _Second)"]
ruleQueries CourseWithTeacher = ["curso_con_docente(_Course)"]
ruleQueries ClassmatesInCourse = ["companero(_First, _Second, _Course)"]
ruleQueries StudentOf = ["estudiante_de(_Student, _Teacher)"]
ruleQueries CourseWithoutTeacher = ["curso_sin_docente(_Course)"]
ruleQueries (UnknownRule _) = []

-- | From an entity, return queries using its actual quoted name.
concreteQueries :: Entity -> [String]
concreteQueries (Person name) = ["lleva(" ++ quoteAtom (unEntityName name) ++ ", _Curso)"]
concreteQueries (Course name) = ["imparte(_Docente, " ++ quoteAtom (unEntityName name) ++ ")"]
concreteQueries (Teacher name) = ["imparte(" ++ quoteAtom (unEntityName name) ++ ", _Curso)"]

-- | Quote names as SWI-Prolog atoms without changing their identity.
quoteAtom :: String -> String
quoteAtom value = "'" ++ concatMap escape value ++ "'"
  where
    escape '\'' = "\\'"
    escape '\\' = "\\\\"
    escape '\n' = "\\n"
    escape '\r' = "\\r"
    escape '\t' = "\\t"
    escape char = [char]
