"""فحص ملفات الترجمة (ar.arb · fr.arb) — بوابة الجودة قبل `flutter gen-l10n`.

لماذا: فشل gen-l10n أو نقص ترجمة يظهر للمستخدم كنص مفقود أو بناء متوقف،
وكلاهما يكلّف وقتاً. هذا الفحص يلتقطه في ثوانٍ.

يفحص:
  1. تطابق المفاتيح بين اللغتين (لا مفتاح في لغة دون الأخرى)
  2. كل مفتاح له قيمة غير فارغة
  3. لا مفاتيح مكررة في الملف الخام (JSON يبتلع التكرار بصمت!)
  4. المتغيّرات {placeholder} متطابقة بين اللغتين ومُعلَنة في @metadata القالب
  5. صيغة ICU (plural/select): أقواس متوازنة + فئة `other` موجودة
     (بمحلّل أقواس حقيقي: كلمات الفروع مثل «و» و«et» ليست متغيّرات)
     + فئات الجمع العربية صحيحة (zero/one/two/few/many/other)
  6. كل مفتاح مستعمل في الكود موجود فعلاً في ar.arb
  7. المفاتيح المعلنة غير المستعملة ← تقرير معلوماتي (احتياطي المراحل القادمة)

التشغيل: python3 tool/check_l10n.py
"""

import io
import json
import os
import re
import sys

TEMPLATE = "lib/l10n/ar.arb"  # القالب حسب l10n.yaml → template-arb-file
OTHER = "lib/l10n/fr.arb"

# فئات الجمع المعتمدة في العربية (CLDR)
AR_PLURAL_CATEGORIES = {"zero", "one", "two", "few", "many", "other"}
SELECTORS = re.compile(r"([A-Za-z_]\w*)\s*,\s*(plural|select)\s*,")
PLACEHOLDER = re.compile(r"\{([A-Za-z_][A-Za-z0-9_]*)")
# المفتاح المستعمل في الكود: l10n.keyName / AppLocalizations.of(context).keyName
USAGE = re.compile(r"(?:\bl10n|\blocalizations|\bAppLocalizations\.of\([^)]*\))\.(\w+)")


def _match_brace(text, open_idx):
    """موضع القوس المُغلق المطابق للقوس المفتوح عند open_idx (أو نهاية النص)."""
    depth = 0
    for i in range(open_idx, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return i
    return len(text) - 1


def _scan_placeholders(value):
    """متغيّرات ICU الحقيقية — يتجاهل كلمات الفروع مثل «و» و«et».

    ⚠️ درس (22/09/2026): البحث بتعبير نمطي عن `{كلمة` كان يعتبر
    `few{و{count} …}` متغيّراً اسمه «و»، و`other{et {count} …}` متغيّراً
    اسمه «et». فكانت البوابة ترفض ترجمات سليمة تماماً. الحل: تحليل
    أقواس متوازن يفهم بنية ICU فعلية.
    """
    found = set()
    i = 0
    while i < len(value):
        if value[i] != "{":
            i += 1
            continue
        close = _match_brace(value, i)
        inner = value[i + 1:close]
        selector = re.match(r"\s*([A-Za-z_]\w*)\s*,\s*(plural|select)\s*,(.*)$", inner, re.S)
        if selector:
            found.add(selector.group(1))
            found |= _branch_placeholders(selector.group(3))
        else:
            name = re.match(r"\s*([A-Za-z_]\w*)", inner)
            if name:
                found.add(name.group(1))
        i = close + 1
    return found


def _iter_branches(body):
    """يُمرّر (اسم الفئة، موضع القوس المفتوح، موضع القوس المُغلق) لكل فرع."""
    i = 0
    while i < len(body):
        head = re.match(r"\s*(=\d+|[a-z]+)\s*\{", body[i:])
        if not head:
            i += 1
            continue
        brace = i + head.end() - 1
        close = _match_brace(body, brace)
        yield head.group(1), brace, close
        i = close + 1


def _branch_placeholders(body):
    out = set()
    for _name, brace, close in _iter_branches(body):
        out |= _scan_placeholders(body[brace + 1:close])
    return out


def plural_categories(body):
    """فئات الجمع في المستوى الأعلى فقط — لا تُقرأ عبارات داخل الفروع."""
    return [name for name, _brace, _close in _iter_branches(body)]


def load(path):
    return json.load(io.open(path, encoding="utf-8"))


def keys_of(data):
    return [k for k in data if not k.startswith("@")]


def duplicates(path):
    """المفاتيح المكررة في الملف الخام — JSON لا يشتكي منها لكن gen-l10n يأخذ الأخير."""
    text = io.open(path, encoding="utf-8").read()
    seen = {}
    dupes = []
    for match in re.finditer(r'^\s{2}"([^"@][^"]*)"\s*:', text, re.M):
        key = match.group(1)
        if key in seen:
            dupes.append(key)
        seen[key] = True
    return dupes


def balanced(text):
    depth = 0
    for ch in text:
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


def main():
    problems = []
    notes = []

    template = load(TEMPLATE)
    other = load(OTHER)
    t_keys = keys_of(template)
    o_keys = keys_of(other)

    print("القالب %s: %d مفتاحاً | %s: %d مفتاحاً" % (TEMPLATE, len(t_keys), OTHER, len(o_keys)))

    # 0) @@locale داخل الملف يجب أن يطابق امتداد اسم الملف تماماً
    #    (قاعدة gen-l10n في Flutter 3.47+ — كسرها يوقف التوليد عند المستخدم)
    for path in (TEMPLATE, OTHER):
        data = load(path)
        declared = data.get("@@locale")
        suffix = os.path.basename(path)[: -len(".arb")]
        if declared != suffix:
            problems.append(
                "%s: @@locale=%s لا يطابق اسم الملف %s" % (path, declared, suffix)
            )

    # 1) التطابق
    only_t = sorted(set(t_keys) - set(o_keys))
    only_o = sorted(set(o_keys) - set(t_keys))
    if only_t:
        problems.append("مفاتيح في العربية دون الفرنسية: %s" % only_t)
    if only_o:
        problems.append("مفاتيح في الفرنسية دون العربية: %s" % only_o)

    # 2) قيم فارغة
    for name, data, ks in ((TEMPLATE, template, t_keys), (OTHER, other, o_keys)):
        empty = [k for k in ks if not str(data[k]).strip()]
        if empty:
            problems.append("%s: قيم فارغة → %s" % (name, empty))

    # 3) التكرار الخام
    for path in (TEMPLATE, OTHER):
        dupes = duplicates(path)
        if dupes:
            problems.append("%s: مفاتيح مكررة → %s" % (path, sorted(set(dupes))))

    # 4 + 5) المتغيّرات وصيغة ICU
    for k in t_keys:
        t_value = str(template[k])
        o_value = str(other.get(k, ""))
        t_ph = _scan_placeholders(t_value)
        o_ph = _scan_placeholders(o_value)
        if t_ph != o_ph:
            problems.append(
                "%s: المتغيّرات غير متطابقة (عربية %s · فرنسية %s)"
                % (k, sorted(t_ph), sorted(o_ph))
            )
        meta = template.get("@%s" % k) or {}
        declared = set((meta.get("placeholders") or {}).keys())
        missing = t_ph - declared
        if missing:
            problems.append("%s: متغيّرات بلا إعلان في @metadata → %s" % (k, sorted(missing)))
        extra = declared - t_ph
        if extra:
            problems.append("%s: @metadata يعلن متغيّرات غير مستعملة → %s" % (k, sorted(extra)))

        for label, value in (("عربية", t_value), ("فرنسية", o_value)):
            if not balanced(value):
                problems.append("%s (%s): أقواس ICU غير متوازنة" % (k, label))
                continue
            selector = SELECTORS.search(value)
            if not selector:
                continue
            kind = selector.group(2)
            body = value[selector.end():]
            cats = plural_categories(body)
            if "other" not in cats:
                problems.append("%s (%s): ICU %s بلا فئة `other`" % (k, label, kind))
            if kind == "plural" and label == "عربية":
                bad = [c for c in cats if not c.startswith("=") and c not in AR_PLURAL_CATEGORIES]
                if bad:
                    problems.append("%s: فئات جمع عربية غير صالحة → %s" % (k, bad))

    # 6 + 7) الاستعمال في الكود
    used = set()
    for root, _dirs, files in os.walk("lib"):
        for fn in sorted(files):
            if not fn.endswith(".dart") or fn.startswith("app_localizations"):
                continue
            text = io.open(os.path.join(root, fn), encoding="utf-8").read()
            used.update(USAGE.findall(text))
    for root, _dirs, files in os.walk("test"):
        for fn in sorted(files):
            if fn.endswith(".dart"):
                text = io.open(os.path.join(root, fn), encoding="utf-8").read()
                used.update(USAGE.findall(text))

    t_set = set(t_keys)
    missing_keys = sorted(k for k in used - t_set if not k.startswith(("of", "locale")))
    if missing_keys:
        problems.append("مفاتيح مستعملة في الكود وغير موجودة في %s → %s" % (TEMPLATE, missing_keys))

    unused = sorted(t_set - used)
    notes.append("مفاتيح معلنة ولم تُستعمل بعد: %d (احتياطي المراحل القادمة)" % len(unused))

    print()
    if problems:
        print("🔴 مشاكل الترجمة (%d):" % len(problems))
        for p in problems:
            print("   ", p)
    else:
        print("✅ الترجمة سليمة: تطابق · متغيّرات · ICU · استعمال")
    for n in notes:
        print("ℹ️ ", n)

    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
