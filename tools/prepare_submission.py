"""Run verification and delivery preparation; stop on unexpected failure."""
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def run(*arguments, expected=0):
    """Run from the repository root and enforce the expected exit status."""
    result = subprocess.run(arguments, cwd=ROOT)
    if result.returncode != expected:
        raise RuntimeError(f"Expected exit {expected}, got {result.returncode}: {arguments}")


def main():
    for suite in ("ModelTest", "ParserTest", "ValidationTest", "PrologTest", "HtmlTest", "PipelineTest"):
        run("runghc", "-Wall", "-Werror", "-isrc", f"test/{suite}.hs")
    run("runghc", "-Wall", "-Werror", "-isrc", "app/Main.hs")
    scenarios = (
        ("input/problema.txt", "output", "browser-checks", 0),
        ("test/fixtures/alternate-valid.txt", "output/defense-alternate", "browser-alternate", 0),
        ("test/fixtures/assignment-valid.txt", "output/assignment-example", "browser-assignment", 0),
        ("test/fixtures/duplicate-entity.txt", "output/invalid-example", "browser-invalid", 1),
    )
    for source, directory, evidence, status in scenarios:
        if directory != "output":
            run("runghc", "-Wall", "-Werror", "-isrc", "app/Main.hs", source, directory, expected=status)
        run("node", "tools/browser_check.mjs", f"{directory}/index.html", f"output/{evidence}")
    run(sys.executable, "tools/package_submission.py")
    print("All checks passed. Delivery ready: output/submission.zip", flush=True)


if __name__ == "__main__":
    main()
