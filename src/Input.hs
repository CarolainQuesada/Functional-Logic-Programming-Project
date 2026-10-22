module Input (readProblem) where

import Control.Exception (evaluate)
import Model (Problem)
import Parser (parseProblem)
import System.IO (IOMode (ReadMode), hGetContents, hSetEncoding, utf8, withFile)

-- | Decode UTF-8 fully before closing the handle; IO failures remain IO errors.
readProblem :: FilePath -> IO Problem
readProblem path = withFile path ReadMode $ \handle -> do
  hSetEncoding handle utf8
  contents <- hGetContents handle
  _ <- evaluate (length contents)
  pure (parseProblem contents)
