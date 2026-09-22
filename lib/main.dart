import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/config/constants.dart';
import 'core/utils/clock_guard.dart';
import 'data/local/local_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  نقطة الدخول — فلوسنا
///
///  ⚠️ ترتيب الإقلاع مهم ولا يُغيَّر:
///    1. WidgetsFlutterBinding  — ربط المحرك
///    2. LocalStore.init()      — التخزين المحلي (قبل أي UI)
///    3. ضبط نافذة Windows      — سطح المكتب فقط
///    4. ProviderScope + override — حقن التخزين
///    5. runApp                 — الإقلاع
///
///  ✅ التطبيق يعمل كاملاً في هذه المرحلة **بدون إنترنت وبدون حساب**
///     (Offline-first + «جرّب بدون حساب») — لا Supabase بعد.
///     ربط الخادم يأتي في المرحلة 3.
/// ═══════════════════════════════════════════════════════════════
Future<void> main() async {
  // 1) ربط المحرك — إلزامي قبل أي استدعاء async لمنصة
  WidgetsFlutterBinding.ensureInitialized();

  // 2) التخزين المحلي + حارس الساعة — فشل هنا = لا يمكن الإقلاع
  final LocalStore store;
  final ClockGuard clock;
  try {
    store = await LocalStore.init();
    clock = await ClockGuard.create();
    // ⚠️ الالتقاط الشامل هنا مقصود: فشل التخزين المحلي يمنع الإقلاع
    //    كلياً، فنعرض شاشة طوارئ بدل انهيار صامت.
    // ignore: avoid_catching_errors
  } on Object catch (error, stackTrace) {
    // 🔴 لا نعرض stack trace للمستخدم — نسجّله ونشغّل بديل الطوارئ
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'main',
        context: ErrorDescription('تهيئة التخزين المحلي'),
      ),
    );
    runApp(const _FatalStartupErrorApp());
    return;
  }

  // 3) ضبط نافذة Windows (سطح المكتب فقط)
  await _configureDesktopWindow();

  // 4 + 5) الإقلاع مع حقن التخزين المحلي
  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(store),
        clockGuardProvider.overrideWithValue(clock),
      ],
      child: const FalousnaApp(),
    ),
  );
}

/// يضبط نافذة تطبيق سطح المكتب (Windows)
///
/// على الهاتف والويب هذه الدالة لا تفعل شيئاً.
Future<void> _configureDesktopWindow() async {
  final bool isDesktop = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  if (!isDesktop) return;

  // فشل ضبط النافذة ليس خطأً قاتلاً — التطبيق يعمل بدونه
  try {
    await windowManager.ensureInitialized();

    const WindowOptions options = WindowOptions(
      size: Size(420, 860),
      minimumSize: Size(380, 640),
      center: true,
      skipTaskbar: false,
      title: 'فلوسنا — Falousna',
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setTitle('${AppConstants.appName} — ${AppConstants.appNameLatin}');
      await windowManager.setMinimumSize(const Size(380, 640));
      await windowManager.show();
      await windowManager.focus();
    });
  } on Exception catch (error) {
    // نسجّل ولا نوقف الإقلاع
    debugPrint('⚠️ تعذّر ضبط نافذة سطح المكتب: $error');
  }
}

/// ═══════════════════════════════════════════════════════════════
///  شاشة الطوارئ — إن فشل التخزين المحلي
///
///  ⚠️ قاعدة: ممنوع شاشة بيضاء أو انهيار صامت.
///  هذه الشاشة تعمل بلا أي تبعية (لا Riverpod، لا l10n) لأنها
///  تظهر عندما تفشل البنية الأساسية.
/// ═══════════════════════════════════════════════════════════════
class _FatalStartupErrorApp extends StatelessWidget {
  const _FatalStartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFFAFAF7),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9DEDC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storage_rounded,
                      size: 44,
                      color: Color(0xFF410E0B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'تعذّر بدء التشغيل',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C19),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'لم يستطع التطبيق الوصول إلى مساحة التخزين في جهازك.\n\n'
                    'جرّب إغلاق التطبيق وفتحه مرة أخرى. '
                    'إن تكررت المشكلة، تحقق من أن مساحة التخزين في جهازك غير ممتلئة.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Color(0xFF49454F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Impossible de démarrer — l\'espace de stockage est inaccessible.\n'
                    'Fermez et rouvrez l\'application, puis vérifiez l\'espace disponible.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF79747E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
