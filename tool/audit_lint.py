"""فحص تقريبي لقواعد التحليل في analysis_options.yaml — بلا SDK.

لماذا هذا السكربت؟
    سياسة المشروع Zero-Bugs تتطلب صفر إنذارات، لكن بيئة التطوير هنا لا تحتوي
    Flutter SDK لتشغيل `flutter analyze` الحقيقي. لذلك نُنفِّذ تقريبات دقيقة
    (بوعي بحدودها) لأهم القواعد النشطة، فتبقى المخالفات مكتشفة مبكراً بدل أن
    تظهر دفعة واحدة على جهاز المستخدم.

    🔴 المصدر الرسمي يبقى `flutter analyze` — يُشغَّل في CI من المرحلة 2.

القواعد المفحوصة هنا:
    prefer_single_quotes · eol_at_end_of_file · require_trailing_commas
    use_super_parameters · prefer_final_in_for_each · always_declare_return_types
    sort_child_properties_last · avoid_unnecessary_containers
    sized_box_for_whitespace · use_colored_box · use_decorated_box
    use_build_context_synchronously · cascade_invocations
    unnecessary_await_in_return · use_is_even_rather_than_modulo
    literal_only_boolean_expressions · avoid_bool_literals_in_conditional_expressions
    use_named_constants · unnecessary_lambdas

التشغيل: python3 tool/audit_lint.py
"""

import fnmatch
import io
import os
import re
import sys

from audit_project import _skip_string, walk

KEYWORDS_BEFORE_PAREN = {
    "if", "for", "while", "switch", "catch", "return", "await", "yield",
    "assert", "do", "else", "in", "is", "as", "new", "const", "throw",
    "super", "this", "case",
}

# أنواع مدمجة/modifiers — لا يمكن أن تكون اسم دالة بلا نوع إرجاع
BUILTIN_NAMES = {
    "int", "double", "num", "bool", "void", "dynamic", "var", "final",
    "late", "required", "covariant", "never", "Null", "Object", "Function",
}

CHILD_KEYS = ("child", "children")


# ═══════════════════════════════════════════════════════════════
#  أدوات التحليل النصي
# ═══════════════════════════════════════════════════════════════
def mask(src):
    """نسخة بنفس الطول: التعليقات ومحتوى السلاسل ← مسافات (الأسطر محفوظة).

    الحفاظ على الطول يجعل الأرقام والمواضع مطابقة للأصل تماماً.
    """
    out = list(src)
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                out[i] = " "
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            while i < n and not (src[i] == "*" and i + 1 < n and src[i + 1] == "/"):
                if src[i] != "\n":
                    out[i] = " "
                i += 1
            for k in range(i, min(i + 2, n)):
                if src[k] != "\n":
                    out[k] = " "
            i += 2
            continue
        if c in "'\"":
            j, _ = _skip_string(src, i)
            for k in range(i, min(j, n)):
                if src[k] != "\n":
                    out[k] = " "
            i = j
            continue
        i += 1
    return "".join(out)


def string_literals(src):
    """كل السلاسل النصية خارج التعليقات: (بداية، نهاية، النص، خام؟)."""
    res = []
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
            raw = i > 0 and src[i - 1] == "r"
            j, text = _skip_string(src, i)
            res.append((i, j, text, raw))
            i = j
            continue
        i += 1
    return res


def groups(m):
    """كل الأزواج المتطابقة من الأقواس: (موضع الفتح، موضع الإغلاق، نوع الفتح)."""
    pairs = {"(": ")", "[": "]", "{": "}"}
    stack = []
    res = []
    for i, ch in enumerate(m):
        if ch in pairs:
            stack.append((ch, i))
        elif ch in ")]}":
            if not stack:
                continue
            opener, oi = stack.pop()
            res.append((oi, i, opener))
    return res


TYPE_CHARS = set(
    "abcdefghijklmnopqrstuvwxyz"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "0123456789_.?,[]<>() \t\r\n"
)


def _angle_open(m, k):
    """هل `<` عند k فتح وسائط نوع عامة (generic) لا عملية مقارنة؟

    نعتمد على سياقين: ما قبلها بلا فراغ (معرّف/`>`) وبداية اسم نوع،
    ثم نتحقق أن ما بينها وبين `>` المطابق لا يحوي إلا محارف نوعية.
    هذا يمنع العدّ الخاطئ لـ `a < b` ويصحّح الفواصل داخل `Map<K, V>`.
    """
    if k <= 0:
        return False
    prev = m[k - 1]
    if not (prev.isalnum() or prev in "_.>"):
        return False
    nxt = m[k + 1] if k + 1 < len(m) else ""
    if not (nxt.isalpha() or nxt == "_"):
        return False
    depth = 0
    for j in range(k, min(len(m), k + 400)):
        ch = m[j]
        if ch == "<":
            depth += 1
        elif ch == ">":
            depth -= 1
            if depth == 0:
                return True
        elif ch not in TYPE_CHARS:
            return False
    return False


def split_args(m, open_idx, close_idx):
    """تقسيم وسائط المجموعة على الفواصل في العمق صفر.

    نتعقّب الأقواس الزاوية للنوع العام (`FutureBuilder<Result<X, Y>>`)
    حتى لا تُحسب الفاصلة داخل النوع فاصلةَ وسائط.
    """
    depth = 0
    ang = 0
    start = open_idx + 1
    args = []
    for k in range(open_idx + 1, close_idx):
        ch = m[k]
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        elif ch == "<":
            if ang or _angle_open(m, k):
                ang += 1
        elif ch == ">" and ang:
            ang -= 1
        elif ch == "," and depth == 0 and ang == 0:
            args.append((start, k))
            start = k + 1
    if m[start:close_idx].strip():
        args.append((start, close_idx))
    return args


def _exclude_patterns():
    """أنماط `exclude` من analysis_options.yaml — مصدر الحقيقة أنفسها."""
    if not os.path.isfile("analysis_options.yaml"):
        return []
    txt = io.open("analysis_options.yaml", encoding="utf-8").read()
    match = re.search(r"^\s*exclude:\s*\n((?:\s*-\s*.+\n?)+)", txt, re.M)
    if not match:
        return []
    return [
        ln.strip()[1:].strip().strip('"').strip("'")
        for ln in match.group(1).splitlines()
        if ln.strip().startswith("-")
    ]


def _is_excluded(path, patterns):
    posix = path.replace("\\", "/")
    base = posix.rsplit("/", 1)[-1]
    for pat in patterns:
        q = pat.replace("\\", "/")
        if q.endswith("/**") and (posix == q[:-3] or posix.startswith(q[:-3] + "/")):
            return True
        if q.startswith("**/"):
            q = q[3:]
        if fnmatch.fnmatch(base, q) or fnmatch.fnmatch(posix, q) or fnmatch.fnmatch(posix, "*/" + q):
            return True
    return False


def callee(m, open_idx):
    """اسم الدالة/الصنف قبل قوس الفتح (فارغ إن لم يوجد)."""
    j = open_idx - 1
    while j >= 0 and m[j] in " \t\r\n":
        j -= 1
    end = j + 1
    while j >= 0 and (m[j].isalnum() or m[j] in "_.$"):
        j -= 1
    return m[j + 1:end]


def arg_name(m, span):
    """اسم الوسيط المُسمّى (أو None)."""
    text = m[span[0]:span[1]].strip()
    match = re.match(r"^([A-Za-z_]\w*)\s*:", text)
    return match.group(1) if match else None


def _statement_end(m, start):
    """موضع الفاصلة المنقوطة التي تُنهي البيان المبتدئ عند start (أو None)."""
    depth = 0
    i = start
    n = len(m)
    while i < n:
        ch = m[i]
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            if depth == 0:
                return None
            depth -= 1
        elif ch == ";" and depth == 0:
            return i
        i += 1
    return None


def _gap_start(m, await_idx):
    """موضع نهاية البيان الذي يحتوي await — أي بداية الفجوة غير المتزامنة.

    استعمال context **داخل** نداء await نفسه ليس مخالفة (لا فجوة بعد)،
    لذلك نبحث عن أول `;` عند عمق ≤ 0.
    """
    depth = 0
    i = await_idx
    n = len(m)
    while i < n:
        ch = m[i]
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        elif ch == ";" and depth <= 0:
            return i
        i += 1
    return n


def line_of(src, idx):
    return src.count("\n", 0, idx) + 1


# ═══════════════════════════════════════════════════════════════
#  الفحوص
# ═══════════════════════════════════════════════════════════════
def check_file(path, findings):
    src = io.open(path, encoding="utf-8").read()
    m = mask(src)
    strs = string_literals(src)
    grps = groups(m)
    close_of = {oi: (ci, op) for oi, ci, op in grps}

    def add(rule, idx, note):
        findings.append("%s:%d  [%s] %s" % (path, line_of(src, idx), rule, note))

    # ── eol_at_end_of_file ──
    if src and not src.endswith("\n"):
        add("eol_at_end_of_file", len(src) - 1, "الملف لا ينتهي بسطر جديد")

    # ── prefer_single_quotes ──
    for start, end, text, raw in strs:
        if raw or not text.startswith('"'):
            continue
        if "$" in text:
            continue  # يتطلّب استيفاءً (interpolation)
        if "'" in text:
            continue  # يحتوي فاصلة اقتباس مفردة — المزدوجة أنظف
        if text.startswith('"""'):
            continue
        add("prefer_single_quotes", start, "سلسلة بنصوص مزدوجة بلا حاجة: %s" % text[:40])

    # ── use_super_parameters ──
    for match in re.finditer(r"\bKey\??\s+key\b", m):
        add("use_super_parameters", match.start(), "استعمل `super.key` بدل `Key? key`")

    # ── prefer_final_in_for_each ──
    for match in re.finditer(r"\bfor\s*\(\s*var\s", m):
        add("prefer_final_in_for_each", match.start(), "استعمل `for (final …)`")

    # ── unnecessary_await_in_return ──
    for match in re.finditer(r"\breturn\s+await\b", m):
        add("unnecessary_await_in_return", match.start(), "`return await` ← `return`")

    # ── use_is_even_rather_than_modulo ──
    for match in re.finditer(r"%\s*2\s*==\s*0", m):
        add("use_is_even_rather_than_modulo", match.start(), "استعمل `.isEven`")

    # ── literal_only_boolean_expressions / avoid_bool_literals_in_conditional ──
    for match in re.finditer(r"\b(if|while)\s*\(\s*(true|false)\s*\)", m):
        add("literal_only_boolean_expressions", match.start(), "شرط بقيمة ثابتة")
    for match in re.finditer(r"\?\s*(true|false)\s*:\s*(false|true)", m):
        add("avoid_bool_literals_in_conditional_expressions", match.start(), "ثلاثي بقيم ثابتة")

    # ── unnecessary_lambdas: `onX: () => f()` ──
    for match in re.finditer(r":\s*\(\s*\)\s*=>\s*[A-Za-z_][\w.]*\(\s*\)", m):
        add("unnecessary_lambdas", match.start(), "مرّر الدالة مباشرة بدل lambda فارغة")

    # ── use_named_constants ──
    for pattern, note in (
        (r"\bDuration\s*\(\s*(seconds|milliseconds|minutes)\s*:\s*0\s*\)", "Duration.zero"),
        (r"\bEdgeInsets(\.all)?\s*\(\s*0\s*\)", "EdgeInsets.zero"),
        (r"\bOffset\s*\(\s*0\s*,\s*0\s*\)", "Offset.zero"),
        (r"\bSize\s*\.\s*zero\b", ""),
    ):
        if not note:
            continue
        for match in re.finditer(pattern, m):
            add("use_named_constants", match.start(), "استعمل %s" % note)

    # ── always_declare_return_types ──
    #    (الأسماء التي تبدأ بحرف كبير مستثناة عمداً: لا نميّزها عن constructors)
    modifiers = r"(?:(?:static|external|abstract)\s+)*"
    for match in re.finditer(r"^([ \t]*)(" + modifiers + r")([a-z_]\w*)\s*\(", m, re.M):
        name = match.group(3)
        if name in KEYWORDS_BEFORE_PAREN or name in BUILTIN_NAMES:
            continue  # كلمة محجوزة أو نمط switch مثل `int() => value`
        open_idx = match.end() - 1
        pair = close_of.get(open_idx)
        if not pair:
            continue
        ci, _ = pair
        rest = m[ci + 1:ci + 12].lstrip()
        if rest.startswith("{") or rest.startswith("=>"):
            add("always_declare_return_types", match.start(3),
                "الدالة `%s` بلا نوع إرجاع معلن" % name)

    # ── فحوص على المجموعات ──
    multiline_strings = [(s, e) for s, e, t, _ in strs if "\n" in t]

    for oi, ci, opener in grps:
        inner = m[oi + 1:ci]
        args = split_args(m, oi, ci)
        fn = callee(m, oi)

        # require_trailing_commas (للأقواس الدائرية والمربعة فقط)
        if opener in "([" and "\n" in inner and args:
            before = fn.split(".")[-1] if fn else ""
            if before not in KEYWORDS_BEFORE_PAREN:
                k = ci - 1
                while k > oi and m[k] in " \t\r\n":
                    k -= 1
                if m[k] != "," and line_of(src, k) != line_of(src, ci):
                    overlapped = any(s < ci and e > k for s, e in multiline_strings)
                    if not overlapped:
                        add("require_trailing_commas", ci,
                            "قائمة متعددة الأسطر بلا فاصلة أخيرة")

        if opener != "(" or not args:
            continue

        # sort_child_properties_last — للأصناف (أول حرف كبير)
        if fn and fn[0].isupper() and "." not in fn:
            names = [arg_name(m, a) for a in args]
            for pos, nm in enumerate(names):
                if nm in CHILD_KEYS and pos != len(names) - 1:
                    add("sort_child_properties_last", args[pos][0],
                        "`%s:` يجب أن يكون آخر وسيط في %s" % (nm, fn))
                    break

        # قواعد Container
        if fn == "Container":
            names = {nm for nm in (arg_name(m, a) for a in args) if nm}
            if names <= {"key", "child"}:
                add("avoid_unnecessary_containers", oi,
                    "Container بلا خصائص ← احذفه ومرّر الطفل مباشرة")
            elif names <= {"key", "child", "width", "height"}:
                add("sized_box_for_whitespace", oi, "استعمل SizedBox بدل Container")
            elif "decoration" in names and names <= {"key", "child", "decoration"}:
                add("use_decorated_box", oi, "استعمل DecoratedBox بدل Container")
            elif "color" in names and names <= {"key", "child", "color"}:
                add("use_colored_box", oi, "استعمل ColoredBox بدل Container")

    # ── cascade_invocations: بيانان متتاليان فعلاً على نفس الهدف ──
    statements = []
    for match in re.finditer(r"([A-Za-z_]\w*)\s*\.\s*[A-Za-z_]\w*\s*\(", m):
        head = match.group(1)
        line_start = m.rfind("\n", 0, match.start()) + 1
        if m[line_start:match.start()].strip():
            continue  # ليس في بداية السطر ← ليس بياناً مستقلاً
        end = _statement_end(m, match.start())
        if end is None:
            continue
        statements.append((head, match.start(), end))
    for (h1, i1, e1), (h2, i2, _e2) in zip(statements, statements[1:]):
        if h1 != h2:
            continue
        # البيان التالي يجب أن يبدأ مباشرة بعد فاصلة منقوطة السابق
        nxt = e1 + 1
        while nxt < len(m) and m[nxt] in " \t\r\n":
            nxt += 1
        if nxt != i2:
            continue
        add("cascade_invocations", i2,
            "بيانان متتاليان على `%s` ← استعمل cascade (..)" % h1)

    # ── use_build_context_synchronously ──
    #    القاعدة: بعد أي await لا يجوز استعمال BuildContext إلا بفحص
    #    `context.mounted` (أو `mounted` في State) بينهما.
    for match in re.finditer(r"\basync\b", m):
        brace = m.find("{", match.end())
        if brace < 0:
            continue
        ci = close_of.get(brace, (None, None))[0]
        if ci is None:
            continue
        body = m[brace:ci]
        for await_match in re.finditer(r"\bawait\b", body):
            gap = _gap_start(body, await_match.start())
            # `context.mounted` هو الفحص نفسه — لا يُحسب استعمالاً
            ctx = [
                x.start()
                for x in re.finditer(
                    r"\bcontext\b(?!\s*:)(?!\s*\.\s*mounted)", body
                )
                if x.start() > gap
            ]
            if not ctx:
                continue
            first_ctx = ctx[0]
            # استثناء: context مُعلَن محلياً **بعد** الفجوة (نمط الاختبارات
            # `final BuildContext context = tester.element(…)`) — لا فجوة فيه.
            local_decl = re.search(r"\bBuildContext\s+context\s*=", body)
            if local_decl is not None and local_decl.start() > gap:
                continue
            guarded = any(
                gap < g.start() < first_ctx
                for g in re.finditer(r"\bmounted\b", body)
            )
            if not guarded:
                add(
                    "use_build_context_synchronously",
                    brace + first_ctx,
                    "استعمال context بعد await بلا فحص mounted",
                )
                break


def main():
    findings = []
    patterns = _exclude_patterns()
    files = [
        f for f in walk(["lib", "test"], [".dart"])
        if not f.endswith("app_localizations.dart") and not _is_excluded(f, patterns)
    ]
    for path in files:
        check_file(path, findings)

    print("files checked: %d" % len(files))
    if findings:
        print("\n⚠️ مخالفات محتملة لقواعد analysis_options.yaml (%d):" % len(findings))
        for f in sorted(findings):
            print("  ", f)
        print("\n(الفحص تقريبي — الحكم النهائي لـ `flutter analyze`)")
        return 1
    print("\n✅ لا مخالفات لقواعد التنسيق النشطة (فحص تقريبي لـ 19 قاعدة)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
