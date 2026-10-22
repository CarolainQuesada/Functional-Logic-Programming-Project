"""Package tracked source plus regenerated deliverables without Git metadata."""

from pathlib import Path
import subprocess
import zipfile


ROOT = Path(__file__).resolve().parents[1]


def main():
    required = [ROOT / "output" / name for name in
                ("conocimiento.pl", "consultas.pl", "index.html", "reporte_validacion.txt")]
    required += [ROOT / "docs" / "html" / "index.html", ROOT / "docs" / "api" / "haskell-api.dox"]
    for path in required:
        if not path.is_file():
            raise RuntimeError(f"Missing deliverable; regenerate first: {path.relative_to(ROOT)}")
    report = (ROOT / "output" / "reporte_validacion.txt").read_text(encoding="utf-8")
    if "Status: VALID" not in report:
        raise RuntimeError("Generate a valid primary input before packaging the final submission.")
    tracked = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT)
    files = {ROOT / name for name in tracked.decode("utf-8").split("\0") if name}
    files.update(required)
    files.update(path for path in (ROOT / "docs" / "html").rglob("*") if path.is_file())
    for directory in ("browser-checks", "browser-alternate", "browser-invalid", "defense-alternate", "invalid-example"):
        files.update(path for path in (ROOT / "output" / directory).rglob("*")
                     if path.is_file() and path.suffix in {".png", ".json", ".html", ".pl", ".txt"})
    destination = ROOT / "output" / "submission.zip"
    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(files):
            if path.is_file():
                archive.write(path, path.relative_to(ROOT).as_posix())
    with zipfile.ZipFile(destination) as archive:
        assert archive.testzip() is None, "Archive integrity check failed."
        assert "app/Main.hs" in archive.namelist()
        assert "output/index.html" in archive.namelist()
        count = len(archive.namelist())
    print(f"Submission archive verified: output/submission.zip ({count} files).")


if __name__ == "__main__":
    main()
