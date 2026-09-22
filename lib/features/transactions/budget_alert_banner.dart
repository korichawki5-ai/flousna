// ═══════════════════════════════════════════════════════════════
//  budget_alert_banner.dart — تنبيه السقوف داخل التطبيق
//
//  ⭐ القاعدة: التنبيه يأتي **قبل** نفاد المال لا بعده.
//     يظهر على الرئيسية حين يبلغ أي سقف نسبة التنبيه التي
//     اختارها المستخدم، أو يتجاوزه.
//
//  ✅ تنبيه حقيقي مبني على قاعدة صريحة (لا «ذكاء» غامض):
//       - الحالة من `BudgetProgress.status` (معادلة موثّقة)
//       - الأشدّ أولاً: المتجاوز قبل القريب
//       - عند تعدد التنبيهات: الأول + «و{n} أخرى» (لا جدار نصوص)
//     وضغطة واحدة تنقل المستخدم إلى الميزانية — التنبيه يقود
//     إلى إجراء، لا يزعج فقط.
//
//  🔇 لا تنبيه إطلاقاً حين كل السقوف داخل حدودها الآمنة: الشاشة
//     تبقى هادئة، والتنبيه يحتفظ بمعناه.
// ═══════════════════════════════════════════════════════════════
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/category_labels.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/number_format.dart';
import '../../core/utils/period_resolver.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../data/db/db.dart';
import '../../data/seed/seed_categories.dart';

class BudgetAlertBanner extends ConsumerWidget {
  const BudgetAlertBanner({
    required this.period,
    required this.onReview,
    super.key,
  });

  /// الفترة التي تُحسب عليها السقوف (نفس فترة الرئيسية)
  final FiscalPeriod period;

  /// إجراء «راجع السقوف» — ينتقل إلى تبويب الميزانية
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final AsyncValue<List<BudgetProgress>> progress =
        ref.watch(budgetProgressProvider((
      startMs: period.start.millisecondsSinceEpoch,
      endMs: period.end.millisecondsSinceEpoch,
    )));

    // بيانات لم تصل بعد (أو خطأ): لا لافتة — لا نزعج المستخدم بما لا نعرفه
    final List<BudgetProgress> items =
        progress.maybeWhen(data: (List<BudgetProgress> v) => v, orElse: () => const <BudgetProgress>[]);
    final List<BudgetProgress> alerts = budgetAlertsOf(items);
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final BudgetProgress top = alerts.first;
    final bool over = top.status == BudgetStatus.over;
    final String formattedSpent =
        AppNumberFormat.formatMoney(context, top.spent, withDecimals: false);
    final String formattedLimit =
        AppNumberFormat.formatMoney(context, top.limit, withDecimals: false);
    final String formattedRemaining =
        AppNumberFormat.formatMoney(context, top.remaining, withDecimals: false);

    final String categoryName = _categoryName(context, l10n, ref, top);
    final String title = over
        ? l10n.budgetAlertOverTitle(categoryName)
        : l10n.budgetAlertNearTitle(categoryName);
    final String body = over
        ? l10n.budgetAlertOverBody(formattedSpent, formattedLimit)
        : l10n.budgetAlertNearBody(
            formattedSpent,
            formattedLimit,
            formattedRemaining,
          );

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InfoBanner(
            icon: over ? Icons.error_rounded : Icons.warning_amber_rounded,
            message: '$title\n$body',
            tone: InfoBannerTone.warning,
            actionLabel: l10n.budgetAlertAction,
            onTap: onReview,
          ),
          if (alerts.length > 1)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: AppTokens.spaceXxs,
                start: AppTokens.spaceSm,
              ),
              child: Text(
                l10n.budgetAlertMore(alerts.length - 1),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  /// اسم الفئة بلغة الواجهة: البذرة تُترجم، والمخصصة باسمها المخزَّن
  String _categoryName(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    BudgetProgress progress,
  ) {
    final String? id = progress.budget.categoryId;
    if (id == null) return l10n.budgetOverallShort;
    final List<CategoryView> view = ref
        .watch(categoriesProvider(SeedCategoryKind.expense))
        .maybeWhen(
          data: (List<CategoryView> list) => list,
          orElse: () => const <CategoryView>[],
        );
    for (final CategoryView c in view) {
      if (c.id != id) continue;
      if (c.labelKey != null) return CategoryLabels.of(l10n, c.labelKey!);
      final bool arabic = Localizations.localeOf(context).languageCode == 'ar';
      return (arabic ? c.nameAr : c.nameFr) ?? l10n.budgetCategoryMissing;
    }
    return l10n.budgetCategoryMissing;
  }
}
