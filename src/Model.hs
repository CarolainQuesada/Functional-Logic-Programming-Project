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

newtype EntityName = EntityName { unEntityName :: String }
  deriving (Eq, Ord, Show)

data EntityKind = PersonKind | CourseKind | TeacherKind
  deriving (Eq, Show)

data Entity
  = Person EntityName
  | Course EntityName
  | Teacher EntityName
  deriving (Eq, Show)

data Relation
  = Enrolled EntityName EntityName
  | Teaches EntityName EntityName
  deriving (Eq, Show)

-- | Retain unknown names so domain validation can report them later.
data RequestedRule
  = Classmates
  | CourseWithTeacher
  | UnknownRule String
  deriving (Eq, Show)

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

emptyProblem :: Problem
emptyProblem = Problem [] [] [] [] []

entityName :: Entity -> EntityName
entityName (Person name) = name
entityName (Course name) = name
entityName (Teacher name) = name

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
