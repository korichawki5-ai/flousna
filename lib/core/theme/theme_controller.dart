import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/local_store.dart';

/// ═══════════════════════════════════════════════════════════════
///  ThemeController — الوضع الفاتح / الداكن / التلقائي
///
///  ✅ الثلاثة مدعومة عبر Design Tokens — لا قيم ألوان مكررة.
/// ═══════════════════════════════════════════════════════════════

/// مُشغّل المظهر
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final LocalStore store = ref.watch(localStorageProvider);
    return store.themeMode;
  }

  /// يضبط وضعاً محدداً ويحفظه
  Future<void> setMode(ThemeMode mode) async {
    final LocalStore store = ref.read(localStorageProvider);
    await store.setThemeMode(mode);
    state = mode;
  }

  Future<void> setLight() => setMode(ThemeMode.light);
  Future<void> setDark() => setMode(ThemeMode.dark);
  Future<void> setSystem() => setMode(ThemeMode.system);

  /// يبدّل بين الفاتح والداكن (تجاهل التلقائي)
  Future<void> toggle(Brightness platformBrightness) {
    final bool isDarkNow = state == ThemeMode.dark ||
        (state == ThemeMode.system && platformBrightness == Brightness.dark);
    return setMode(isDarkNow ? ThemeMode.light : ThemeMode.dark);
  }
}

/// مزوّد وضع المظهر
final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
