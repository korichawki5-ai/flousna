import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/constants.dart';
import '../../core/utils/period_resolver.dart';

/// ═══════════════════════════════════════════════════════════════
///  LocalStore — التخزين المحلي للإعدادات وحالة الجلسة
///
///  ⚠️ هذه الطبقة تعمل **بدون إنترنت وبدون حساب** — وهي أساس
///     وضع Offline-first ووضع «جرّب بدون حساب».
///
///  🔒 القيم الحساسة (رمز الجلسة، معرّف المستخدم) لا تُخزَّن هنا
///     بل في flutter_secure_storage (المرحلة 3).
/// ═══════════════════════════════════════════════════════════════
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  /// تهيئة واحدة عند إقلاع التطبيق — قبل runApp
  static Future<LocalStore> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LocalStore(prefs);
  }

  // ─────────────────────────────────────────────────────────────
  //  الموافقات القانونية (القانون 18-07)
  // ─────────────────────────────────────────────────────────────

  /// هل وافق المستخدم على سياسة الخصوصية والشروط؟
  bool get hasPrivacyConsent => _prefs.getBool(AppConstants.keyConsentGranted) ?? false;

  /// وقت الموافقة
  DateTime? get consentGrantedAt {
    final String? raw = _prefs.getString(AppConstants.keyConsentGrantedAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// إصدار السياسة التي وُوفق عليها
  String? get consentPolicyVersion => _prefs.getString(AppConstants.keyConsentVersion);

  /// بصمة SHA-256 لنص السياسة لحظة الموافقة — الدليل القانوني
  String? get consentHash => _prefs.getString(AppConstants.keyConsentHash);

  /// هل الموافقة صالحة للإصدار الحالي من السياسة؟
  ///
  /// إن رُفع إصدار السياسة → يلزم إعادة الموافقة.
  bool get isConsentCurrent =>
      hasPrivacyConsent && consentPolicyVersion == AppConstants.privacyPolicyVersion;

  /// يسجّل الموافقة
  Future<void> grantPrivacyConsent({required String policyHash}) async {
    await _prefs.setBool(AppConstants.keyConsentGranted, true);
    await _prefs.setString(
      AppConstants.keyConsentGrantedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
    await _prefs.setString(AppConstants.keyConsentVersion, AppConstants.privacyPolicyVersion);
    await _prefs.setString(AppConstants.keyConsentHash, policyHash);
  }

  /// يسحب الموافقة (حق الاعتراض — المادة 36)
  Future<void> revokePrivacyConsent() async {
    await _prefs.setBool(AppConstants.keyConsentGranted, false);
    await _prefs.remove(AppConstants.keyConsentGrantedAt);
    await _prefs.remove(AppConstants.keyConsentVersion);
    await _prefs.remove(AppConstants.keyConsentHash);
  }

  // ─────────────────────────────────────────────────────────────
  //  حالة التشغيل الأول
  // ─────────────────────────────────────────────────────────────

  /// هل أُكمل الـ Onboarding؟
  bool get onboardingDone => _prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

  Future<void> completeOnboarding() =>
      _prefs.setBool(AppConstants.keyOnboardingDone, true);

  /// هل أُكمل الإعداد الأولي السريع؟
  bool get setupDone => _prefs.getBool(AppConstants.keySetupDone) ?? false;

  Future<void> completeSetup() => _prefs.setBool(AppConstants.keySetupDone, true);

  // ─────────────────────────────────────────────────────────────
  //  وضع الضيف (بدون حساب)
  // ─────────────────────────────────────────────────────────────

  /// هل التطبيق في وضع «بدون حساب»؟
  bool get isGuestMode => _prefs.getBool(AppConstants.keyGuestMode) ?? false;

  Future<void> enterGuestMode() async {
    await _prefs.setBool(AppConstants.keyGuestMode, true);
    // بدء التجربة المجانية فوراً
    if (trialStartedAt == null) {
      await _prefs.setString(
        AppConstants.keyTrialStartedAt,
        DateTime.now().toUtc().toIso8601String(),
      );
    }
  }

  /// يخرج من وضع الضيف (عند إنشاء حساب — المرحلة 3)
  Future<void> exitGuestMode() => _prefs.setBool(AppConstants.keyGuestMode, false);

  // ─────────────────────────────────────────────────────────────
  //  التجربة المجانية (7 أيام)
  // ─────────────────────────────────────────────────────────────

  DateTime? get trialStartedAt {
    final String? raw = _prefs.getString(AppConstants.keyTrialStartedAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// نهاية التجربة = البداية + 7 أيام
  DateTime? get trialEndsAt {
    final DateTime? started = trialStartedAt;
    if (started == null) return null;
    return started.add(const Duration(days: AppConstants.trialDays));
  }

  Future<void> startTrial() async {
    if (trialStartedAt != null) return; // لا نعيد الضبط أبداً
    await _prefs.setString(
      AppConstants.keyTrialStartedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  /// معرّف التثبيت الفريد (لمقاومة إعادة ضبط التجربة)
  String? get deviceInstallId => _prefs.getString(AppConstants.keyDeviceInstallId);

  Future<void> setDeviceInstallId(String id) =>
      _prefs.setString(AppConstants.keyDeviceInstallId, id);

  // ─────────────────────────────────────────────────────────────
  //  المظهر واللغة
  // ─────────────────────────────────────────────────────────────

  /// `null` = لغة الجهاز
  Locale? get locale {
    final String? raw = _prefs.getString(AppConstants.keyLocale);
    if (raw == null || raw.isEmpty) return null;
    final List<String> parts = raw.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
  }

  Future<void> setLocale(Locale locale) async {
    final String tag = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    await _prefs.setString(AppConstants.keyLocale, tag);
  }

  Future<void> clearLocale() => _prefs.remove(AppConstants.keyLocale);

  ThemeMode get themeMode {
    final String? raw = _prefs.getString(AppConstants.keyThemeMode);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) => _prefs.setString(
        AppConstants.keyThemeMode,
        switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        },
      );

  // ─────────────────────────────────────────────────────────────
  //  الدورة المالية
  // ─────────────────────────────────────────────────────────────

  /// يوم بداية الشهر المالي (1..28)
  int get fiscalAnchorDay {
    final int raw = _prefs.getInt(AppConstants.keyFiscalAnchorDay) ?? 1;
    return raw.clamp(
      AppConstants.minFiscalAnchorDay,
      AppConstants.maxFiscalAnchorDay,
    );
  }

  Future<void> setFiscalAnchorDay(int day) => _prefs.setInt(
        AppConstants.keyFiscalAnchorDay,
        day.clamp(
          AppConstants.minFiscalAnchorDay,
          AppConstants.maxFiscalAnchorDay,
        ),
      );

  BudgetMode get budgetMode =>
      BudgetMode.fromName(_prefs.getString(AppConstants.keyBudgetMode));

  Future<void> setBudgetMode(BudgetMode mode) =>
      _prefs.setString(AppConstants.keyBudgetMode, mode.name);

  String get baseCurrency =>
      _prefs.getString(AppConstants.keyBaseCurrency) ?? AppConstants.baseCurrency;

  Future<void> setBaseCurrency(String code) =>
      _prefs.setString(AppConstants.keyBaseCurrency, code);

  // ─────────────────────────────────────────────────────────────
  //  المحو الكامل (حق المحو — القانون 18-07)
  // ─────────────────────────────────────────────────────────────

  /// يحذف **كل** ما في التخزين المحلي — لا رجعة.
  ///
  /// ⚠️ يُستدعى فقط بعد تأكيد صريح من المستخدم.
  Future<void> eraseEverything() async {
    await _prefs.clear();
  }
}

/// ⚠️ مزوّد مؤقت — يُستبدل بالقيمة الحقيقية في main.dart عبر override
///
/// هذا النمط يسمح باختبار الكود بدون SharedPreferences حقيقي.
final localStorageProvider = Provider<LocalStore>(
  (Ref ref) => throw UnimplementedError(
    'localStorageProvider يجب تجاوزه في main.dart عبر ProviderScope(overrides: ...)',
  ),
);
