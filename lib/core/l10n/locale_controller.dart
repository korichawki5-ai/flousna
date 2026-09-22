import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/local_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  LocaleController — التحكم في اللغة والاتجاه
///
///  ⚠️ الاتجاه (RTL/LTR) يُشتق تلقائياً من اللغة — لا يُضبط يدوياً.
///     Flutter يقلب كل شيء عبر Directionality عند Locale('ar').
///
///  ✅ النمط: `followsSystem` علم صريح بدل الاعتماد على null —
///     أوضح وأقل عرضة للأخطاء.
/// ═══════════════════════════════════════════════════════════════

/// اللغات المدعومة — العربية هي الأساسية
const List<Locale> kSupportedLocales = <Locale>[
  Locale('ar', 'DZ'),
  Locale('fr', 'DZ'),
];

/// اللغة الافتراضية عند عدم وجود تفضيل أو تطابق
const Locale kDefaultLocale = Locale('ar', 'DZ');

/// حالة اللغة الحالية
class LocaleState {
  const LocaleState({
    required this.followsSystem,
    required this.choice,
    required this.effective,
  });

  /// هل يتبع لغة الجهاز؟
  final bool followsSystem;

  /// ما اختاره المستخدم (يُحفظ حتى لو يتبع النظام حالياً)
  final Locale? choice;

  /// اللغة الفعلية المطبّقة الآن
  final Locale effective;

  /// هل الواجهة عربية (RTL)؟
  bool get isRtl => effective.languageCode == 'ar';

  /// هل الواجهة فرنسية (LTR)؟
  bool get isLtr => !isRtl;

  /// اسم اللغة للعرض
  String get languageName => switch (effective.languageCode) {
        'ar' => 'العربية',
        'fr' => 'Français',
        _ => effective.languageCode,
      };
}

/// مُشغّل اللغة
class LocaleController extends Notifier<LocaleState> {
  @override
  LocaleState build() {
    final LocalStore store = ref.watch(localStorageProvider);
    final Locale? saved = store.locale;
    return LocaleState(
      followsSystem: saved == null,
      choice: saved,
      effective: saved ?? kDefaultLocale,
    );
  }

  /// يضبط لغة محددة
  Future<void> setLocale(Locale locale) async {
    final LocalStore store = ref.read(localStorageProvider);
    await store.setLocale(locale);
    state = LocaleState(
      followsSystem: false,
      choice: locale,
      effective: locale,
    );
  }

  /// يعود إلى لغة الجهاز
  Future<void> followSystem() async {
    final LocalStore store = ref.read(localStorageProvider);
    await store.clearLocale();
    state = LocaleState(
      followsSystem: true,
      choice: null,
      effective: kDefaultLocale,
    );
  }

  /// يحلّ اللغة الفعلية من لغة النظام — يُستدعى من app.dart
  ///
  /// يطابق على رمز اللغة فقط، فتعمل ar_EG و ar_MA كـ ar_DZ.
  Locale resolveFromPlatform(Locale? platformLocale) {
    if (!state.followsSystem && state.choice != null) return state.choice!;
    if (platformLocale == null) return kDefaultLocale;

    for (final Locale supported in kSupportedLocales) {
      if (supported.languageCode == platformLocale.languageCode) {
        return supported;
      }
    }
    return kDefaultLocale;
  }
}

/// مزوّد حالة اللغة
final localeControllerProvider =
    NotifierProvider<LocaleController, LocaleState>(LocaleController.new);

/// هل الواجهة RTL؟ — يُستعمل لعكس الأيقونات والمحاور
final isRtlProvider = Provider<bool>((Ref ref) => ref.watch(localeControllerProvider).isRtl);

/// اللغة الفعلية المطبّقة
final effectiveLocaleProvider =
    Provider<Locale>((Ref ref) => ref.watch(localeControllerProvider).effective);
