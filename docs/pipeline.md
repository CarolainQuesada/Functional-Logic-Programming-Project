# Complete pipeline

Run `runghc -Wall -Werror -isrc app/Main.hs` from the repository root, or build the `knowledge-pipeline` executable with Cabal. Optional arguments are the input file and output directory. The directory is created when needed.

`Pipeline.runPipeline` checks input/output path aliases, invalidates previous outputs, reads UTF-8 input, parses and validates the model, renders all results in memory, and publishes knowledge, queries, the validation report, and finally the HTML interface. File writes use a temporary file in the destination directory followed by a rename, so each individual published file is complete.

On malformed or semantically invalid input, both Prolog files become comment-only blocked markers. The HTML shows current errors and hides knowledge downloads. Missing/unreadable input and invalid UTF-8 become file-level `InputFailure` diagnostics without inventing missing-section errors. Warning-only input still generates executable knowledge. A later valid input replaces the invalid results normally.

The command exits 0 on success and 1 for invalid input, usage errors, or output IO failures. Invalid input still produces the HTML and report. There is no browser-side inference; run logical queries in SWI-Prolog.

Publication is atomic per file, not a filesystem-wide transaction. Run one pipeline process per output directory. Disk errors, permission failures, or process interruption can prevent final publication; the command must finish successfully before results are used. Output invalidation reduces stale-result risk but cannot guarantee writes to an inaccessible disk. Permission-related rename errors are retried for at most 800ms to tolerate temporary Windows file locks, then propagated if they persist. A failed rename can leave an ignored temporary file in the output directory; the pipeline does not delete files.

The 19 integration checks exercise output creation, both valid inputs, regeneration in the same directory, every invalid fixture after valid output, missing input, actual invalid UTF-8, warning-only input, BOM/CRLF, HTML escaping, input/output alias rejection, and recovery after errors.
