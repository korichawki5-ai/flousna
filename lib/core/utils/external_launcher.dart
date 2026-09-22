import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../errors/app_error.dart';
import 'result.dart';

/// ═══════════════════════════════════════════════════════════════
///  ExternalLauncher — فتح الروابط الخارجية بأمان
///
///  ✅ كل فتح رابط يمرّ من هنا حتى:
///     1. لا ينهار التطبيق إن لم يوجد متصفح/تطبيق واتساب
///     2. تصل المستخدم رسالة مفهومة بدل استثناء صامت
///     3. يبقى هناك **حل بديل**: نسخ الرابط إلى الحافظة
///
///  ⚠️ لا نعد المستخدم بأن الرابط «سيفتح» — نفحص `canLaunchUrl`
///     أولاً، ونعيد `Result` لا استثناءً.
/// ═══════════════════════════════════════════════════════════════
abstract final class ExternalLauncher {
  /// يفتح رابطاً في التطبيق الخارجي المناسب
  ///
  /// يعيد `Ok(true)` عند النجاح، و`Err(AppError)` عند الفشل مع
  /// تسجيل السبب التقني في `logOnly` (لا يظهر للمستخدم).
  static Future<Result<bool, AppError>> open(
    Uri uri, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      final bool supported = await canLaunchUrl(uri);
      if (!supported) {
        return Result<bool, AppError>.failure(
          AppError(
            kind: AppErrorKind.permission,
            messageKey: 'errorPermissionBody',
            titleKey: 'errorPermissionTitle',
            logOnly: 'canLaunchUrl=false for ${uri.scheme}:${uri.host}',
          ),
        );
      }

      final bool launched = await launchUrl(uri, mode: mode);
      if (!launched) {
        return Result<bool, AppError>.failure(
          AppError(
            kind: AppErrorKind.unknown,
            messageKey: 'errorGenericBody',
            titleKey: 'errorGenericTitle',
            logOnly: 'launchUrl returned false for $uri',
          ),
        );
      }
      return const Result<bool, AppError>.success(true);
    } on PlatformException catch (error) {
      return Result<bool, AppError>.failure(
        AppError(
          kind: AppErrorKind.permission,
          messageKey: 'errorPermissionBody',
          titleKey: 'errorPermissionTitle',
          logOnly: 'PlatformException(${error.code}) opening $uri',
        ),
      );
    } on Exception catch (error) {
      return Result<bool, AppError>.failure(
        AppError.unknown(cause: error),
      );
    }
  }

  /// ينسخ نصاً إلى الحافظة — الحل البديل دائماً متاح
  static Future<Result<bool, AppError>> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return const Result<bool, AppError>.success(true);
    } on Exception catch (error) {
      return Result<bool, AppError>.failure(AppError.unknown(cause: error));
    }
  }

  /// يفتح الرابط، وإن فشل ينسخه إلى الحافظة تلقائياً
  ///
  /// يعيد `true` إن فُتح الرابط، و`false` إن نُسخ بدل ذلك.
  /// ⚠️ في الحالتين المستخدم لا يبقى بلا حل.
  static Future<LaunchOutcome> openOrCopy(Uri uri) async {
    final Result<bool, AppError> opened = await open(uri);
    if (opened.isSuccess) return LaunchOutcome.opened;

    // روابط mailto قد تفشل على أجهزة بلا تطبيق بريد —
    // ننسخ العنوان نفسه بدل الرابط الكامل
    final String fallbackText =
        uri.scheme == 'mailto' ? uri.path : uri.toString();

    final Result<bool, AppError> copied = await copyToClipboard(fallbackText);
    return copied.isSuccess ? LaunchOutcome.copied : LaunchOutcome.failed;
  }
}

/// نتيجة محاولة فتح رابط خارجي
enum LaunchOutcome {
  /// فُتح في تطبيق خارجي
  opened,

  /// فشل الفتح ونُسخ النص إلى الحافظة
  copied,

  /// فشل الفتح والنسخ معاً (نادر — جهاز مقفل)
  failed,
}
