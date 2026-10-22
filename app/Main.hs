module Main (main) where

import Control.Exception (IOException, displayException, try)
import Pipeline (runPipeline)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)

main :: IO ()
main = do
  arguments <- getArgs
  case arguments of
    ["--help"] -> putStrLn usage
    [] -> run "input/problema.txt" "output"
    [inputPath, directory] -> run inputPath directory
    _ -> hPutStrLn stderr usage >> exitFailure
  where
    usage = "Usage: runghc -isrc app/Main.hs [INPUT OUTPUT_DIRECTORY]"
    run inputPath directory = do
      result <- try (runPipeline inputPath directory) :: IO (Either IOException Bool)
      case result of
        Left failure -> hPutStrLn stderr ("Pipeline failed: " ++ displayException failure) >> exitFailure
        Right False -> hPutStrLn stderr ("Input is invalid. Review " ++ directory ++ "/index.html and reporte_validacion.txt.") >> exitFailure
        Right True -> putStrLn ("Pipeline complete. Open " ++ directory ++ "/index.html")
