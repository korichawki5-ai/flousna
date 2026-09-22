"""اختبار ذاتي لأداة audit_lint.py — «اختبر الفاحص قبل أن تثق به».

يكتب ملف Dart مؤقتاً مليئاً بمخالفات مقصودة (خارج المستودع في مجلد
مؤقت)، ويتأكد أن كل قاعدة نشطة تُكتشف فعلاً. لو سكتت قاعدة عن مخالفة
مقصودة فالفاحص نفسه معطوب — وهذا أخطر من المخالفة.

التشغيل: python3 tool/audit_lint_selftest.py
"""

import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import audit_lint  # noqa: E402  (يحتاج مسار tool/ قبل الاستيراد)

# كل قطعة = (اسم القاعدة، كود يحتوي مخالفة واحدة مقصودة)
CASES = [
    (
        "prefer_single_quotes",
        'class A {\n  static const String x = "نص";\n}\n',
    ),
    (
        "eol_at_end_of_file",
        "class A {\n  static const String x = 'y';\n}",
    ),
    (
        "require_trailing_commas",
        "class A {\n"
        "  static Widget build() {\n"
        "    return Padding(\n"
        "      padding: EdgeInsets.zero,\n"
        "      child: Text('x')\n"
        "    );\n"
        "  }\n"
        "}\n",
    ),
    (
        "use_super_parameters",
        "class A {\n  const A({Key? key});\n}\n",
    ),
    (
        "prefer_final_in_for_each",
        "class A {\n"
        "  static void f(List<int> xs) {\n"
        "    for (var x in xs) {\n"
        "      print(x);\n"
        "    }\n"
        "  }\n"
        "}\n",
    ),
    (
        "unnecessary_await_in_return",
        "class A {\n"
        "  static Future<int> f(Future<int> g) async {\n"
        "    return await g;\n"
        "  }\n"
        "}\n",
    ),
    (
        "use_is_even_rather_than_modulo",
        "class A {\n  static bool f(int x) => x % 2 == 0;\n}\n",
    ),
    (
        "literal_only_boolean_expressions",
        "class A {\n  static void f() {\n    if (true) {\n      print('x');\n    }\n  }\n}\n",
    ),
    (
        "avoid_bool_literals_in_conditional_expressions",
        "class A {\n  static bool f(bool x) => x ? true : false;\n}\n",
    ),
    (
        "unnecessary_lambdas",
        "class A {\n"
        "  static Widget f(VoidCallback g) => TextButton(onPressed: () => g());\n"
        "}\n",
    ),
    (
        "use_named_constants",
        "class A {\n  static Duration d = const Duration(seconds: 0);\n}\n",
    ),
    (
        "always_declare_return_types",
        "class A {\n  static _helper() {\n    return 1;\n  }\n}\n",
    ),
    (
        "sort_child_properties_last",
        "class A {\n"
        "  static Widget f() {\n"
        "    return Padding(\n"
        "      child: Text('x'),\n"
        "      padding: EdgeInsets.zero,\n"
        "    );\n"
        "  }\n"
        "}\n",
    ),
    (
        "avoid_unnecessary_containers",
        "class A {\n"
        "  static Widget f() => Container(\n"
        "        child: Text('x'),\n"
        "      );\n"
        "}\n",
    ),
    (
        "sized_box_for_whitespace",
        "class A {\n"
        "  static Widget f() => Container(\n"
        "        width: 8,\n"
        "        height: 8,\n"
        "        child: Text('x'),\n"
        "      );\n"
        "}\n",
    ),
    (
        "use_decorated_box",
        "class A {\n"
        "  static Widget f() => Container(\n"
        "        decoration: BoxDecoration(),\n"
        "        child: Text('x'),\n"
        "      );\n"
        "}\n",
    ),
    (
        "use_colored_box",
        "class A {\n"
        "  static Widget f() => Container(\n"
        "        color: Colors.red,\n"
        "        child: Text('x'),\n"
        "      );\n"
        "}\n",
    ),
    (
        "cascade_invocations",
        "class A {\n"
        "  static void f(List<int> xs) {\n"
        "    xs.add(1);\n"
        "    xs.add(2);\n"
        "  }\n"
        "}\n",
    ),
    (
        "use_build_context_synchronously",
        "class A {\n"
        "  static Future<void> f(BuildContext context) async {\n"
        "    await Future<void>.delayed(Duration.zero);\n"
        "    ScaffoldMessenger.of(context).showSnackBar(SnackBar());\n"
        "  }\n"
        "}\n",
    ),
]

# مقاطع سليمة يجب ألا تُنتج أي إنذار (حماية من الإيجابيات الكاذبة)
CLEAN_CASES = [
    (
        "context محروس بـ context.mounted",
        "class A {\n"
        "  static Future<void> f(BuildContext context) async {\n"
        "    await Future<void>.delayed(Duration.zero);\n"
        "    if (!context.mounted) return;\n"
        "    ScaffoldMessenger.of(context).showSnackBar(SnackBar());\n"
        "  }\n"
        "}\n",
    ),
    (
        "context مُعلَن بعد الفجوة (نمط الاختبارات)",
        "void main() {\n"
        "  testWidgets('x', (WidgetTester tester) async {\n"
        "    await tester.pumpWidget(App());\n"
        "    final BuildContext context = tester.element(find.byType(App));\n"
        "    expect(Directionality.of(context), TextDirection.rtl);\n"
        "  });\n"
        "}\n",
    ),
    (
        "context كوسيط مُسمّى داخل نداء await",
        "class A {\n"
        "  static Future<bool> f(BuildContext context) async {\n"
        "    final bool? r = await showDialog<bool>(\n"
        "      context: context,\n"
        "      builder: (BuildContext c) => Text('x'),\n"
        "    );\n"
        "    return r ?? false;\n"
        "  }\n"
        "}\n",
    ),
    (
        "أسهم متتالية ليست cascade (دوال مختلفة)",
        "class A {\n"
        "  static String x(BuildContext c, DateTime d) =>\n"
        "      DateFormat.MMMd('ar').format(d);\n"
        "\n"
        "  static String y(BuildContext c, DateTime d) =>\n"
        "      DateFormat.MMMd('ar').format(d);\n"
        "  }\n",
    ),
    (
        "نمط switch يبدأ باسم نوع",
        "class A {\n"
        "  static int? f(Object? v) => switch (v) {\n"
        "        int() => v,\n"
        "        String() => int.tryParse(v),\n"
        "        _ => null,\n"
        "      };\n"
        "}\n",
    ),
    (
        "أقواس ضرورية حول عملية حسابية",
        "class A {\n  static int f(int hours) => (hours / 24).ceil();\n}\n",
    ),
    (
        "سلسلة مزدوجة لأنها تحتوي فاصلة اقتباس مفردة",
        "class A {\n  static const String x = \"it's fine\";\n}\n",
    ),
    (
        "فواصل داخل نوع عام لا تُحسب فواصلَ وسائط (child يبقى الأخير)",
        "class A {\n"
        "  static Widget build() {\n"
        "    return Expanded(\n"
        "      child: FutureBuilder<Result<List<CategoryView>, AppError>>(\n"
        "        future: Future<Result<List<CategoryView>, AppError>>.value(ok),\n"
        "        builder: (BuildContext c, AsyncSnapshot<Result<List<CategoryView>, AppError>> s) {\n"
        "          return Text('x');\n"
        "        },\n"
        "      ),\n"
        "    );\n"
        "  }\n"
        "}\n",
    ),
    (
        "cascade مكتوب فعلاً",
        "class A {\n"
        "  static void f(List<int> xs) {\n"
        "    xs\n"
        "      ..add(1)\n"
        "      ..add(2);\n"
        "  }\n"
        "}\n",
    ),
]


def run_on(code):
    """يشغّل الفاحص على كود مؤقت ويُرجع قواعد المخالفات المكتشفة."""
    tmp_dir = tempfile.mkdtemp(prefix="lint_selftest_")
    path = os.path.join(tmp_dir, "sample.dart")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(code)
    findings = []
    audit_lint.check_file(path, findings)
    rules = {f.split("[")[1].split("]")[0].strip() for f in findings}
    try:
        os.remove(path)
        os.rmdir(tmp_dir)
    except OSError:
        pass
    return rules


def main():
    failed = []

    print("1) كل مخالفة مقصودة يجب أن تُكتشف (%d قاعدة)" % len(CASES))
    for rule, code in CASES:
        found = run_on(code)
        if rule in found:
            print("   ✅ %-46s مكتشفة" % rule)
        else:
            failed.append("القاعدة %s لم تكتشف مخالفتها (وجدنا: %s)" % (rule, sorted(found) or "لا شيء"))
            print("   🔴 %-46s غير مكتشفة" % rule)

    print("\n2) الكود السليم يجب ألا يُنتج إنذاراً (%d مقطعاً)" % len(CLEAN_CASES))
    for label, code in CLEAN_CASES:
        found = run_on(code)
        if not found:
            print("   ✅ %s" % label)
        else:
            failed.append("إنذار كاذب في «%s» → %s" % (label, sorted(found)))
            print("   🔴 %s → %s" % (label, sorted(found)))

    print("\n3) استثناء الملفات المولّدة المعلن في analysis_options.yaml")
    generated = [
        ("database.g.dart", True),
        ("lib/data/db/database.g.dart", True),
        ("lib/generated/l10n/app_localizations.dart", True),
        ("lib/features/home/home_screen.dart", False),
        ("lib/data/db/database.dart", False),
    ]
    patterns = audit_lint._exclude_patterns()
    if not patterns:
        failed.append("لم نقرأ أي نمط exclude من analysis_options.yaml")
        print("   🔴 لم نقرأ أي نمط")
    for rel, want in generated:
        got = audit_lint._is_excluded(rel, patterns)
        if got == want:
            print("   ✅ %-52s %s" % (rel, "مستثنى" if want else "مفحوص"))
        else:
            failed.append("استثناء خاطئ لـ %s (توقّعنا %s)" % (rel, want))
            print("   🔴 %-52s %s" % (rel, "مستثنى" if got else "مفحوص"))

    print()
    if failed:
        print("🔴 الفاحص نفسه معطوب (%d مشكلة):" % len(failed))
        for f in failed:
            print("   ", f)
        return 1
    print("✅ الفاحص سليم: يكتشف كل المخالفات المقصودة ولا يطلق إنذارات كاذبة")
    return 0


if __name__ == "__main__":
    sys.exit(main())
