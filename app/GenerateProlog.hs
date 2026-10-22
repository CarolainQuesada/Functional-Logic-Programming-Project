module Main (main) where

import Control.Exception (IOException, displayException, try)
import Control.Monad (when)
import Input (readProblem)
import Prolog (generateProlog)
import PrologFiles (writePrologFiles)
import System.Directory (canonicalizePath)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.FilePath ((</>), equalFilePath)
import System.IO (hPutStrLn, stderr)
import Validation (validateProblem)
import ValidationReport (writeValidationReport)

main :: IO ()
main = do
  arguments <- getArgs
  case arguments of
    [] -> run "input/problema.txt" "output"
    [inputPath, outputDirectory] -> run inputPath outputDirectory
    _ -> hPutStrLn stderr "Usage: runghc -isrc app/GenerateProlog.hs [INPUT OUTPUT_DIRECTORY]" >> exitFailure

run :: FilePath -> FilePath -> IO ()
run inputPath directory = do
  result <- try action :: IO (Either IOException Bool)
  case result of
    Left failure -> hPutStrLn stderr ("Generation failed: " ++ displayException failure) >> exitFailure
    Right True -> putStrLn ("Prolog and queries generated in " ++ directory)
    Right False -> do
      hPutStrLn stderr "Validation errors prevent Prolog generation. See reporte_validacion.txt."
      hPutStrLn stderr "Existing Prolog files were not updated; they may describe an earlier input."
      exitFailure
  where
    action = do
      resolvedInput <- canonicalizePath inputPath
      destinations <- mapM (canonicalizePath . (directory </>))
        ["conocimiento.pl", "consultas.pl", "reporte_validacion.txt"]
      when (any (equalFilePath resolvedInput) destinations)
        (ioError (userError "Input and generated output must be different files."))
      problem <- validateProblem <$> readProblem inputPath
      writeValidationReport (directory </> "reporte_validacion.txt") problem
      case generateProlog problem of
        Left _ -> pure False
        Right output -> writePrologFiles directory output >> pure True
