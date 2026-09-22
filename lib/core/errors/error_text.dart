// ═══════════════════════════════════════════════════════════════
//  error_text.dart — ترجمة الأخطاء إلى رسالة عربية/فرنسية مقروءة
//
//  ❓ المشكلة: المستودعات تُعيد AppError يحمل **مفتاح ترجمة**
//     (مثل `validateAmountZero`) لا نصاً جاهزاً — وهذا صحيح
//     (طبقة البيانات لا تعرف لغة الواجهة). لكن الشاشات كانت تعرض
//     المفتاح الخام للمستخدم أحياناً، أو تكتفي برسالة عامة.
//
//  ✅ الحل: مكان واحد يحوّل المفتاح إلى نص مترجم، مع **سقوط آمن**
//     إلى رسالة عامة صريحة (لا نص فارغ، لا مفتاح خام، لا استثناء).
//     لو أضفت مفتاحاً جديداً في المستودع فاذكره هنا — وإن نسيت،
//     يظهر للمستخدم نص عام مفهوم بدل `validateSomething`.
// ═══════════════════════════════════════════════════════════════
import 'package:falousna/l10n/app_localizations.dart';

import '../config/constants.dart';
import 'app_error.dart';

abstract final class ErrorText {
  /// رسالة صالحة للعرض من أي [AppError]
  static String of(AppLocalizations l10n, AppError error) =>
      fromKey(l10n, error.messageKey);

  /// تحويل مفتاح خطأ إلى نص — السقوط الآمن رسالة عامة صريحة
  static String fromKey(AppLocalizations l10n, String key) => switch (key) {
        // ── التحقق من المدخلات ──
        'validateRequired' => l10n.validateRequired,
        'validateAmountZero' => l10n.validateAmountZero,
        // ⚠️ هذا المفتاح يأخذ معاملاً: نمرّر حدّ اسم الفئة المخصصة
        //    (المكان الوحيد الذي يُنتجه اليوم) فلا يظهر نص ناقص.
        'validateTooLong' => l10n.validateTooLong(AppConstants.maxCategoryNameLength),
        // ── الفئات ──
        'catMgrDuplicate' => l10n.catMgrDuplicate,
        // ── السقوف ──
        'budgetAlertRange' => l10n.budgetAlertRange,
        'budgetNotFound' => l10n.budgetNotFound,
        // ── عام (الحالة الافتراضية) ──
        _ => l10n.errorGenericBody,
      };
}
