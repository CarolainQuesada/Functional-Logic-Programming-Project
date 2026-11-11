module Diagnostic
  ( Severity (..)
  , DiagnosticCode (..)
  , DiagnosticLocation (..)
  , Diagnostic (..)
  , hasErrors
  ) where

import Source (SourceLine)

-- | Severity of a diagnostic. Errors block Prolog generation; warnings are reported but allow it.
data Severity = Error | Warning
  deriving (Eq, Show)

-- | Stable identifier for each kind of input, syntax, reference or domain problem shown in the report.
data DiagnosticCode
  = InputFailure
  | MalformedRecord
  | UnknownVocabulary
  | UnknownSection
  | MissingSection
  | RepeatedSection
  | RecordOutsideSection
  | DuplicateEntity
  | UndeclaredReference
  | ArgumentTypeMismatch
  | UnsupportedRule
  | DuplicateRelation
  | CourseWithoutTeacherWarning
  | CourseWithoutStudents
  | PersonWithoutCourses
  | TeacherWithoutCourses
  | CaseSimilarEntity
  | DuplicateRule
  deriving (Eq, Show)

-- | File-level errors have no invented physical line number.
data DiagnosticLocation = FileLocation | LineLocation SourceLine
  deriving (Eq, Show)

-- | One reported problem with its severity, code, message, primary location and related source lines.
data Diagnostic = Diagnostic
  { diagnosticSeverity :: Severity
  , diagnosticCode :: DiagnosticCode
  , diagnosticMessage :: String
  , diagnosticLocation :: DiagnosticLocation
  , diagnosticRelatedLines :: [SourceLine]
  } deriving (Eq, Show)

-- | Return whether any diagnostic blocks executable output; warnings alone do not.
hasErrors :: [Diagnostic] -> Bool
hasErrors = any ((== Error) . diagnosticSeverity)
