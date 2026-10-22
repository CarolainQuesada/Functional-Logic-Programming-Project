$ErrorActionPreference = 'Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    foreach ($suite in @('ModelTest', 'ParserTest', 'ValidationTest', 'PrologTest', 'HtmlTest', 'PipelineTest')) {
        & runghc -Wall -Werror -isrc "test/$suite.hs"
        if ($LASTEXITCODE -ne 0) { throw "Test suite failed: $suite" }
    }
    & runghc -Wall -Werror -isrc app/Main.hs
    if ($LASTEXITCODE -ne 0) { throw 'Primary pipeline generation failed.' }
    Write-Output 'All Haskell, SWI-Prolog, and integration checks passed.'
} finally {
    Pop-Location
}
