module Source
  ( SourceLine (..)
  , Located (..)
  , mapLocated
  ) where

-- | Physical input line, numbered from one before filtering blank lines.
data SourceLine = SourceLine
  { sourceLineNumber :: Int
  , sourceLineText :: String
  } deriving (Eq, Show)

data Located a = Located
  { sourceLine :: SourceLine
  , locatedValue :: a
  } deriving (Eq, Show)

-- | Transform a value without changing its original source information.
mapLocated :: (a -> b) -> Located a -> Located b
mapLocated transform (Located origin value) = Located origin (transform value)
