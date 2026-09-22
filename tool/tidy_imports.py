"""أدوات صيانة الكود — ترتيب الاستيرادات وفحص القواعد.

يُستعمل من المساعد أثناء البناء (لا Flutter SDK في بيئة البناء)،
ويمكن للمطوّر تشغيله لاحقاً:

    python3 tool/tidy_imports.py
"""

import io
import os
import re
import sys

IMPORT_RE = re.compile(r"^(import|export)\s+'([^']+)'\s*(as\s+\w+\s*)?;\s*$")


def split_groups(paths):
    dart, package, relative = [], [], []
    for line in paths:
        if line.startswith("import 'dart:") or line.startswith("export 'dart:"):
            dart.append(line)
        elif "package:" in line.split("'")[1]:
            package.append(line)
        else:
            relative.append(line)
    return dart, package, relative


def tidy(path):
    src = io.open(path, encoding="utf-8").read()
    lines = src.split("\n")

    # find contiguous import block (allow blank lines/comments between)
    idx = [i for i, l in enumerate(lines) if IMPORT_RE.match(l.strip())]
    if not idx:
        return False

    first, last = idx[0], idx[-1]
    block = lines[first:last + 1]

    imports, others = [], []
    for l in block:
        if IMPORT_RE.match(l.strip()):
            imports.append(l.strip())
        elif l.strip():
            others.append(l)

    if others:
        # comments interleaved — leave file untouched (safe)
        return False

    dart, package, relative = split_groups(imports)
    dart.sort()
    package.sort()
    relative.sort()

    groups = [g for g in (dart, package, relative) if g]
    new_block = "\n\n".join("\n".join(g) for g in groups)

    new_lines = lines[:first] + new_block.split("\n") + lines[last + 1:]
    out = "\n".join(new_lines)
    if out != src:
        io.open(path, "w", encoding="utf-8").write(out)
        return True
    return False


def main():
    changed = []
    for root, dirs, files in os.walk("lib"):
        for fn in sorted(files):
            if fn.endswith(".dart"):
                p = os.path.join(root, fn)
                if tidy(p):
                    changed.append(p)
    print("reordered:", len(changed))
    for c in changed:
        print("  ", c)


if __name__ == "__main__":
    sys.exit(main())
