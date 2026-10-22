module PrologFiles (writePrologFiles) where

import Prolog (PrologOutput (..))
import System.FilePath ((</>))
import System.IO (IOMode (WriteMode), hPutStr, hSetEncoding, utf8, withFile)

-- | Write generated files to an existing directory without invoking Prolog.
writePrologFiles :: FilePath -> PrologOutput -> IO ()
writePrologFiles directory output = do
  writeUtf8 (directory </> "conocimiento.pl") (knowledgeText output)
  writeUtf8 (directory </> "consultas.pl") (queriesText output)

writeUtf8 :: FilePath -> String -> IO ()
writeUtf8 path contents = withFile path WriteMode $ \handle -> do
  hSetEncoding handle utf8
  hPutStr handle contents
