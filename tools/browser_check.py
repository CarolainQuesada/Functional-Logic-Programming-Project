"""Run the dependency-free Node/Chrome browser verification."""
from pathlib import Path
import subprocess
import sys

if __name__ == "__main__":
    script = Path(__file__).with_suffix(".mjs")
    raise SystemExit(subprocess.call(["node", str(script), *sys.argv[1:]]))
