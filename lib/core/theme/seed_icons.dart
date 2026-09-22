import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  SeedIcons — تحويل أسماء الأيقونات (نصوص) إلى IconData
///
///  ⭐ لماذا أسماء نصية أصلاً؟
///     ملفات البذرة (JSON) وقاعدة البيانات تخزّن اسم الأيقونة كنص،
///     لأن IconData لا يمكن تخزينه ولا إرساله عبر الشبكة.
///     هذا الملف هو **الجسر الوحيد** بين النص وMaterial Icons.
///
///  ⚠️ أي اسم غير معروف يعيد أيقونة افتراضية (`category`) ولا يرمي
///     استثناءً أبداً — شاشة التصنيفات لا يجب أن تنهار بسبب أيقونة.
/// ═══════════════════════════════════════════════════════════════
abstract final class SeedIcons {
  /// الأيقونة الافتراضية عند اسم غير معروف
  static const IconData fallback = Icons.category_outlined;

  /// الجدول الكامل — ⚠️ يجب أن يغطّي كل أسماء `SeedCategories`
  /// (يتحقق من ذلك `seed_consistency_test.dart`)
  static const Map<String, IconData> table = <String, IconData>{
    // ── المصاريف ──
    'restaurant': Icons.restaurant_rounded,
    'directions_bus': Icons.directions_bus_rounded,
    'home': Icons.home_rounded,
    'bolt': Icons.bolt_rounded,
    'water_drop': Icons.water_drop_rounded,
    'wifi': Icons.wifi_rounded,
    'medical_services': Icons.medical_services_rounded,
    'school': Icons.school_rounded,
    'checkroom': Icons.checkroom_rounded,
    'family_restroom': Icons.family_restroom_rounded,
    'volunteer_activism': Icons.volunteer_activism_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
    'local_cafe': Icons.local_cafe_rounded,
    'flight': Icons.flight_rounded,
    'handyman': Icons.handyman_rounded,
    'subscriptions': Icons.subscriptions_rounded,
    'currency_exchange': Icons.currency_exchange_rounded,
    'more_horiz': Icons.more_horiz_rounded,

    // ── المداخيل ──
    'payments': Icons.payments_rounded,
    'construction': Icons.construction_rounded,
    'laptop_mac': Icons.laptop_mac_rounded,
    'storefront': Icons.storefront_rounded,
    'workspace_premium': Icons.workspace_premium_rounded,
    'elderly': Icons.elderly_rounded,
    'handshake': Icons.handshake_rounded,

    // ── المناسبات الموسمية ──
    'mosque': Icons.mosque_rounded,
    'celebration': Icons.celebration_rounded,
    'event': Icons.event_rounded,
    'backpack': Icons.backpack_rounded,
    'beach_access': Icons.beach_access_rounded,
    'ac_unit': Icons.ac_unit_rounded,
    'savings': Icons.savings_rounded,

    // ── واجهات التطبيق ──
    'category': Icons.category_rounded,
    'insights': Icons.insights_rounded,
    'repeat': Icons.repeat_rounded,
    'goal': Icons.flag_rounded,
    'debt': Icons.swap_vert_rounded,
    'report': Icons.assessment_rounded,
  };

  /// يعيد الأيقونة المطابقة للاسم، أو [fallback]
  static IconData fromName(String? name) {
    if (name == null) return fallback;
    return table[name] ?? fallback;
  }

  /// هل الاسم معروف في الجدول؟ (يستعملها الاختبار)
  static bool isKnown(String name) => table.containsKey(name);

  /// كل الأسماء المعروفة
  static List<String> get knownNames => table.keys.toList();
}
