module Main (main) where

import Control.Monad (forM, forM_, unless)
import Data.Char (ord)
import Data.List (isInfixOf, isPrefixOf, tails)
import Diagnostic
import Input (readProblem)
import Model
import Parser (parseProblem)
import Prolog
import PrologFiles (writePrologFiles)
import System.Directory (createDirectoryIfMissing)
import System.Exit (ExitCode (..), exitFailure)
import System.FilePath ((</>))
import System.Process (readProcessWithExitCode)

main :: IO ()
main = do
  primaryProblem <- readProblem "input/problema.txt"
  alternateProblem <- readProblem "test/fixtures/alternate-valid.txt"
  primary <- generated primaryProblem
  alternate <- generated alternateProblem
  empty <- generated (academic "" "" "classmates\ncourse_with_teacher")
  noRules <- generated (academic "person: Alice" "" "")
  warnings <- generated sharedCourses
  caseSensitive <- generated (academic "person: Alice\nperson: alice\ncourse: Logic"
    "enrolled: Alice, Logic\nenrolled: alice, Logic" "classmates")
  invalidResults <- forM
    ["duplicate-entity.txt","undeclared-reference.txt","malformed-records.txt","missing-section.txt","unsupported-rule.txt"]
    (\file -> generateProlog <$> readProblem ("test/fixtures" </> file))
  let pureChecks =
        [ ("All invalid fixtures block generation", all rejected invalidResults)
        , ("Unvalidated empty model is rejected", rejected (generateProlog emptyProblem))
        , ("Names retain case as quoted atoms", "person('Alice')." `isInfixOf` knowledgeText primary)
        , ("All academic entity types produce facts", all (`isInfixOf` knowledgeText primary)
            ["person('Bob').","course('ProgrammingParadigms').","teacher('Morgan')."])
        , ("Relations produce typed predicates", all (`isInfixOf` knowledgeText primary)
            ["enrolled('Alice', 'ProgrammingParadigms').","teaches('Morgan', 'ProgrammingParadigms')."])
        , ("Facts retain their actual physical source lines", all (`isInfixOf` knowledgeText primary)
            ["% Source line 2: person: Alice","% Source line 8: enrolled: Alice, ProgrammingParadigms"])
        , ("Rules retain request source lines", all (`isInfixOf` knowledgeText primary)
            ["% Source line 13: classmates","% Source line 14: course_with_teacher"])
        , ("Only requested rules are emitted", not ("classmate(" `isInfixOf` knowledgeText noRules)
            && not ("course_with_teacher(" `isInfixOf` knowledgeText noRules))
        , ("Only requested rule queries are emitted", not ("classmate(" `isInfixOf` queriesText noRules))
        , ("Warnings allow deduplicated generation", occurrences "enrolled('Alice', 'Logic')." (knowledgeText warnings) == 1
            && occurrences "classmate(First, Second) :-" (knowledgeText warnings) == 1)
        , ("Duplicate provenance keeps the first occurrence", "% Source line 9: enrolled: Alice, Logic" `isInfixOf` knowledgeText warnings)
        , ("Queries load sibling knowledge file", ":- ensure_loaded('conocimiento.pl')." `isInfixOf` queriesText primary)
        , ("New input changes facts without fixed sample names", "person('Casey')." `isInfixOf` knowledgeText alternate
            && not ("'Alice'" `isInfixOf` knowledgeText alternate))
        , ("Atom escaping handles quotes and backslashes", quoteAtom "O'Brien\\Path" == "'O\\'Brien\\\\Path'")
        , ("Atom escaping handles control characters", quoteAtom "a\n\r\tb" == "'a\\n\\r\\tb'")
        , ("Existing parser errors also block generation", rejected (generateProlog (parseProblem "not a section")))
        ]
  forM_ pureChecks (uncurry check)
  let scenarios =
        [ ("primary", primary,
            "findall(X-Y,classmate(X,Y),Pairs),Pairs=['Alice'-'Bob','Bob'-'Alice'],"
            ++ "\\+classmate('Alice','Alice'),findall(C,course_with_teacher(C),Cs),Cs=['ProgrammingParadigms']")
        , ("alternate", alternate,
            "classmate('Casey','Jordan'),\\+classmate('Casey','Casey'),"
            ++ "findall(C,course_with_teacher(C),Cs),Cs=['Logic'],\\+course_with_teacher('Algebra')")
        , ("empty", empty,
            "findall(X-Y,classmate(X,Y),[]),findall(C,course_with_teacher(C),[]),findall(P,person(P),[])")
        , ("no-rules", noRules,
            "person('Alice'),\\+current_predicate(classmate/2),\\+current_predicate(course_with_teacher/1)")
        , ("shared-courses", warnings,
            "findall(X-Y,classmate(X,Y),Pairs),Pairs=['Alice'-'Bob','Bob'-'Alice'],"
            ++ "findall(C,course_with_teacher(C),Cs),Cs=['Logic','Algebra'],"
            ++ "findall(C,enrolled('Alice',C),Es),Es=['Logic','Algebra']")
        , ("case-sensitive", caseSensitive,
            "classmate('Alice','alice'),\\+classmate('Alice','Alice')")
        ]
  forM_ scenarios $ \(label, output, goal) -> do
    let directory = "output" </> "prolog-checks" </> label
    createDirectoryIfMissing True directory
    writePrologFiles directory output
    prologCheck (label ++ " knowledge") (directory </> "conocimiento.pl") goal
    prologCheck (label ++ " suggested queries") (directory </> "consultas.pl")
      "forall(suggested_query(Q),findall(Q,call(Q),_))"
  let escapedName = "O'Brien\\Path\n\t"
  prologCheck "quoted atom round trip" ("output" </> "prolog-checks" </> "primary" </> "conocimiento.pl")
    ("atom_codes(" ++ quoteAtom escapedName ++ "," ++ show (map ord escapedName) ++ ")")
  putStrLn ("All " ++ show (length pureChecks) ++ " generation checks and 13 SWI-Prolog checks passed.")

generated :: Problem -> IO PrologOutput
generated problem = case generateProlog problem of
  Right output -> pure output
  Left diagnostics -> putStrLn ("Unexpected generation failure: " ++ show diagnostics) >> exitFailure

rejected :: Either [Diagnostic] PrologOutput -> Bool
rejected (Left diagnostics) = hasErrors diagnostics
rejected (Right _) = False

check :: String -> Bool -> IO ()
check label condition = unless condition $ putStrLn ("FAIL: " ++ label) >> exitFailure

prologCheck :: String -> FilePath -> String -> IO ()
prologCheck label path goal = do
  (status, _, errors) <- readProcessWithExitCode "swipl"
    ["-q", "-f", "none", "-s", path, "-g", goal, "-t", "halt"] ""
  check (label ++ ": " ++ errors) (status == ExitSuccess && null errors)

occurrences :: String -> String -> Int
occurrences needle = length . filter (isPrefixOf needle) . tails

academic :: String -> String -> String -> Problem
academic entities relations rules = parseProblem (unlines
  ["[ENTIDADES]", entities, "[RELACIONES]", relations, "[REGLAS_SOLICITADAS]", rules])

sharedCourses :: Problem
sharedCourses = academic
  "person: Alice\nperson: Bob\ncourse: Logic\ncourse: Algebra\nteacher: Morgan\nteacher: Riley"
  "enrolled: Alice, Logic\nenrolled: Alice, Logic\nenrolled: Bob, Logic\nenrolled: Alice, Algebra\nenrolled: Bob, Algebra\nteaches: Morgan, Logic\nteaches: Riley, Logic\nteaches: Riley, Algebra"
  "classmates\nclassmates\ncourse_with_teacher"
