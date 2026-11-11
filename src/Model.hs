module Model
  ( EntityName (..)
  , EntityKind (..)
  , Entity (..)
  , Relation (..)
  , RequestedRule (..)
  , Section (..)
  , Problem (..)
  , emptyProblem
  , entityName
  , entityKind
  , relationReferences
  ) where

import Diagnostic (Diagnostic)
import Source (Located)

-- | Entity identifier exactly as written in the input; case and spaces are preserved.
newtype EntityName = EntityName { unEntityName :: String }
  deriving (Eq, Ord, Show)

-- | Entity type without its name, used to check that relation arguments have the expected type.
data EntityKind = PersonKind | CourseKind | TeacherKind
  deriving (Eq, Show)

-- | Entity declared in the [ENTIDADES] section: a person, a course or a teacher.
data Entity
  = Person EntityName
  | Course EntityName
  | Teacher EntityName
  deriving (Eq, Show)

-- | Relation declared in the [RELACIONES] section: a person enrolled in a course, or a teacher teaching a course.
data Relation
  = Enrolled EntityName EntityName
  | Teaches EntityName EntityName
  deriving (Eq, Show)

-- | Retain unknown names so domain validation can report them later.
data RequestedRule
  = Classmates
  | CourseWithTeacher
  | ClassmatesInCourse
  | StudentOf
  | CourseWithoutTeacher
  | UnknownRule String
  deriving (Eq, Show)

-- | The three required sections of problema.txt.
data Section = EntitiesSection | RelationsSection | RulesSection
  deriving (Eq, Show)

-- | Preserve input order and duplicates until validation diagnoses them.
data Problem = Problem
  { problemSections :: [Located Section]
  , problemEntities :: [Located Entity]
  , problemRelations :: [Located Relation]
  , problemRules :: [Located RequestedRule]
  , problemDiagnostics :: [Diagnostic]
  } deriving (Eq, Show)

-- | Construct an empty intermediate model before parsing; required sections are not implied.
emptyProblem :: Problem
emptyProblem = Problem [] [] [] [] []

-- | Extract the case-sensitive identifier shared by every entity constructor.
entityName :: Entity -> EntityName
entityName (Person name) = name
entityName (Course name) = name
entityName (Teacher name) = name

-- | Return the domain type used to validate relation arguments.
entityKind :: Entity -> EntityKind
entityKind (Person _) = PersonKind
entityKind (Course _) = CourseKind
entityKind (Teacher _) = TeacherKind

-- | Return references in argument order with the types each argument requires.
relationReferences :: Relation -> [(EntityName, EntityKind)]
relationReferences (Enrolled person course) =
  [(person, PersonKind), (course, CourseKind)]
relationReferences (Teaches teacher course) =
  [(teacher, TeacherKind), (course, CourseKind)]
