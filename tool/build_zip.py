"""يبني حزمة التوزيع falousna-phaseN.zip من المصدر بلا مخلفات بناء.

القاعدة: نُضمّن ما يلزم للبناء على جهاز المستخدم فقط —
    lib/ · test/ · tool/ · docs/ · assets/ + ملفات الإعداد في الجذر.
ونستثني: build/ · .dart_tool/ · المنصّات (android/windows تُنشأ بـ
`flutter create` على جهازه) · ملفات النظام والكاش.

التشغيل: python3 tool/build_zip.py <اسم-الحزمة.zip>
"""

import os
import sys
import zipfile

ROOT_FILES = (
    ".env.example",
    ".gitignore",
    "README_AR.md",
    "analysis_options.yaml",
    "l10n.yaml",
    "pubspec.yaml",
    "pubspec.lock",
)
TREES = ("assets", "docs", "lib", "test", "tool")
SKIP_DIRS = {"build", ".dart_tool", ".git", "__pycache__", ".dartServer"}
SKIP_EXTS = (".pyc", ".iml", ".log")


def _files():
    for name in ROOT_FILES:
        if os.path.isfile(name):
            yield name
    for tree in TREES:
        for dirpath, dirnames, filenames in os.walk(tree):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
            for fn in sorted(filenames):
                if fn.endswith(SKIP_EXTS) or fn == "l10n_missing.txt":
                    continue
                yield os.path.join(dirpath, fn).replace("\\", "/")


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "falousna-phase1.zip"
    items = sorted(_files())
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for rel in items:
            zf.write(rel, "falousna/" + rel)
    size_mb = os.path.getsize(out) / (1024 * 1024)
    print("✅ %s — %d ملف، %.2f ميغابايت" % (out, len(items), size_mb))
    return 0


if __name__ == "__main__":
    sys.exit(main())
