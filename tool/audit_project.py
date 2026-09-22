"""فحص بنيوي شامل — بديل جزئي للمحلّل (لا Flutter SDK في بيئة البناء).

يفحص كل ملفات lib/ و test/:
  1. توازن الأقواس بعد إزالة التعليقات والسلاسل النصية
  2. لا TODO / FIXME / نقاط حشو
  3. نهاية ملف بسطر جديد
  4. لا print() — المعتمد debugPrint
  5. لا EdgeInsets.left/right — المطلوب EdgeInsetsDirectional (RTL)
  6. لا نصوص عربية مكتوبة يدوياً في الواجهة (يجب أن تأتي من .arb)
  7. مواضع DateTime.now() — المنطق الزمني يجب أن يمرّ عبر ClockGuard
  8. استيرادات test/ صالحة

التشغيل:  python3 tool/audit_project.py
"""

import io
import os
import re
import sys

problems = []
warnings = []

ARABIC = re.compile(r"[\u0600-\u06FF]")

# ملفات يُسمح فيها بنصوص عربية:
#   · ثوابت الهوية (اسم التطبيق)
#   · قائمة الحظر نفسها (تعريف الأسماء الممنوعة)
#   · أنماط المقارنة ورموز العملات
#   · أسماء اللغات بلغتها (عرف عالمي — لا تُترجم)
ARABIC_ALLOWED = {
    "lib/core/config/constants.dart",
    "lib/core/config/forbidden_brands.dart",
    "lib/core/config/app_config.dart",
    "lib/core/l10n/locale_controller.dart",
    "lib/core/utils/money.dart",
    "lib/core/utils/number_format.dart",
    "lib/core/utils/validators.dart",
    "lib/main.dart",
    "lib/data/local/local_store.dart",
    "lib/core/utils/clock_guard.dart",
    "lib/features/settings/settings_screen.dart",
    "lib/features/onboarding/onboarding_screen.dart",
}

# مواضع يُسمح فيها بـ DateTime.now() (الحارس نفسه والتخزين)
NOW_ALLOWED = {
    "lib/core/utils/clock_guard.dart",
    "lib/data/local/local_store.dart",
}


def _skip_string(src, i):
    """يعيد (موضع النهاية، النص المستهلك) لسلسلة نصية تبدأ عند i."""
    triple = src[i:i + 3]
    if triple in ("'''", '"""'):
        j = i + 3
        while j + 2 < len(src) and src[j:j + 3] != triple:
            if src[j] == "\\":
                j += 1
            j += 1
        j += 3
        return j, src[i:j]

    raw = i > 0 and src[i - 1] == "r"
    quote = src[i]
    j = i + 1
    while j < len(src) and src[j] != quote and src[j] != "\n":
        if src[j] == "\\" and not raw:
            j += 1
        j += 1
    j = min(j + 1, len(src))
    return j, src[i:j]


def strip_comments(src):
    """يزيل التعليقات فقط — يُبقي السلاسل النصية وأرقام الأسطر."""
    out = []
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            start = i
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                i += 1
            i += 2
            block = src[start:i]
            out.append("\n" * block.count("\n"))
            continue
        if c in "'\"":
            i, consumed = _skip_string(src, i)
            out.append(consumed)
            continue
        out.append(c)
        i += 1
    return "".join(out)


def strip_code(src):
    """يزيل التعليقات والسلاسل النصية — لفحص بنية الأقواس فقط."""
    out = []
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                i += 1
            i += 2
            continue
        if c in "'\"":
            i, _ = _skip_string(src, i)
            out.append('""')
            continue
        out.append(c)
        i += 1
    return "".join(out)


def check_balance(path, src):
    code = strip_code(src)
    pairs = {"(": ")", "[": "]", "{": "}"}
    stack = []
    line = 1
    for ch in code:
        if ch == "\n":
            line += 1
        elif ch in pairs:
            stack.append((ch, line))
        elif ch in (")", "]", "}"):
            if not stack:
                problems.append("%s:%d قوس إغلاق زائد «%s»" % (path, line, ch))
                return
            opener, open_line = stack.pop()
            if pairs[opener] != ch:
                problems.append(
                    "%s:%d قوس «%s» لا يطابق «%s» المفتوح في %d"
                    % (path, line, ch, opener, open_line)
                )
                return
    if stack:
        opener, open_line = stack[-1]
        problems.append("%s:%d قوس «%s» لم يُغلق" % (path, open_line, opener))


def walk(roots, exts):
    for root in roots:
        if not os.path.isdir(root):
            continue
        for dirpath, dirnames, filenames in os.walk(root):
            for fn in sorted(filenames):
                if any(fn.endswith(e) for e in exts):
                    yield os.path.join(dirpath, fn).replace("\\", "/")


def main():
    files = [
        f for f in walk(["lib", "test"], [".dart"])
        if not f.endswith("app_localizations.dart")
    ]

    for path in files:
        src = io.open(path, encoding="utf-8").read()
        norm = path.replace("\\", "/")

        check_balance(norm, src)

        if not src.endswith("\n"):
            problems.append(norm + ": لا ينتهي بسطر جديد (eol_at_end_of_file)")

        for marker in ("TODO", "FIXME"):
            if re.search(r"//.*\b" + marker + r"\b", src):
                problems.append(norm + ": يحتوي " + marker + " (ممنوع — سياسة Zero-Bugs)")

        if re.search(r"^\s*print\(", src, re.M):
            problems.append(norm + ": يستعمل print() بدل debugPrint()")

        for m in re.finditer(r"EdgeInsets\.(only|symmetric)\(([^)]*)\)", src):
            if re.search(r"\b(left|right):", m.group(2)):
                line = src[:m.start()].count("\n") + 1
                problems.append(
                    "%s:%d EdgeInsets باستعمال left/right — المطلوب EdgeInsetsDirectional (RTL)"
                    % (norm, line)
                )

        code_only = strip_comments(src)

        if norm.startswith("lib/") and norm not in ARABIC_ALLOWED:
            for m in re.finditer(r"'([^'\n]*)'", code_only):
                text = m.group(1)
                if not ARABIC.search(text):
                    continue
                line_start = code_only.rfind("\n", 0, m.start()) + 1
                line_end = code_only.find("\n", m.start())
                line_text = code_only[line_start:line_end if line_end > 0 else None]
                # رسائل المطوّر (سجلات وأخطاء داخلية) مسموحة بالعربية
                if "debugPrint" in line_text or "StateError" in line_text:
                    continue
                warnings.append(norm + ": نص عربي في الكود ← " + repr(text[:40]))

        if norm.startswith("lib/") and norm not in NOW_ALLOWED:
            for m in re.finditer(r"DateTime\.now\(\)", code_only):
                line = code_only[:m.start()].count("\n") + 1
                warnings.append(
                    "%s:%d DateTime.now() — المنطق الزمني يمرّ عبر ClockGuard" % (norm, line)
                )

    for path in walk(["test"], [".dart"]):
        src = io.open(path, encoding="utf-8").read()
        for m in re.finditer(r"^import\s+'([^']+)';", src, re.M):
            target = m.group(1)
            if target.startswith("package:falousna/"):
                rel = os.path.join("lib", target[len("package:falousna/"):])
                # الملفات المولَّدة (gen-l10n) غير موجودة قبل التوليد — ليست نقصاً
                if os.path.basename(rel).startswith("app_localizations"):
                    continue
                if not os.path.exists(rel):
                    problems.append(path + ": استيراد مفقود → " + target)

    # ── pubspec.yaml: الأصول والخطوط والحزم المعلنة ──
    #    (فشل البناء الأكثر شيوعاً: مسار أصل أو خط معلن غير موجود على القرص)
    try:
        import yaml

        spec = yaml.safe_load(io.open("pubspec.yaml", encoding="utf-8").read())
    except Exception as exc:  # noqa: BLE001 — أداة فحص لا تطبيق
        spec = None
        warnings.append("pubspec.yaml: تعذّر الفحص (%s)" % exc)

    if spec:
        flutter_section = spec.get("flutter") or {}

        # 1) مجلدات/ملفات الأصول المعلنة موجودة وغير فارغة
        for entry in flutter_section.get("assets") or []:
            path = str(entry)
            if path.endswith("/"):
                if not os.path.isdir(path):
                    problems.append("pubspec: مجلد أصول غير موجود → %s" % path)
                elif not os.listdir(path):
                    problems.append("pubspec: مجلد أصول فارغ → %s" % path)
            elif not os.path.exists(path):
                problems.append("pubspec: أصل غير موجود → %s" % path)

        # 2) كل ملف خط معلن موجود، وأوزانه صالحة وغير مكررة
        declared_weights = {}
        for family in flutter_section.get("fonts") or []:
            name = family.get("family")
            weights = []
            for entry in family.get("fonts") or []:
                asset = entry.get("asset")
                if not asset:
                    problems.append("pubspec: خط بلا مسار asset في عائلة %s" % name)
                    continue
                if not os.path.exists(asset):
                    problems.append("pubspec: ملف خط غير موجود → %s" % asset)
                    continue
                weight = entry.get("weight", 400)
                if weight not in range(100, 1000, 100):
                    problems.append(
                        "pubspec: وزن غير صالح (%s) للخط %s" % (weight, asset)
                    )
                weights.append(weight)
            if len(weights) != len(set(weights)):
                problems.append("pubspec: أوزان مكررة في عائلة %s" % name)
            declared_weights[name] = set(weights)

        # 3) الأوزان المستعملة في الكود يجب أن تكون معلنة (وإلا اختار المحرّك
        #    أقرب وزن وقد لا تظهر السماكة المطلوبة)
        used_weights = set()
        for path in files:
            if not path.startswith("lib"):
                continue  # الاختبارات لا تُشحن — لا أثر لها على الخطوط
            src = io.open(path, encoding="utf-8").read()
            for m in re.finditer(r"FontWeight\.w(\d{3})", src):
                used_weights.add(int(m.group(1)))
        primary = declared_weights.get("Cairo", set())
        if primary and not used_weights.issubset(primary):
            warnings.append(
                "pubspec: أوزان مستعملة بلا إعلان في عائلة Cairo → %s"
                % sorted(used_weights - primary)
            )

        # 4) لا حزمة معلنة بلا استعمال (تبعيات ميتة تُبطئ البناء وترفع
        #    احتمال فشل أول تشغيل)
        declared = set(spec.get("dependencies") or {})
        # كل الحزم المعلنة (تشغيل + تطوير) للتحقق من الاستيرادات
        declared_all = declared | set(spec.get("dev_dependencies") or {})
        declared -= {"flutter", "flutter_localizations"}
        imported = set()
        for path in files + list(walk(["test"], [".dart"])):
            src = io.open(path, encoding="utf-8").read()
            for m in re.finditer(r"package:([a-z0-9_]+)/", src):
                imported.add(m.group(1))
        imported.discard("falousna")
        unused = declared - imported
        if unused:
            warnings.append("pubspec: حزم معلنة غير مستعملة في الكود → %s" % sorted(unused))
        undeclared = imported - declared_all
        if undeclared:
            problems.append("pubspec: حزم مستوردة غير معلنة → %s" % sorted(undeclared))

    # ── .env.example يجب أن يوثّق كل متغيّر بناء يُقرأ في الكود ──
    #    (متغيّر غير موثّق = قيمة لن يعرف المستخدم كيف يضبطها قبل النشر)
    env_documented_only = {"SUPABASE_REGION"}  # موثّق توثيقياً ولا يُحقن
    config_path = "lib/core/config/app_config.dart"
    if os.path.exists(config_path):
        config_src = io.open(config_path, encoding="utf-8").read()
        read_keys = set(
            re.findall(r"String\.fromEnvironment\(\s*'([A-Z0-9_]+)'", config_src)
        )
        if not os.path.exists(".env.example"):
            problems.append(".env.example مفقود (توثيق متغيرات البناء)")
        else:
            env_src = io.open(".env.example", encoding="utf-8").read()
            doc_keys = set(re.findall(r"^([A-Z][A-Z0-9_]*)=", env_src, re.M))
            undocumented = read_keys - doc_keys
            if undocumented:
                problems.append(
                    ".env.example: متغيرات تُقرأ في الكود وغير موثّقة → %s"
                    % sorted(undocumented)
                )
            stale = doc_keys - read_keys - env_documented_only
            if stale:
                warnings.append(
                    ".env.example: متغيرات موثّقة لا يقرؤها الكود → %s" % sorted(stale)
                )

    print("files checked: %d" % len(files))
    if problems:
        print("\n🔴 مشاكل بنيوية:")
        for p in problems:
            print("  ", p)
    else:
        print("\n✅ لا مشاكل بنيوية (أقواس متوازنة · لا TODO · لا print · RTL سليم)")

    if warnings:
        print("\n⚠️ تنبيهات للمراجعة (%d):" % len(warnings))
        for w in warnings:
            print("  ", w)
    else:
        print("✅ لا تنبيهات: كل النصوص من .arb وكل وقت من ClockGuard")

    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
