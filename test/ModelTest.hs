module Main (main) where

import Control.Monad (unless)
import Diagnostic
import Model
import Source
import System.Exit (exitFailure)

main :: IO ()
main = do
  let alice = EntityName "Alice"
      course = EntityName "Logic"
      teacher = EntityName "Morgan"
      firstLine = SourceLine 2 "  person: Alice  "
      repeatedLine = SourceLine 5 "person: Alice"
      declaration = Located firstLine (Person alice)
      repeated = Located repeatedLine (Person alice)
      warning = Diagnostic Warning DuplicateRule "Repeated rule request."
        (LineLocation (SourceLine 14 "classmates")) []
      missing = Diagnostic Error MissingSection "Missing rules section."
        FileLocation []
      duplicate = Diagnostic Error DuplicateEntity "Duplicate entity name."
        (LineLocation repeatedLine) [firstLine]
      problem = emptyProblem
        { problemEntities = [declaration, repeated]
        , problemRules = [Located (SourceLine 19 "grandparents") (UnknownRule "grandparents")]
        , problemDiagnostics = [warning, duplicate]
        }
  check "Empty input model retains absent sections" (null (problemSections emptyProblem))
  check "Entity names retain case" (alice /= EntityName "alice")
  check "Entity identity and kind are available"
    (entityName (Teacher teacher) == teacher && entityKind (Teacher teacher) == TeacherKind)
  check "Enrollment references preserve argument order and expected kinds"
    (relationReferences (Enrolled alice course) == [(alice, PersonKind), (course, CourseKind)])
  check "Teaching references require a teacher and a course"
    (relationReferences (Teaches teacher course) == [(teacher, TeacherKind), (course, CourseKind)])
  check "Transformation preserves physical line and untrimmed source"
    (mapLocated entityName declaration == Located firstLine alice)
  check "Model preserves duplicate declarations and their locations"
    (problemEntities problem == [declaration, repeated])
  check "Unknown rule names remain available for domain validation"
    (map locatedValue (problemRules problem) == [UnknownRule "grandparents"])
  check "Warnings alone do not block generation" (not (hasErrors [warning]))
  check "An error among warnings blocks generation" (hasErrors (problemDiagnostics problem))
  check "Missing section diagnostics have no artificial source line"
    (diagnosticLocation missing == FileLocation)
  check "Duplicate diagnostics retain both source locations"
    (diagnosticLocation duplicate == LineLocation repeatedLine
      && diagnosticRelatedLines duplicate == [firstLine])
  putStrLn "All 12 model checks passed."

check :: String -> Bool -> IO ()
check label condition = unless condition $ do
  putStrLn ("FAIL: " ++ label)
  exitFailure
