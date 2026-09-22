/// ═══════════════════════════════════════════════════════════════
///  أسماء الفئات المحظورة — حماية قانونية آلية
///
///  ⚠️ هذا الملف + الاختبار test/forbidden_brands_test.dart
///     يشكّلان حاجزاً تقنياً يمنع ذكر أي مؤسسة مالية أو علامة
///     تجارية داخل التطبيق — تنفيذاً لقرار تجنّب:
///       1. شبهة الوساطة المالية → ترخيص PSP من بنك الجزائر
///       2. جمع معطيات مالية حساسة → القانون 18-07 المادة 18
///       3. مسؤولية عن معلومات مصرفية لا نملكها
///
///  🔴 قاعدة: لا تُضف أي اسم مؤسسة إلى النصوص، ولا إلى الفئات
///     الافتراضية، ولا إلى رسائل واتساب. الاختبار سيفشل البناء.
///
///  ⚠️ ملاحظة تقنية مهمة:
///     المصطلحات اللاتينية القصيرة (ccp · rip · cib · bna…) تُطابَق
///     بحدود الكلمة (word boundary) وليس بـ contains — وإلا لأعطت
///     إنذارات كاذبة داخل كلمات مثل «accept» أو «banque».
/// ═══════════════════════════════════════════════════════════════
abstract final class ForbiddenBrands {
  /// مصطلحات لاتينية — تُطابَق ككلمة كاملة (word boundary)
  static const List<String> forbiddenLatin = <String>[
    // مؤسسات مالية وبريدية
    'baridimob',
    'baridi',
    'algerie poste',
    'ccp',
    'rip',
    'rib',
    // بطاقات وأنظمة دفع
    'cib',
    'edahabia',
    'satim',
    // بنوك
    'bna',
    'cpa',
    'bea',
    'badr',
    'cnep',
    'bdl',
    'agb',
    'al baraka',
    'societe generale',
    'bnp',
    'paribas',
    // محافظ إلكترونية
    'paysera',
    'wise',
    'paypal',
    'payoneer',
    'skrill',
    // مرافق ومتعاملون
    'sonelgaz',
    'seaal',
    'algerie telecom',
    'djezzy',
    'ooredoo',
    'mobilis',
  ];

  /// مصطلحات عربية — تُطابَق كسلسلة فرعية (العربية بلا حدود كلمات واضحة)
  static const List<String> forbiddenArabic = <String>[
    'بريد الجزائر',
    'بريدي موب',
    'البطاقة الذهبية',
    'سونلغاز',
    'سيال',
    'الجزائرية للمياه',
    'اتصالات الجزائر',
    'جيزي',
    'أوريدو',
    'موبيليس',
    'القرض الشعبي',
    'بنك الفلاحة',
    'البنك الوطني',
    'البنك الخارجي',
    'بنك الجزائر',
  ];

  /// بدائل محايدة معتمدة — استعمل هذه دائماً في الواجهة
  static const Map<String, String> neutralReplacements = <String, String>{
    'تحويل بنكي': 'وسيلة دفع عامة',
    'تحويل بريدي': 'وسيلة دفع عامة',
    'بطاقة بنكية': 'بطاقة',
    'محفظة إلكترونية': 'محفظة رقمية',
    'الكهرباء والغاز': 'بدل اسم شركة المرافق',
    'المياه': 'بدل اسم شركة المياه',
    'الإنترنت والهاتف': 'بدل اسم المتعامل',
    'اشتراك الهاتف': 'بدل اسم المتعامل',
  };

  /// يفحص نصاً ويعيد قائمة الأسماء المحظورة الموجودة فيه.
  ///
  /// قائمة فارغة = النص نظيف.
  ///
  /// يُستخدم في:
  /// - اختبار CI (test/forbidden_brands_test.dart)
  /// - فحص مدخلات المستخدم للفئات المخصصة (المرحلة 2)
  static List<String> scan(String text) {
    final String normalized = _normalize(text);
    final List<String> found = <String>[];

    // اللاتينية: مطابقة بكلمة كاملة
    for (final String brand in forbiddenLatin) {
      final String needle = _normalize(brand);
      // حدود كلمة: ما قبلها وما بعدها ليس حرفاً أو رقماً
      final RegExp pattern = RegExp(
        '(?<![a-z0-9])${RegExp.escape(needle)}(?![a-z0-9])',
      );
      if (pattern.hasMatch(normalized)) {
        found.add(brand);
      }
    }

    // العربية: مطابقة كسلسلة فرعية (طول ≥ 3 لتفادي الإنذارات الكاذبة)
    for (final String brand in forbiddenArabic) {
      final String needle = _normalize(brand);
      if (needle.length >= 3 && normalized.contains(needle)) {
        found.add(brand);
      }
    }

    return found;
  }

  /// هل النص نظيف؟
  static bool isClean(String text) => scan(text).isEmpty;

  /// إزالة التشكيل + توحيد الألف والياء والهمزة + تصغير + ضغط المسافات
  static String _normalize(String input) {
    String out = input.toLowerCase().trim();
    // إزالة التشكيل العربي (الفتحة حتى السكون + التطويل + همزة الوصل)
    out = out.replaceAll(RegExp(r'[\u064B-\u0652\u0640\u0670]'), '');
    // توحيد أشكال الألف
    out = out.replaceAll(RegExp('[\u0622\u0623\u0625\u0671]'), '\u0627');
    // توحيد الياء والألف المقصورة
    out = out.replaceAll('\u0649', '\u064a');
    // توحيد التاء المربوطة والهاء
    out = out.replaceAll('\u0629', '\u0647');
    // همزة على واو أو ياء
    out = out.replaceAll('\u0624', '\u0648');
    out = out.replaceAll('\u0626', '\u064a');
    // ضغط المسافات
    out = out.replaceAll(RegExp(r'\s+'), ' ');
    return out;
  }
}
