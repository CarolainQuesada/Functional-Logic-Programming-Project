module Pipeline (runPipeline) where

import Control.Concurrent (threadDelay)
import Control.Exception (IOException, bracketOnError, catch, displayException, evaluate, try)
import Control.Monad (forM_, when)
import Diagnostic
import Html (renderHtml)
import Input (readProblem)
import Model
import Prolog
import System.Directory (canonicalizePath, createDirectoryIfMissing, renameFile)
import System.FilePath ((</>), equalFilePath)
import System.IO (hClose, hPutStr, hSetEncoding, openTempFile, utf8)
import System.IO.Error (isPermissionError)
import Validation (validateProblem)
import ValidationReport (renderValidationReport)

-- | Regenerate all outputs; invalid input replaces old executable knowledge.
-- Output-directory failures propagate to the command rather than claiming success.
runPipeline :: FilePath -> FilePath -> IO Bool
runPipeline inputPath directory = do
  resolvedInput <- canonicalizePath inputPath
  destinations <- mapM (canonicalizePath . (directory </>)) names
  when (any (equalFilePath resolvedInput) destinations)
    (ioError (userError "Input and generated output must be different files."))
  createDirectoryIfMissing True directory
  let interrupted = inputFailure "Generation is in progress or was interrupted. Run the pipeline again."
      initial = artifacts inputPath interrupted
  -- Hide old downloads first, then invalidate executable output before reading.
  forM_ ["index.html", "reporte_validacion.txt", "conocimiento.pl", "consultas.pl"] $ \name ->
    case lookup name initial of
      Just contents -> writeAtomic directory name contents
      Nothing -> pure ()
  result <- try (readProblem inputPath) :: IO (Either IOException Problem)
  let problem = either (inputFailure . displayException) validateProblem result
      outputs = artifacts inputPath problem
  -- Fully render before publication; publish the interface last.
  forM_ outputs $ \(_, contents) -> evaluate (length contents) >> pure ()
  forM_ outputs $ \(name, contents) -> writeAtomic directory name contents
  pure (not (hasErrors (problemDiagnostics problem)))
  where
    names = ["conocimiento.pl", "consultas.pl", "reporte_validacion.txt", "index.html"]

inputFailure :: String -> Problem
inputFailure message = emptyProblem
  { problemDiagnostics = [Diagnostic Error InputFailure message FileLocation []] }

artifacts :: FilePath -> Problem -> [(FilePath, String)]
artifacts inputPath problem =
  [ ("conocimiento.pl", knowledge)
  , ("consultas.pl", queries)
  , ("reporte_validacion.txt", renderValidationReport problem)
  , ("index.html", renderHtml inputPath problem)
  ]
  where
    (knowledge, queries) = case generateProlog problem of
      Right output -> (knowledgeText output, queriesText output)
      Left _ -> (blocked, blocked)
    blocked = "% Generation blocked. This input has errors; see reporte_validacion.txt.\n"

writeAtomic :: FilePath -> FilePath -> String -> IO ()
writeAtomic directory name contents =
  bracketOnError (openTempFile directory ".pipeline.tmp") (hClose . snd) $ \(temporary, handle) -> do
    hSetEncoding handle utf8
    hPutStr handle contents
    hClose handle
    renameWithRetry 8 temporary (directory </> name)

-- | Windows can temporarily lock a newly written file; never hide persistent errors.
renameWithRetry :: Int -> FilePath -> FilePath -> IO ()
renameWithRetry attempts temporary destination = renameFile temporary destination `catch` retry
  where
    retry failure
      | attempts > 0 && isPermissionError failure =
          threadDelay 100000 >> renameWithRetry (attempts - 1) temporary destination
      | otherwise = ioError failure
