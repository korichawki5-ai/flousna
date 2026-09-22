import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppShell — الهيكل الرئيسي مع التنقل السفلي
///
///  ✅ القواعد المطبَّقة (المرحلة 3 — النقطة 6):
///     - Bottom Navigation: **4 وجهات** + زر إجراء عائم في الوسط
///       (الحد الأقصى 5 — نحن ضمنه)
///     - ⭐ زر «إضافة» **إجراء لا وجهة** — لذلك FAB عائم وليس فرعاً
///       في الـ NavigationBar. هذا النمط يمنع ضياع حالة الفرع.
///     - FAB في Thumb Zone (أسفل الوسط) —reachable بالإبهام
///     - IndexedStack عبر StatefulShellRoute → كل فرع يحتفظ بحالته
///       وموضع تمريره عند التبديل (لا إعادة بناء)
///     - ارتفاع الشريط 80dp · أيقونات 24dp · هدف لمس ≥ 48dp
/// ═══════════════════════════════════════════════════════════════
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  /// هيكل التنقل ذو الفروع من go_router
  final StatefulNavigationShell navigationShell;

  /// 🔴 خريطة **مقعد الشريط ← رقم الفرع** — إلزامية لا تجميلية.
  ///
  /// مقعد الزر العائم (رقم 2) مقعد فاضٍ بلا فرع، فبدون هذه الإزاحة
  /// يفتح الضغط على «الميزانية» فرع «المزيد» — و«المزيد» لا يفتح
  /// شيئاً. كانت عطلاً حقيقياً اكتشفه اختبار التنقل (22/09/2026).
  static const List<int?> _branchOfSeat = <int?>[0, 1, null, 2, 3];

  /// موضع الفرع الحالي في الشريط (لعرض المقعد النشط صحيحاً)
  static const List<int> _seatOfBranch = <int>[0, 1, 3, 4];

  void _onSeatSelected(int seat) {
    final int? branch =
        seat >= 0 && seat < _branchOfSeat.length ? _branchOfSeat[seat] : null;
    if (branch == null) return; // المقعد الفاضي: لا فرع له
    navigationShell.goBranch(
      branch,
      // النقر على الفرع النشط يعيده إلى جذره (سلوك متوقع)
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  void _openAddTransaction(BuildContext context) {
    // مسار كامل فوق الهيكل — يحافظ على حالة الفرع الحالي
    context.push(RoutePaths.addTransaction);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // المقعد المُبرَز = مقعد الفرع الحالي (لا رقم الفرع نفسه)
    final int current = _seatOfBranch[navigationShell.currentIndex];

    return Scaffold(
      body: navigationShell,

      // ── شريط التنقل السفلي ──
      bottomNavigationBar: NavigationBar(
        selectedIndex: current,
        onDestinationSelected: _onSeatSelected,
        height: AppTokens.bottomNavHeight,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
            tooltip: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n.navTransactions,
            tooltip: l10n.navTransactions,
          ),

          // ⭐ مقعد زر الإضافة — فارغ بصرياً لأن FAB يطفو فوقه
          NavigationDestination(
            icon: const SizedBox(
              width: AppTokens.fabSize,
              height: AppTokens.fabSize,
            ),
            label: '',
            // لا tooltip — الزر الفعلي هو الـ FAB وله تسميته الخاصة
            tooltip: l10n.navAdd,
            enabled: false,
          ),

          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: const Icon(Icons.pie_chart_rounded),
            label: l10n.navBudget,
            tooltip: l10n.navBudget,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_rounded),
            selectedIcon: const Icon(Icons.more_horiz_rounded),
            label: l10n.navMore,
            tooltip: l10n.navMore,
          ),
        ],
      ),

      // ── زر الإضافة العائم ──
      floatingActionButton: Semantics(
        button: true,
        label: l10n.navAdd,
        child: FloatingActionButton(
          onPressed: () => _openAddTransaction(context),
          // ⭐ مرفوع فوق الشريط ليظهر كزر مركزي مميز (Von Restorff)
          elevation: 3,
          highlightElevation: 6,
          tooltip: l10n.navAdd,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
