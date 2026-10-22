module Main (main) where

import Control.Exception (IOException, displayException, try)
import Diagnostic (hasErrors)
import Input (readProblem)
import Model (problemDiagnostics)
import System.Directory (canonicalizePath)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.FilePath (equalFilePath)
import System.IO (hPutStrLn, stderr)
import Validation (validateProblem)
import ValidationReport (writeValidationReport)

main :: IO ()
main = do
  arguments <- getArgs
  case arguments of
    [] -> run "input/problema.txt" "output/reporte_validacion.txt"
    [inputPath, reportPath] | inputPath /= reportPath -> run inputPath reportPath
    _ -> do
      hPutStrLn stderr "Usage: runghc -isrc app/Validate.hs [INPUT REPORT]"
      hPutStrLn stderr "Input and report must be different files. The report directory must exist."
      exitFailure

run :: FilePath -> FilePath -> IO ()
run inputPath reportPath = do
  result <- try action :: IO (Either IOException Bool)
  case result of
    Left failure -> hPutStrLn stderr ("Validation failed: " ++ displayException failure) >> exitFailure
    Right valid -> do
      putStrLn ("Validation report written to " ++ reportPath)
      if valid then putStrLn "Validation passed." else exitFailure
  where
    action = do
      resolvedInput <- canonicalizePath inputPath
      resolvedReport <- canonicalizePath reportPath
      if equalFilePath resolvedInput resolvedReport
        then ioError (userError "Input and report must be different files.")
        else pure ()
      problem <- validateProblem <$> readProblem inputPath
      writeValidationReport reportPath problem
      pure (not (hasErrors (problemDiagnostics problem)))
