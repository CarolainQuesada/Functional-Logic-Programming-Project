module Main (main) where

import Control.Monad (forM_, unless)
import Data.List (isInfixOf)
import Html
import Input (readProblem)
import Parser (parseProblem)
import System.Exit (exitFailure)

main :: IO ()
main = do
  primary <- renderHtml "problema.txt" <$> readProblem "input/problema.txt"
  alternate <- renderHtml "alternate.txt" <$> readProblem "test/fixtures/alternate-valid.txt"
  invalid <- renderHtml "invalid.txt" <$> readProblem "test/fixtures/duplicate-entity.txt"
  let hostile = renderHtml "<script>alert(1)</script>" (parseProblem "<script>alert(1)</script>")
      empty = renderHtml "empty.txt" (parseProblem "[ENTIDADES]\n[RELACIONES]\n[REGLAS_SOLICITADAS]")
      warning = renderHtml "warning.txt" (parseProblem "[ENTIDADES]\nperson: Alice\n[RELACIONES]\n[REGLAS_SOLICITADAS]\nclassmates\nclassmates")
      checks =
        [ ("English accessible document", all (`isInfixOf` primary) ["<!doctype html>","lang=\"en\"","name=\"viewport\"","Skip to content","scope=\"col\""])
        , ("Every required section exists", all (`isInfixOf` primary) ["id=\"entities\"","id=\"relations\"","id=\"rules\"","id=\"knowledge\"","id=\"queries\"","id=\"validation\""])
        , ("Input entities are rendered", all (`isInfixOf` primary) ["Alice","Bob","ProgrammingParadigms","Morgan"])
        , ("Generated facts are shown", "person(&#39;Alice&#39;)." `isInfixOf` primary)
        , ("Generated rule definitions are shown", "classmate(First, Second) :-" `isInfixOf` primary)
        , ("Suggested queries are shown", "suggested_query(classmate(_First, _Second))." `isInfixOf` primary)
        , ("Traceability is visible", "Source line 8:" `isInfixOf` primary)
        , ("Alternate data replaces primary names", "Casey" `isInfixOf` alternate && not ("Alice" `isInfixOf` alternate))
        , ("Valid input has success status", "Validation passed" `isInfixOf` primary)
        , ("Invalid input blocks knowledge", "Generation is blocked" `isInfixOf` invalid && not ("person(&#39;Alice&#39;)." `isInfixOf` invalid))
        , ("Invalid input shows related source", all (`isInfixOf` invalid) ["DuplicateEntity","Related line 2","Validation failed"])
        , ("Invalid input hides knowledge download", not ("href=\"conocimiento.pl\"" `isInfixOf` invalid))
        , ("Names and raw lines cannot inject HTML", not ("<script>" `isInfixOf` hostile) && "&lt;script&gt;" `isInfixOf` hostile)
        , ("All HTML special characters are escaped", escapeHtml "<&>\"'" == "&lt;&amp;&gt;&quot;&#39;")
        , ("Empty data has an explicit empty state", "No records in this section." `isInfixOf` empty)
        , ("Warnings preserve valid output", "Valid with warnings" `isInfixOf` warning && "href=\"conocimiento.pl\"" `isInfixOf` warning)
        , ("Responsive layout is included", "@media(max-width:760px)" `isInfixOf` primary)
        , ("No external network resources", not ("https://" `isInfixOf` primary) && not ("<script" `isInfixOf` primary))
        ]
  forM_ checks $ \(label, ok) -> unless ok (putStrLn ("FAIL: " ++ label) >> exitFailure)
  putStrLn ("All " ++ show (length checks) ++ " HTML checks passed.")
