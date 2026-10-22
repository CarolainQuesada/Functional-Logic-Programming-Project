module Prolog (PrologOutput (..), generateProlog, quoteAtom) where

import Data.List (intercalate, nubBy)
import Diagnostic (Diagnostic, hasErrors)
import Model
import Source
import Validation (validateProblem)

data PrologOutput = PrologOutput
  { knowledgeText :: String
  , queriesText :: String
  } deriving (Eq, Show)

-- | Revalidate before generation; invalid models never yield executable output.
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
       , ":- dynamic person/1, course/1, teacher/1, enrolled/2, teaches/2."
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
         (["person(_Person)", "course(_Course)", "teacher(_Teacher)",
           "enrolled(_Person, _Course)", "teaches(_Teacher, _Course)"]
          ++ concatMap (ruleQueries . locatedValue) rules))

unique :: Eq a => [Located a] -> [Located a]
unique = nubBy (\first second -> locatedValue first == locatedValue second)

renderLocated :: (a -> String) -> Located a -> [String]
renderLocated render record = [traceComment (sourceLine record), render (locatedValue record), ""]

traceComment :: SourceLine -> String
traceComment origin = "% Source line " ++ show (sourceLineNumber origin) ++ ": "
  ++ map singleLine (sourceLineText origin)
  where
    singleLine '\n' = ' '
    singleLine '\r' = ' '
    singleLine char = char

entityFact :: Entity -> String
entityFact entity = term predicate [entityName entity] ++ "."
  where
    predicate = case entityKind entity of
      PersonKind -> "person"
      CourseKind -> "course"
      TeacherKind -> "teacher"

relationFact :: Relation -> String
relationFact (Enrolled person course) = term "enrolled" [person, course] ++ "."
relationFact (Teaches teacher course) = term "teaches" [teacher, course] ++ "."

isTeaching :: Relation -> Bool
isTeaching (Teaches _ _) = True
isTeaching _ = False

term :: String -> [EntityName] -> String
term predicate names = predicate ++ "(" ++ intercalate ", " (map (quoteAtom . unEntityName) names) ++ ")"

renderRule :: Located RequestedRule -> [String]
renderRule record = traceComment (sourceLine record) : body ++ [""]
  where
    body = case locatedValue record of
      Classmates ->
        [ "classmate(First, Second) :-"
        , "    person(First),"
        , "    person(Second),"
        , "    dif(First, Second),"
        , "    once((enrolled(First, Course), enrolled(Second, Course)))."
        ]
      CourseWithTeacher ->
        [ "course_with_teacher(Course) :-"
        , "    course(Course),"
        , "    once(teaches(_, Course))."
        ]
      UnknownRule _ -> []

ruleQueries :: RequestedRule -> [String]
ruleQueries Classmates = ["classmate(_First, _Second)"]
ruleQueries CourseWithTeacher = ["course_with_teacher(_Course)"]
ruleQueries (UnknownRule _) = []

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
