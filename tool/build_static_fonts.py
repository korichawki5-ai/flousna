"""توليد أوزان Cairo الثابتة من الملف المتغيّر الرسمي.

لماذا هذا السكربت موجود:
    ملف Cairo.ttf الذي ينشره Google Fonts صار **متغيّراً فقط** (محورا wght
    وslnt)، ومحرّك Flutter لا يطبّق محور الوزن تلقائياً من `fontWeight`
    بل يحتاج `FontVariation` صريحة في كل TextStyle. النتيجة العملية:
    النص w600 يظهر بنفس سماكة w400 — أي نظام تصميم بلا تدرّج بصري حقيقي.

    الحل الحتمي: أوزان ثابتة (static instances) يولّدها fontTools من الملف
    المتغيّر، فتصبح السماكات مضمونة على أي منصّة وأي إصدار Flutter.
    والمفارقة أن الناتج أصغر: 492 KB للأوزان الثلاثة مقابل 599 KB للملف
    المتغيّر (لأن فروق التغيّر تُحذف بعد التثبيت).

الملف المتغيّر الأصلي لا يُحفظ في المستودع (بلا حاجة) — يُنزَّل عند الطلب.

المتطلبات: pip install fonttools
التشغيل:   python3 tool/build_static_fonts.py
"""

import hashlib
import io
import os
import tempfile
import urllib.request

from fontTools.pens.statisticsPen import StatisticsPen
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

SRC_URL = (
    "https://raw.githubusercontent.com/google/fonts/main/"
    "ofl/cairo/Cairo%5Bslnt%2Cwght%5D.ttf"
)
OUT_DIR = "assets/fonts/Cairo"

# الأوزان = المستعملة فعلاً في lib/ (تحقق: grep -rho "FontWeight\.w[0-9]*" lib)
# لا نولّد غيرها حتى لا يتضخّم حجم التطبيق بأصول غير مستعملة.
WEIGHTS = {
    400: "Cairo-Regular.ttf",
    500: "Cairo-Medium.ttf",
    600: "Cairo-SemiBold.ttf",
}

# محرف لاتيني + عربي + رقم — للتأكد أن السماكة تغيّرت فعلاً في كل المجموعات
PROBE_CHARS = ("A", "ع", "5")


def main() -> int:
    tmp = tempfile.mkdtemp(prefix="cairo_var_")
    src = os.path.join(tmp, "Cairo.ttf")

    print(f"1) تنزيل المصدر المتغيّر من مستودع Google Fonts…")
    print(f"   {SRC_URL}")
    urllib.request.urlretrieve(SRC_URL, src)

    variable = TTFont(src)
    if "fvar" not in variable:
        print("🔴 الملف المنزَّل ليس خطاً متغيّراً — تغيّر مصدر Google Fonts؟")
        return 1
    axes = {a.axisTag for a in variable["fvar"].axes}
    base_glyphs = variable["maxp"].numGlyphs
    print(f"   ✅ glyphs={base_glyphs} · axes={sorted(axes)}")

    # 2) توليد الأوزان
    print("\n2) توليد الأوزان الثابتة…")
    digests = {}
    ok = True
    for wght, fname in sorted(WEIGHTS.items()):
        out_path = os.path.join(OUT_DIR, fname)
        pinned = {"wght": float(wght)}
        if "slnt" in axes:
            pinned["slnt"] = 0.0  # بلا إمالة
        inst = instantiateVariableFont(
            TTFont(src), pinned, inplace=False, updateFontNames=True
        )
        inst.save(out_path)

        check = TTFont(out_path)
        data = io.open(out_path, "rb").read()
        digests[fname] = hashlib.sha256(data).hexdigest()[:12]
        wc = check["OS/2"].usWeightClass
        glyphs = check["maxp"].numGlyphs
        bad = (
            "fvar" in check
            or wc != wght
            or glyphs < base_glyphs * 0.95
        )
        ok = ok and not bad
        mark = "🔴" if bad else "✅"
        print(
            f"   {mark} {fname:20} {len(data)/1024:7.1f} KB · "
            f"usWeightClass={wc} · glyphs={glyphs}"
        )

    if len(set(digests.values())) != len(digests):
        print("🔴 الأوزان الناتجة متطابقة — التثبيت لم يغيّر المحارف")
        return 1

    # 3) قياس السماكة الفعلية (مساحة المحرف) بين الأخف والأثقل
    print("\n3) التحقق أن السماكة تغيّرت في المحارف فعلاً…")
    light, heavy = WEIGHTS[min(WEIGHTS)], WEIGHTS[max(WEIGHTS)]
    f_light = TTFont(os.path.join(OUT_DIR, light))
    f_heavy = TTFont(os.path.join(OUT_DIR, heavy))
    cmap = f_light.getBestCmap()
    gs_light, gs_heavy = f_light.getGlyphSet(), f_heavy.getGlyphSet()
    for ch in PROBE_CHARS:
        glyph = cmap.get(ord(ch))
        if glyph is None:
            print(f"   ⚠️ المحرف '{ch}' غير موجود في الخط")
            continue
        p_light, p_heavy = StatisticsPen(gs_light), StatisticsPen(gs_heavy)
        gs_light[glyph].draw(p_light)
        gs_heavy[glyph].draw(p_heavy)
        ratio = abs(p_heavy.area) / abs(p_light.area)
        good = ratio > 1.05
        ok = ok and good
        print(
            f"   {'✅' if good else '🔴'} '{ch}': مساحة {light}={abs(p_light.area):.0f}"
            f" → {heavy}={abs(p_heavy.area):.0f} (+{100*(ratio-1):.1f}%)"
        )

    print()
    if not ok:
        print("🔴 فشل التحقق — لا تستعمل هذه الملفات")
        return 1

    print("✅ الأوزان الثابتة جاهزة ومطابقة لما يعلنه pubspec.yaml")
    print("   ⚠️ تذكير قانوني: ملف OFL.txt يجب أن يبقى بجانب الخطوط (رخصة OFL 1.1).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
