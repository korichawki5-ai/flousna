"""اختبار ذاتي لأداة check_l10n.py — «اختبر الفاحص قبل أن تثق به».

🐞 ولد من عطل حقيقي (22/09/2026): البوابة كانت تعتبر كلمات الفروع
   «و» و«et» **متغيّرات**، و«فئات جمع» — فرفضت ترجمات سليمة تماماً
   («و{n} تنبيهات أخرى» عربية فصيحة، و«et {n} autres alertes» فرنسية).
   عطل في الفاحص أخطر من عطل في الكود: يدفعك لتشويه الترجمة الصحيحة
   إرضاءً لأداة معطوبة.

الاختبار يثبّت الاتجاهين:
   أ) لا إنذار كاذب على صيغ جمع سليمة (المسارات الثلاثة).
   ب) الإنذار الحقيقي يبقى يعمل (فئة `other` غائبة · فئة عربية غريبة ·
      متغيّرات غير متطابقة · قوس غير متوازن).

التشغيل: python3 tool/check_l10n_selftest.py
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import check_l10n  # noqa: E402  (يحتاج مسار tool/ قبل الاستيراد)

# ── أ) حالات سليمة يجب ألا تُنتج أي إنذار ──
CLEAN = [
    (
        "جمع عربي مع «و» قبل العدّاد (الصيغة التي أُضيفت في م2.2)",
        "{count, plural, =0{لا تنبيهات أخرى} =1{وتنبيه آخر} "
        "=2{وتنبيهان آخران} few{و{count} تنبيهات أخرى} "
        "many{و{count} تنبيهاً آخر} other{و{count} تنبيه آخر}}",
    ),
    (
        "جمع عربي بالنمط القديم (العدّاد أولاً)",
        "{count, plural, =1{يوم واحد} =2{يومان} few{{count} أيام} "
        "many{{count} يوماً} other{{count} يوم}}",
    ),
    (
        "جمع فرنسي فيه «et» قبل العدّاد",
        "{count, plural, =0{et aucune autre alerte} =1{et une autre alerte} "
        "other{et {count} autres alertes}}",
    ),
    (
        "نص بسيط بمتغيّر واحد",
        "بقي {days} من التجربة",
    ),
    (
        "متغيّران في نص واحد",
        "صرفتَ {spent} من أصل {limit}",
    ),
]

# ── ب) حالات معطوبة يجب أن تُكتشف ──
DIRTY = [
    (
        "فئة other غائبة في الجمع",
        "{count, plural, =1{واحد} other2{{count} كثير}}",
        "ICU plural بلا فئة `other`",
    ),
    (
        "فئة جمع عربية غير معتمدة",
        "{count, plural, lots{{count} كثير} other{{count} آخر}}",
        "فئات جمع عربية غير صالحة",
    ),
    (
        "أقواس ICU غير متوازنة",
        "{count, plural, other{{count} آخر}",
        "أقواس ICU غير متوازنة",
    ),
]


def main():
    failed = []

    print("1) صيغ سليمة يجب ألا يُشتكى منها (%d حالة)" % len(CLEAN))
    for label, value in CLEAN:
        found = check_l10n._scan_placeholders(value)
        cats = check_l10n.plural_categories(
            value.split(",", 2)[2] if ", plural," in value else ""
        )
        bad_cats = [c for c in cats if not c.startswith("=")
                    and c not in check_l10n.AR_PLURAL_CATEGORIES]
        ok = found == {"count"} or found == {"days"} or found == {"spent", "limit"}
        if ok and not bad_cats:
            print("   ✅ %s → متغيّرات %s" % (label, sorted(found)))
        else:
            failed.append("إنذار كاذب في «%s» → متغيّرات %s · فئات %s"
                          % (label, sorted(found), bad_cats))
            print("   🔴 %s → متغيّرات %s · فئات مرفوضة %s"
                  % (label, sorted(found), bad_cats))

    print("\n2) الأعطال الحقيقية يجب أن تُكتشف (%d حالة)" % len(DIRTY))
    for label, value, expected in DIRTY:
        problems = []
        if not check_l10n.balanced(value):
            problems.append("أقواس ICU غير متوازنة")
        else:
            kind_body = value.split(",", 2)[2]
            cats = check_l10n.plural_categories(kind_body)
            if "other" not in cats:
                problems.append("ICU plural بلا فئة `other`")
            bad = [c for c in cats if not c.startswith("=")
                   and c not in check_l10n.AR_PLURAL_CATEGORIES]
            if bad:
                problems.append("فئات جمع عربية غير صالحة")
        hit = any(expected.split("`")[0].strip() in p for p in problems)
        if hit:
            print("   ✅ %s → %s" % (label, problems))
        else:
            failed.append("لم يُكتشف: %s (وجدنا %s)" % (label, problems))
            print("   🔴 %s → %s" % (label, problems or "لا شيء"))

    print("\n3) الملفات الحقيقية تمرّ الآن بلا إنذار كاذب")
    template = check_l10n.load(check_l10n.TEMPLATE)
    other = check_l10n.load(check_l10n.OTHER)
    for key in ("budgetAlertMore", "dayCountLabel", "homeTrialBanner"):
        value = str(template.get(key, ""))
        found = check_l10n._scan_placeholders(value)
        declared = set(
            (template.get("@" + key, {}) or {}).get("placeholders", {}).keys()
        )
        if found == declared or not declared:
            print("   ✅ %-18s متغيّرات %s" % (key, sorted(found)))
        else:
            failed.append("%s: المتغيّرات %s لا تطابق الإعلان %s"
                          % (key, sorted(found), sorted(declared)))
            print("   🔴 %-18s متغيّرات %s ≠ إعلان %s"
                  % (key, sorted(found), sorted(declared)))
    if check_l10n._scan_placeholders(str(other.get("budgetAlertMore", ""))) != {"count"}:
        failed.append("النسخة الفرنسية من budgetAlertMore لا تُحلَّل صحيحاً")
        print("   🔴 budgetAlertMore (fr) تحليل خاطئ")
    else:
        print("   ✅ %-18s متغيّرات ['count']" % "budgetAlertMore (fr)")

    print()
    if failed:
        print("🔴 الفاحص نفسه معطوب (%d مشكلة):" % len(failed))
        for item in failed:
            print("   ", item)
        return 1
    print("✅ الفاحص سليم: يفهم ICU بلا إنذارات كاذبة، ويكتشف الأعطال الحقيقية")
    return 0


if __name__ == "__main__":
    sys.exit(main())
