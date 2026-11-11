"""Regression checks for submission exclusions using only Python's standard library."""
import importlib.util
from pathlib import Path
import tempfile
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("package_submission", ROOT / "tools/package_submission.py")
package = importlib.util.module_from_spec(spec)
spec.loader.exec_module(package)

with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    names = ["src/Keep.hs", "dist-newstyle/cache.txt", ".git/config", "tools/__pycache__/cache.pyc", "output/submission.zip"]
    for name in names:
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("fixture", encoding="utf-8")
    listing = ("\0".join(names) + "\0").encode("utf-8")
    with patch.object(package, "ROOT", root), patch.object(package.subprocess, "check_output", return_value=listing):
        collected = {path.relative_to(root).as_posix() for path in package.collect_files()}
    assert "src/Keep.hs" in collected
    assert not set(names[1:]).intersection(collected), collected
print("Submission exclusion regression passed.")
