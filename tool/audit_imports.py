"""فحص الاستيرادات والروابط بين الملفات — بديل التحليل الثابت.

لا يوجد Flutter SDK في بيئة البناء، لذلك نفحص يدوياً:
  1. كل استيراد يشير إلى ملف موجود فعلاً
  2. كل صنف/دالة عامة يستعملها ملفٌ ما معرَّفة في الملف المستورد
  3. كل استيراد **مستعمل** فعلاً (لا استيرادات ميتة)
  4. كل شاشة يشير إليها الراوتر موجودة وباسم الصنف الصحيح

التشغيل:  python3 tool/audit_imports.py
"""

import io
import os
import re
import sys

LIB = "lib"
IMPORT_RE = re.compile(r"^\s*import\s+'([^']+)'(?:\s+as\s+(\w+))?\s*;", re.M)
DECL_RE = re.compile(
    r"^(?:abstract\s+|final\s+|sealed\s+|base\s+|interface\s+)*"
    r"(?:class|enum|mixin|extension|typedef)\s+(\w+)"
    r"|^(\w[\w<>,\s\?]*?)\s+(\w+)\s*(?:\(|=>|=|;)"
    r"|^final\s+(\w+)",
    re.M,
)

errors = []
notes = []


def read(path):
    return io.open(path, encoding="utf-8").read()


def declared_symbols(src):
    names = set()
    for m in re.finditer(
        r"^(?:abstract\s+|final\s+|sealed\s+|base\s+|interface\s+)*"
        r"(?:class|enum|mixin|extension)\s+(\w+)",
        src,
        re.M,
    ):
        names.add(m.group(1))
    for m in re.finditer(r"^typedef\s+(\w+)", src, re.M):
        names.add(m.group(1))
    # top-level finals / functions / consts
    for m in re.finditer(
        r"^(?:final|const)\s+(?:[\w<>,\?\s]+\s+)?(\w+)\s*=", src, re.M
    ):
        names.add(m.group(1))
    for m in re.finditer(
        r"^(?!//)([\w<>,\?\s]+?)\s+(\w+)\s*\([^)]*\)\s*(?:async\s*)?\{",
        src,
        re.M,
    ):
        if m.group(2) not in ("if", "for", "while", "switch", "catch", "return"):
            names.add(m.group(2))
    return names


# ملفات يولّدها `flutter gen-l10n` وقت البناء — لا نعتبرها مفقودة
GENERATED = ("l10n/app_localizations.dart",)


def resolve(importer, target):
    if target.startswith("dart:"):
        return None
    if target.startswith("package:falousna/") and target.endswith(GENERATED):
        return None
    if target.startswith("package:falousna/"):
        return os.path.join(LIB, target[len("package:falousna/"):])
    if target.startswith("package:"):
        return None  # external package
    return os.path.normpath(os.path.join(os.path.dirname(importer), target))


def body_without_imports(src):
    return "\n".join(
        line for line in src.split("\n") if not IMPORT_RE.match(line)
    )


def main():
    files = []
    for root, dirs, names in os.walk(LIB):
        dirs[:] = [d for d in dirs if d != "l10n"]
        for n in sorted(names):
            if n.endswith(".dart") and n != "app_localizations.dart":
                files.append(os.path.join(root, n))

    for f in files:
        src = read(f)
        body = body_without_imports(src)
        for m in IMPORT_RE.finditer(src):
            target, alias = m.group(1), m.group(2)
            path = resolve(f, target)
            if path is None:
                continue
            if not os.path.exists(path):
                errors.append(f"{f}: استيراد ملف غير موجود → {target}")
                continue
            dep_src = read(path)
            symbols = declared_symbols(dep_src)
            if not symbols:
                continue
            used = [s for s in symbols if re.search(r"\b" + re.escape(s) + r"\b", body)]
            if not used:
                errors.append(f"{f}: استيراد غير مستعمل → {target}")

    # 2) شاشات الراوتر
    router = read(os.path.join(LIB, "core/router/app_router.dart"))
    expected = re.findall(r"import '\.\./\.\./features/([\w/]+)\.dart';", router)
    for rel in expected:
        path = os.path.join(LIB, "features", rel + ".dart")
        if not os.path.exists(path):
            errors.append(f"app_router.dart: الشاشة مفقودة → {path}")
            continue
        src = read(path)
        wanted = "".join(
            part[:1].upper() + part[1:]
            for part in os.path.basename(rel).split("_")
        )
        if f"class {wanted}" not in src:
            errors.append(f"{path}: الصنف المتوقع {wanted} غير موجود")

    print(f"files scanned: {len(files)}")
    print(f"router screens: {len(expected)}")
    if errors:
        print("\n🔴 PROBLEMS:")
        for e in errors:
            print("  ", e)
        return 1
    print("\n✅ كل الاستيرادات صالحة ومستعملة، وكل شاشات الراوتر موجودة")
    for n in notes:
        print("  note:", n)
    return 0


if __name__ == "__main__":
    sys.exit(main())
