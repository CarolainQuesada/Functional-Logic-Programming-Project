module Main (main) where

import Control.Exception (IOException, try)
import Control.Monad (forM_, unless)
import qualified Data.ByteString as Bytes
import Data.List (isInfixOf)
import Pipeline (runPipeline)
import System.Directory (doesFileExist)
import System.Exit (exitFailure)
import System.FilePath ((</>))
import System.IO (IOMode (ReadMode, WriteMode), hGetContents, hPutStr, hSetEncoding, utf8, withFile)

main :: IO ()
main = do
  let directory = "output" </> "pipeline-checks"
  valid <- runPipeline "input/problema.txt" directory
  check "Primary pipeline succeeds" valid
  forM_ ["conocimiento.pl","consultas.pl","index.html","reporte_validacion.txt"] $ \file ->
    doesFileExist (directory </> file) >>= check ("Output exists: " ++ file)
  primary <- readUtf8 (directory </> "conocimiento.pl")
  check "Primary knowledge reflects the input" ("person('Alice')." `isInfixOf` primary)
  alternate <- runPipeline "test/fixtures/alternate-valid.txt" directory
  changed <- readUtf8 (directory </> "conocimiento.pl")
  changedHtml <- readUtf8 (directory </> "index.html")
  check "Second input regenerates knowledge and HTML" (alternate && "'Casey'" `isInfixOf` changed
    && not ("'Alice'" `isInfixOf` changed) && "Casey" `isInfixOf` changedHtml && not ("Alice" `isInfixOf` changedHtml))
  forM_ ["duplicate-entity.txt","undeclared-reference.txt","malformed-records.txt","missing-section.txt","unsupported-rule.txt"] $ \file -> do
    _ <- runPipeline "input/problema.txt" directory
    status <- runPipeline ("test/fixtures" </> file) directory
    knowledge <- readUtf8 (directory </> "conocimiento.pl")
    queries <- readUtf8 (directory </> "consultas.pl")
    html <- readUtf8 (directory </> "index.html")
    report <- readUtf8 (directory </> "reporte_validacion.txt")
    check ("Invalid input replaces all old results: " ++ file)
      (not status && knowledge == blocked && queries == blocked && "Validation failed" `isInfixOf` html
        && not ("href=\"conocimiento.pl\"" `isInfixOf` html) && "Status: INVALID" `isInfixOf` report)
  missing <- runPipeline (directory </> "does-not-exist.txt") directory
  missingReport <- readUtf8 (directory </> "reporte_validacion.txt")
  check "Missing input produces current diagnostics without cascading sections" (not missing
    && "InputFailure" `isInfixOf` missingReport && not ("MissingSection" `isInfixOf` missingReport))
  let encodedInput = directory </> "invalid-encoding.txt"
  Bytes.writeFile encodedInput (Bytes.pack [255,254,255])
  encoded <- runPipeline encodedInput directory
  encodedReport <- readUtf8 (directory </> "reporte_validacion.txt")
  check "Invalid UTF-8 cannot leave old executable output" (not encoded && "InputFailure" `isInfixOf` encodedReport)
  let warningInput = directory </> "warnings.txt"
  writeUtf8 warningInput "[ENTIDADES]\nperson: Alice\ncourse: Logic\n[RELACIONES]\nenrolled: Alice, Logic\nenrolled: Alice, Logic\n[REGLAS_SOLICITADAS]\nclassmates\nclassmates"
  warning <- runPipeline warningInput directory
  warningReport <- readUtf8 (directory </> "reporte_validacion.txt")
  check "Warnings allow regeneration" (warning && "Status: VALID WITH WARNINGS" `isInfixOf` warningReport)
  let bomInput = directory </> "bom-crlf.txt"
  Bytes.writeFile bomInput (Bytes.pack ([239,187,191] ++ map (fromIntegral . fromEnum)
    "[ENTIDADES]\r\nperson: Casey\r\n[RELACIONES]\r\n[REGLAS_SOLICITADAS]\r\n"))
  bom <- runPipeline bomInput directory
  check "Actual UTF-8 BOM and CRLF file is accepted" bom
  let hostileInput = directory </> "hostile.txt"
  writeUtf8 hostileInput "[ENTIDADES]\n<script>alert(1)</script>\n[RELACIONES]\n[REGLAS_SOLICITADAS]"
  _ <- runPipeline hostileInput directory
  hostileHtml <- readUtf8 (directory </> "index.html")
  check "Diagnostic HTML is escaped end to end" ("&lt;script&gt;" `isInfixOf` hostileHtml && not ("<script>" `isInfixOf` hostileHtml))
  _ <- runPipeline "input/problema.txt" directory
  before <- readUtf8 (directory </> "conocimiento.pl")
  aliasResult <- try (runPipeline (directory </> "." </> "conocimiento.pl") directory) :: IO (Either IOException Bool)
  after <- readUtf8 (directory </> "conocimiento.pl")
  check "Input/output path alias is rejected without writes" (case aliasResult of Left _ -> before == after; Right _ -> False)
  recovered <- runPipeline "input/problema.txt" directory
  recoveryHtml <- readUtf8 (directory </> "index.html")
  check "Valid input recovers after invalid generations" (recovered && "Validation passed" `isInfixOf` recoveryHtml)
  putStrLn "All 19 pipeline checks passed."
  where
    blocked = "% Generation blocked. This input has errors; see reporte_validacion.txt.\n"

check :: String -> Bool -> IO ()
check label condition = unless condition (putStrLn ("FAIL: " ++ label) >> exitFailure)

readUtf8 :: FilePath -> IO String
readUtf8 path = withFile path ReadMode $ \handle -> do
  hSetEncoding handle utf8
  contents <- hGetContents handle
  length contents `seq` pure contents

writeUtf8 :: FilePath -> String -> IO ()
writeUtf8 path contents = withFile path WriteMode $ \handle -> do
  hSetEncoding handle utf8
  hPutStr handle contents
