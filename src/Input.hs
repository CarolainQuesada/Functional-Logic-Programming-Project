module Input (readProblem) where

import Control.Exception (evaluate)
import Model (Problem)
import Parser (parseProblem)
import System.IO (IOMode (ReadMode), hGetContents, hSetEncoding, utf8, withFile)

-- | Read a path as UTF-8 and return its parsed intermediate model.
-- Force decoding inside the open handle; propagate file and encoding IO errors.
readProblem :: FilePath -> IO Problem
readProblem path = withFile path ReadMode $ \handle -> do
  hSetEncoding handle utf8
  contents <- hGetContents handle
  _ <- evaluate (length contents)
  pure (parseProblem contents)
