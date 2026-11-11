"""Verify current artifacts and package tracked and nonignored new source files."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
ARTIFACTS = ("conocimiento.pl", "consultas.pl", "index.html", "reporte_validacion.txt")


def verify_outputs():
    """Compare published artifacts with a fresh run of the current primary input."""
    with tempfile.TemporaryDirectory(prefix="knowledge-package-") as temporary:
        subprocess.run(["runghc", "-Wall", "-Werror", "-isrc", "app/Main.hs",
                        "input/problema.txt", temporary], cwd=ROOT, check=True)
        for name in ARTIFACTS:
            published = ROOT / "output" / name
            if not published.is_file() or published.read_bytes() != (Path(temporary) / name).read_bytes():
                raise RuntimeError(f"Missing or stale output/{name}; run tools/prepare_submission.py first.")


def collect_files():
    """Include nonignored source, current documentation, and named evidence folders."""
    listing = subprocess.check_output(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=ROOT)
    files = {ROOT / name for name in listing.decode("utf-8").split("\0") if name}
    missing = [path for path in files if not path.is_file()]
    if missing:
        raise RuntimeError(f"Tracked file is missing; review the working tree: {missing[0]}")
    files.update(ROOT / "output" / name for name in ARTIFACTS)
    files.add(ROOT / "docs" / "api" / "haskell-api.dox")
    files.update(path for path in (ROOT / "docs" / "html").rglob("*") if path.is_file())
    for directory in ("browser-checks", "browser-alternate", "browser-invalid", "browser-assignment",
                      "defense-alternate", "assignment-example", "invalid-example"):
        files.update(path for path in (ROOT / "output" / directory).rglob("*")
                     if path.is_file() and path.suffix in {".png", ".json", ".html", ".pl", ".txt"})
    return sorted(path for path in files
                  if path != ROOT / "output" / "submission.zip"
                  if not {"dist-newstyle", ".git", "__pycache__"}.intersection(path.relative_to(ROOT).parts))


def main():
    verify_outputs()
    subprocess.run([sys.executable, "tools/build_docs.py"], cwd=ROOT, check=True)
    files = collect_files()
    manifest = {path.relative_to(ROOT).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
                for path in files}
    destination = ROOT / "output" / "submission.zip"
    temporary = destination.with_suffix(".zip.tmp")
    try:
        with zipfile.ZipFile(temporary, "w", zipfile.ZIP_DEFLATED) as archive:
            for path in files:
                archive.write(path, path.relative_to(ROOT).as_posix())
            archive.writestr("submission-manifest.json", json.dumps(manifest, indent=2) + "\n")
        with zipfile.ZipFile(temporary) as archive:
            if archive.testzip() is not None:
                raise RuntimeError("Archive integrity check failed.")
            for name, digest in manifest.items():
                if hashlib.sha256(archive.read(name)).hexdigest() != digest:
                    raise RuntimeError(f"Archive content mismatch: {name}")
        temporary.replace(destination)
    finally:
        temporary.unlink(missing_ok=True)
    print(f"Submission archive verified: output/submission.zip ({len(files)} files plus SHA-256 manifest).")


if __name__ == "__main__":
    main()
