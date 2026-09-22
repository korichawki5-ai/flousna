"""محاكاة اختبار حظر الأسماء بلغة Python — للتحقق قبل `flutter test`.

يقرأ قائمتي الأسماء من lib/core/config/forbidden_brands.dart نفسه
(حتى لا تتباعد النسخة)، ثم يفحص كل محتوى يُشحن فعلياً.

التشغيل:  python3 tool/check_brands.py
"""

import io
import os
import re
import sys
import unicodedata

SRC = "lib/core/config/forbidden_brands.dart"

# ── استخراج القائمتين من ملف Dart ──
src = io.open(SRC, encoding="utf-8").read()


def extract_list(name):
    m = re.search(name + r"\s*=\s*<String>\[(.*?)\];", src, re.S)
    assert m, name
    return re.findall(r"'([^']+)'", m.group(1))


LATIN = extract_list("forbiddenLatin")
ARABIC = extract_list("forbiddenArabic")


def normalize(text):
    out = unicodedata.normalize("NFC", text).lower().strip()
    # إزالة التشكيل العربي والتطويل وهمزة الوصل
    out = re.sub(r"[\u064B-\u0652\u0640\u0670]", "", out)
    # توحيد أشكال الألف
    out = re.sub(r"[\u0622\u0623\u0625\u0671]", "\u0627", out)
    out = out.replace("\u0649", "\u064a")
    out = out.replace("\u0629", "\u0647")
    out = re.sub(r"\s+", " ", out)
    return out


def scan(text):
    norm = normalize(text)
    found = []
    for brand in LATIN:
        needle = normalize(brand)
        if re.search(r"(?<![a-z0-9])" + re.escape(needle) + r"(?![a-z0-9])", norm):
            found.append(brand)
    for brand in ARABIC:
        needle = normalize(brand)
        if len(needle) >= 3 and needle in norm:
            found.append(brand)
    return found


TARGET_DIRS = [("lib", (".dart", ".arb")), ("assets/seed", (".json",))]
TARGET_FILES = ["pubspec.yaml", "README_AR.md", ".env.example"]
EXEMPT = {"lib/core/config/forbidden_brands.dart"}

violations = []
scanned = 0

for folder, exts in TARGET_DIRS:
    for root, dirs, files in os.walk(folder):
        for fn in sorted(files):
            path = os.path.join(root, fn).replace("\\", "/")
            if not path.endswith(exts):
                continue
            if path in EXEMPT:
                continue
            scanned += 1
            hits = scan(io.open(path, encoding="utf-8").read())
            if hits:
                violations.append(f"{path} → {sorted(set(hits))}")

for path in TARGET_FILES:
    if not os.path.exists(path):
        continue
    scanned += 1
    hits = scan(io.open(path, encoding="utf-8").read())
    if hits:
        violations.append(f"{path} → {sorted(set(hits))}")

# ── فحص تسلّل حروف غير عربية/لاتينية (صينية/يابانية/كورية) ──
cjk = re.compile(r"[\u4e00-\u9fff\u3040-\u30ff\uac00-\ud7af]")
cjk_hits = []
for root, dirs, files in os.walk("."):
    dirs[:] = [d for d in dirs if d not in (".git", "build", ".dart_tool", "tool")]
    for fn in sorted(files):
        if not fn.endswith((".dart", ".md", ".arb", ".json", ".yaml", ".example")):
            continue
        path = os.path.join(root, fn).replace("\\", "/")
        for i, line in enumerate(
            io.open(path, encoding="utf-8", errors="ignore").read().split("\n"), 1
        ):
            if cjk.search(line):
                cjk_hits.append(f"{path}:{i} → {line.strip()[:80]}")

print(f"files scanned: {scanned}")
print(f"latin terms: {len(LATIN)} | arabic terms: {len(ARABIC)}")

ok = True
if violations:
    ok = False
    print("\n🔴 أسماء محظورة في المحتوى المشحون:")
    for v in violations:
        print("  ", v)
else:
    print("\n✅ المحتوى المشحون نظيف تماماً من أسماء المؤسسات")

if cjk_hits:
    ok = False
    print("\n🔴 حروف غير عربية/لاتينية متسللة:")
    for h in cjk_hits:
        print("  ", h)
else:
    print("✅ لا حروف متسللة (صينية/يابانية/كورية)")

sys.exit(0 if ok else 1)
