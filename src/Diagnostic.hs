module Diagnostic
  ( Severity (..)
  , DiagnosticCode (..)
  , DiagnosticLocation (..)
  , Diagnostic (..)
  , hasErrors
  ) where

import Source (SourceLine)

data Severity = Error | Warning
  deriving (Eq, Show)

data DiagnosticCode
  = MalformedRecord
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
  | DuplicateRule
  deriving (Eq, Show)

-- | File-level errors have no invented physical line number.
data DiagnosticLocation = FileLocation | LineLocation SourceLine
  deriving (Eq, Show)

data Diagnostic = Diagnostic
  { diagnosticSeverity :: Severity
  , diagnosticCode :: DiagnosticCode
  , diagnosticMessage :: String
  , diagnosticLocation :: DiagnosticLocation
  , diagnosticRelatedLines :: [SourceLine]
  } deriving (Eq, Show)

hasErrors :: [Diagnostic] -> Bool
hasErrors = any ((== Error) . diagnosticSeverity)
