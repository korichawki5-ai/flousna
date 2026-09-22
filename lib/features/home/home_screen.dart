import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/clock_guard.dart';
import '../../core/utils/money.dart';
import '../../core/utils/period_resolver.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/db/db.dart';
import '../../data/local/local_store.dart';
import '../transactions/budget_alert_banner.dart';
import '../transactions/tx_tile.dart';

/// ═══════════════════════════════════════════════════════════════
///  HomeScreen — لوحة التحكم
///
///  ✅ الحالات الخمس مطبَّقة (قاعدة المرحلة 3 — النقطة 3):
///     هذه الشاشة في **حالة «فارغة»** في المرحلة 1، وهي مبنية
///     بالكامل: رسمة + رسالة + توجيه نحو الإجراء الصحيح.
///
///  ⭐ ما يعمل فعلاً في هذه المرحلة:
///     - لافتة العدّ التنازلي للتجربة (بـ ClockGuard — مقاومة
///       للتلاعب بالساعة)
///     - حساب الفترة المالية الحالية (Cycle مرنة: شهري/أسبوعي)
///     - عرض الأرقام بخط Mono وباتجاه صحيح
///
///  ⭐ م2.2: لافتة تنبيه السقوف (اقتراب/تجاوز) تنقل بضغطة إلى
///     الميزانية — التنبيه قبل نفاد المال لا بعده.
///
///  🟡 ما يأتي في م2.2 التالية: الديون والأهداف والمتكررات
/// ═══════════════════════════════════════════════════════════════
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final LocalStore store = ref.watch(localStorageProvider);

    // ⭐ الوقت من حارس الساعة — يقاوم إرجاع ساعة الجهاز
    final ClockGuard clock = ref.watch(clockGuardProvider);

    // ── الفترة المالية الحالية (دورة مرنة) ──
    final BudgetMode mode = store.budgetMode;
    final PeriodResolution period = PeriodResolver.resolve(
      now: clock.trustedNow(),
      mode: mode,
      anchorDay: store.fiscalAnchorDay,
    );

    // ── العدّ التنازلي للتجربة ──
    final DateTime? trialEnds = store.trialEndsAt;
    final int trialDaysLeft = trialEnds == null
        ? AppConstantsTrial.fallbackDays
        : clock.daysUntil(trialEnds);
    final bool trialActive = trialDaysLeft > 0;

    return ScreenScaffold(
      scrollable: true,
      header: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.spaceLg,
          vertical: AppTokens.spaceSm,
        ),
        child: _buildBanners(
          context,
          ref,
          l10n,
          store,
          period.primary,
          trialActive,
          trialDaysLeft,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── التحية ──
          Text(
            l10n.homeGreeting,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.spaceXs),

          // ── الفترة الحالية ──
          Text(
            _periodLabel(context, period.primary),
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),

          // ── بطاقة الرصيد: بيانات حقيقية ──
          ref.watch(periodSummaryProvider((
            startMs: period.primary.start.millisecondsSinceEpoch,
            endMs: period.primary.end.millisecondsSinceEpoch,
          ))).when(
            loading: () => const _BalanceCard(
              balance: Money.zero(),
              income: Money.zero(),
              expenses: Money.zero(),
              periodLabel: '',
            ),
            error: (Object e, _) => const _BalanceCard(
              balance: Money.zero(),
              income: Money.zero(),
              expenses: Money.zero(),
              periodLabel: '',
            ),
            data: (PeriodSummary s) => _BalanceCard(
              balance: s.remaining,
              income: s.income,
              expenses: s.expenses,
              periodLabel: l10n.homeThisPeriod,
            ),
          ),

          const SizedBox(height: AppTokens.spaceXl),

          // ── آخر الحركات: بيانات حقيقية ──
          SectionHeader(
            title: l10n.homeRecentTransactions,
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: AppTokens.spaceSm),
          ref.watch(recentProvider(5)).when(
            loading: () => const AppCard(
              padding: AppTokens.spaceSm,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, _) => AppCard(
              padding: AppTokens.spaceSm,
              child: Text('$e'),
            ),
            data: (List<Transaction> recent) {
              if (recent.isEmpty) {
                return AppCard(
                  padding: AppTokens.spaceSm,
                  child: EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: l10n.homeEmptyTitle,
                    message: l10n.homeEmptyBody,
                    actionLabel: l10n.homeEmptyAction,
                    onAction: () => context.push(RoutePaths.addTransaction),
                    compact: true,
                  ),
                );
              }
              return AppCard(
                padding: AppTokens.spaceSm,
                child: Column(
                  children: <Widget>[
                    for (final Transaction tx in recent)
                      TransactionTile(
                        transaction: tx,
                        arabic: Localizations.localeOf(context).languageCode == 'ar',
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppTokens.spaceXxl),
          const SizedBox(height: AppTokens.fabSize),
        ],
      ),
    );
  }

  Widget _buildBanners(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LocalStore store,
    FiscalPeriod period,
    bool trialActive,
    int trialDaysLeft,
  ) {
    final List<Widget> banners = <Widget>[
      // لافتة السقوف — الأولوية القصوى: مال ينفد، لا معلومة عامة
      BudgetAlertBanner(
        period: period,
        onReview: () => context.go(RoutePaths.budget),
      ),
    ];

    // لافتة وضع الضيف
    if (store.isGuestMode) {
      banners.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
          child: InfoBanner(
            icon: Icons.person_outline_rounded,
            message: l10n.authGuestBadge,
            tone: InfoBannerTone.neutral,
          ),
        ),
      );
    }

    // لافتة العد التنازلي للتجربة
    if (trialActive && trialDaysLeft <= AppConstantsTrial.warnAtDays) {
      banners.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
          child: InfoBanner(
            icon: Icons.hourglass_bottom_rounded,
            message: l10n.homeTrialBanner(l10n.dayCountLabel(trialDaysLeft)),
            tone: trialDaysLeft <= 2
                ? InfoBannerTone.warning
                : InfoBannerTone.info,
          ),
        ),
      );
    }

    if (banners.isEmpty) return const SizedBox.shrink();
    return Column(children: banners);
  }

  /// label الفترة بالعربية أو الفرنسية
  String _periodLabel(BuildContext context, FiscalPeriod period) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String range =
        '${period.start.day}/${period.start.month} — ${period.end.day}/${period.end.month}';
    final String modeName = switch (period.mode) {
      BudgetMode.weekly => l10n.settingsBudgetModeWeekly,
      BudgetMode.monthly => l10n.settingsBudgetModeMonthly,
      BudgetMode.both => l10n.settingsBudgetModeBoth,
    };
    return '$modeName · $range';
  }
}

/// ثوابت تجربة المستخدم للافتة التجربة
abstract final class AppConstantsTrial {
  /// أيام قبل النهاية نبدأ فيها التنبيه
  static const int warnAtDays = 7;

  /// قيمة احتياطية إن لم يُسجَّل بدء التجربة
  static const int fallbackDays = AppTokens.trialDays;
}

/// بطاقة الرصيد — تعرض المبلغ بخط Mono وباتجاه صحيح
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expenses,
    required this.periodLabel,
  });

  final Money balance;
  final Money income;
  final Money expenses;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return AppCard(
      padding: AppTokens.spaceXl,
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── الرصيد ──
          Text(
            l10n.homeBalance,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: MoneyText(
              amount: balance,
              size: MoneyTextSize.display,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            periodLabel,
            style: AppTypography.monoSmall.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: AppTokens.spaceXl),

          // ── الدخل مقابل المصروف ──
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStat(
                  icon: Icons.south_west_rounded,
                  label: l10n.homeIncome,
                  amount: income,
                  color: const Color(0xFF2E7D32),
                  positive: true,
                ),
              ),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: _MiniStat(
                  icon: Icons.north_east_rounded,
                  label: l10n.homeExpenses,
                  amount: expenses,
                  color: const Color(0xFFC62828),
                  positive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// إحصاء مصغّر — ⚠️ أيقونة اتجاه + لون (لا اللون وحده، WCAG 1.4.1)
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.positive,
  });

  final IconData icon;
  final String label;
  final Money amount;
  final Color color;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppTokens.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.55),
        borderRadius: AppTokens.fieldRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppTokens.spaceXs),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceXs),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: MoneyText(
              amount: amount,
              size: MoneyTextSize.small,
              color: color,
              withDecimals: false,
            ),
          ),
        ],
      ),
    );
  }
}
