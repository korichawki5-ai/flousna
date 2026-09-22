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
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/db/db.dart';
import '../../data/local/local_store.dart';
import '../../data/seed/seed_categories.dart';
import 'tx_tile.dart';

/// ═══════════════════════════════════════════════════════════════
///  TransactionsScreen — قائمة الحركات
///
///  ✅ مبنيّة بالكامل في المرحلة 1: التصفية والبحث والفرز تعمل
///     فعلياً على الحالة المحلية، والقائمة في **حالة فارغة**
///     لأن الحركات تُخزَّن في قاعدة البيانات ابتداءً من المرحلة 2.
///
///  ⭐ الحالات الخمس (قاعدة المرحلة 3):
///     فارغة ← معروضة الآن · تحميل ← في المرحلة 2 · خطأ ← كذلك
///     · بيانات ← كذلك · بلا إنترنت ← التطبيق أصلاً offline-first
/// ═══════════════════════════════════════════════════════════════
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

/// تصفية نوع الحركة
enum TransactionFilter { all, income, expense }

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionFilter _filter = TransactionFilter.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final LocalStore store = ref.watch(localStorageProvider);

    // ⭐ الوقت من حارس الساعة (مقاومة التلاعب)
    final PeriodResolution period = PeriodResolver.resolve(
      now: ref.watch(clockGuardProvider).trustedNow(),
      mode: store.budgetMode,
      anchorDay: store.fiscalAnchorDay,
    );

    return ScreenScaffold(
      title: l10n.navTransactions,
      // ⚠️ scrollable: false إلزامي هنا: الجسم يحوي Expanded لقائمة
      //    الحركات، وExpanded داخل تمرير بلا حدّ ارتفاع = انهيار تخطيط
      //    («RenderFlex children have non-zero flex but incoming height
      //    constraints are unbounded») — عطل اكتشفه اختبار التنقل.
      //    الشاشة تدير تمريرها بنفسها داخل القائمة (lazy loading).
      scrollable: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ── الفترة الحالية ──
          Text(
            _periodLabel(context, period.primary),
            style: AppTypography.monoSmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),

          // ── الإجماليات: بيانات حقيقية ──
          ref.watch(periodSummaryProvider((
            startMs: period.primary.start.millisecondsSinceEpoch,
            endMs: period.primary.end.millisecondsSinceEpoch,
          ))).when(
            loading: () => const AppCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object e, _) => AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.spaceMd),
                child: Text('$e'),
              ),
            ),
            data: (PeriodSummary summary) => AppCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _TotalColumn(
                      label: l10n.txTotalIncome,
                      amount: summary.income,
                      color: AppTokens.semanticIncome,
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  SizedBox(
                    width: 1,
                    height: 44,
                    child: ColoredBox(color: scheme.outlineVariant),
                  ),
                  Expanded(
                    child: _TotalColumn(
                      label: l10n.txTotalExpense,
                      amount: summary.expenses,
                      color: AppTokens.semanticExpense,
                      icon: Icons.trending_down_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTokens.spaceLg),

          // ── البحث ──
          AppTextField(
            label: l10n.actionSearch,
            hint: l10n.txSearchHint,
            fieldType: AppFieldType.text,
            prefixIcon: Icons.search_rounded,
            onChanged: (String value) => setState(() => _query = value),
            semanticLabel: l10n.txSearchHint,
          ),

          const SizedBox(height: AppTokens.spaceMd),

          // ── التصفية ──
          _FilterRow(
            filter: _filter,
            onChanged: (TransactionFilter value) =>
                setState(() => _filter = value),
          ),

          const SizedBox(height: AppTokens.spaceSm),

          // ── قائمة الحركات: بيانات حقيقية ──
          Expanded(
            child: _TxList(
              period: period.primary,
              filter: _filter,
              query: _query,
            ),
          ),

          const SizedBox(height: AppTokens.spaceLg),


          const SizedBox(height: AppTokens.spaceXxl),
          const SizedBox(height: AppTokens.fabSize),
        ],
      ),
    );
  }

  String _periodLabel(BuildContext context, FiscalPeriod period) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String modeName = switch (period.mode) {
      BudgetMode.weekly => l10n.settingsBudgetModeWeekly,
      BudgetMode.monthly => l10n.settingsBudgetModeMonthly,
      BudgetMode.both => l10n.settingsBudgetModeBoth,
    };
    return '$modeName · ${period.start.day}/${period.start.month} — '
        '${period.end.day}/${period.end.month}';
  }
}

/// قائمة الحركات — مراقبة/providers مع تصفية وبحث
class _TxList extends ConsumerWidget {
  const _TxList({required this.period, required this.filter, required this.query});

  final FiscalPeriod period;
  final TransactionFilter filter;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';
    final int startMs = period.start.millisecondsSinceEpoch;
    final int endMs = period.end.millisecondsSinceEpoch;

    final String? kindName = switch (filter) {
      TransactionFilter.income => SeedCategoryKind.income.name,
      TransactionFilter.expense => SeedCategoryKind.expense.name,
      _ => null,
    };

    final categoriesAsync = ref.watch(categoriesProvider(SeedCategoryKind.expense));
    final incomeCatsAsync = ref.watch(categoriesProvider(SeedCategoryKind.income));

    // خريطة المعرّفات ↔ الفئات
    final Map<String, CategoryView> catMap = <String, CategoryView>{};
    categoriesAsync.whenData(
      (List<CategoryView> views) => catMap.addEntries(
        views.map((CategoryView v) => MapEntry<String, CategoryView>(v.id, v)),
      ),
    );
    incomeCatsAsync.whenData(
      (List<CategoryView> views) => catMap.addEntries(
        views.map((CategoryView v) => MapEntry<String, CategoryView>(v.id, v)),
      ),
    );

    // فئات مخصصة مطابقة للاستعلام
    final String q = query.trim();

    final AsyncValue<List<Transaction>> txsAsync = ref.watch(
      transactionsProvider((
        startMs: startMs,
        endMs: endMs,
        kindName: kindName,
        noteQuery: q.isEmpty ? null : q,
        categoryIds: null,
        limit: null,
      )),
    );

    return txsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, _) => Center(child: Text('$e')),
      data: (List<Transaction> rows) {
        if (rows.isEmpty) {
          return AppCard(
            padding: AppTokens.spaceSm,
            child: EmptyState(
              icon: Icons.receipt_long_rounded,
              title: q.isEmpty ? l10n.txEmptyTitle : l10n.txNoResults,
              message: l10n.txEmptyBody,
              actionLabel: l10n.navAdd,
              onAction: () => context.push(RoutePaths.addTransaction),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsetsDirectional.only(top: AppTokens.spaceSm),
          itemCount: rows.length,
          itemBuilder: (BuildContext context, int index) {
            final Transaction tx = rows[index];
            return TransactionTile(
              transaction: tx,
              category: catMap[tx.categoryId],
              arabic: arabic,
            );
          },
        );
      },
    );
  }
}

/// عمود إجمالي (دخل أو مصروف)
class _TotalColumn extends StatelessWidget {
  const _TotalColumn({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final Money amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 15, color: color),
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
            size: MoneyTextSize.medium,
            color: color,
            withDecimals: false,
          ),
        ),
      ],
    );
  }
}

/// صف التصفية — الكل / دخل / مصروف
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.filter, required this.onChanged});

  final TransactionFilter filter;
  final ValueChanged<TransactionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SegmentedButton<TransactionFilter>(
      segments: <ButtonSegment<TransactionFilter>>[
        ButtonSegment<TransactionFilter>(
          value: TransactionFilter.all,
          label: Text(l10n.txFilterAll),
        ),
        ButtonSegment<TransactionFilter>(
          value: TransactionFilter.income,
          label: Text(l10n.incomeKind),
          icon: const Icon(Icons.trending_up_rounded, size: 16),
        ),
        ButtonSegment<TransactionFilter>(
          value: TransactionFilter.expense,
          label: Text(l10n.expenseKind),
          icon: const Icon(Icons.trending_down_rounded, size: 16),
        ),
      ],
      selected: <TransactionFilter>{filter},
      onSelectionChanged: (Set<TransactionFilter> selection) =>
          onChanged(selection.first),
      showSelectedIcon: false,
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll<Size>(
          Size(0, AppTokens.minTouchTarget),
        ),
      ),
    );
  }
}
