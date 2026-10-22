"""Extract actual Haskell declarations into Doxygen pages, then build HTML."""

from pathlib import Path
import re
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]


def declarations(lines):
    """Keep source signatures and type bodies; never execute Haskell code."""
    for index, line in enumerate(lines):
        match = re.match(r"^(?:data|newtype)\s+([A-Z]\w*)|^([a-z]\w*)\s*::", line)
        if not match:
            continue
        name = match.group(1) or match.group(2)
        body = [line]
        for following in lines[index + 1:]:
            if not following.strip() or not following.startswith((" ", "\t")):
                break
            body.append(following)
        comment = []
        previous = index - 1
        while previous >= 0 and lines[previous].startswith("--"):
            comment.insert(0, re.sub(r"^--\s*\|?\s?", "", lines[previous]))
            previous -= 1
        yield name, index + 1, "\n".join(body), " ".join(comment)


def generate_reference():
    output = ROOT / "docs" / "api"
    output.mkdir(parents=True, exist_ok=True)
    pages = []
    for source in sorted((ROOT / "src").glob("*.hs")) + sorted((ROOT / "app").glob("*.hs")):
        text = source.read_text(encoding="utf-8-sig")
        module = re.search(r"^module\s+([\w.]+)", text, re.MULTILINE).group(1)
        identifier = (source.parent.name + "_" + source.stem).replace(".", "_")
        page = [f"/** @page api_{identifier} {source.parent.name}/{source.name}",
                f"Haskell module `{module}`. Declarations below are extracted from the actual source."]
        for name, line, signature, description in declarations(text.splitlines()):
            page += [f"@section api_{identifier}_{name} {name}",
                     description or f"Declaration in the {module} module.",
                     f"Source: `{source.relative_to(ROOT).as_posix()}:{line}`.",
                     "@code", signature.replace("*/", "* /"), "@endcode"]
        pages.append("\n".join(page + ["*/"]))
    (output / "haskell-api.dox").write_text("\n\n".join(pages), encoding="utf-8")
    print(f"Extracted declarations from {len(pages)} Haskell modules.", flush=True)


def main():
    generate_reference()
    if "--extract-only" not in sys.argv:
        subprocess.run(["doxygen", "docs/Doxyfile"], cwd=ROOT, check=True)
        assert (ROOT / "docs" / "html" / "index.html").is_file()
        print("Doxygen documentation generated at docs/html/index.html.")


if __name__ == "__main__":
    main()
