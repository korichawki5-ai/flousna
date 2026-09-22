// ═══════════════════════════════════════════════════════════════
//  tx_tile.dart — سطير حركة واحد، مشترك بين الرئيسية وقائمة الحركات
//
//  ✅ أيقونة الفئة + الاسم بلغتها + الملاحظة + التاريخ + المبلغ
//     بخط Mono ملون دلالياً (أخضر دخل / أحمر مصروف) واتجاه LTR.
//  ✅ فئة مؤرشفة تبقى مقروءة: خريطة الفئات تُبنى(includeArchived: true).
// ═══════════════════════════════════════════════════════════════
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/seed_icons.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/money.dart';
import '../../core/utils/number_format.dart';
import '../../core/widgets/money_text.dart';
import '../../data/db/db.dart';
import '../../data/seed/seed_categories.dart';

/// سطير حركة حقيقية من القاعدة
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    required this.arabic,
    super.key,
    this.category,
  });

  final Transaction transaction;
  final CategoryView? category;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool income = transaction.kind == SeedCategoryKind.income.name;
    final Color accent =
        income ? AppTokens.semanticIncome : AppTokens.semanticExpense;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppTokens.spaceSm),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.cardRadius,
        child: InkWell(
          borderRadius: AppTokens.cardRadius,
          onTap: null, // التفاصيل/التعديل شاشة لاحقة — لا زر ميت الآن
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppTokens.spaceMd,
              vertical: AppTokens.spaceMd,
            ),
            child: Row(
              children: <Widget>[
                // ── أيقونة الفئة ──
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Icon(
                    SeedIcons.fromName(category?.icon),
                    size: 20,
                    color: accent,
                  ),
                ),
                const SizedBox(width: AppTokens.spaceMd),

                // ── الاسم + الملاحظة + التاريخ ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        category?.displayName(l10n, arabic: arabic) ??
                            transaction.categoryId,
                        style: AppTypography.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (transaction.note.trim().isNotEmpty)
                        Text(
                          transaction.note,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        AppNumberFormat.formatDayWithWeekday(
                          context,
                          transaction.occurredOn,
                        ),
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTokens.spaceSm),

                // ── المبلغ: إشارة ولون دلالي وخط Mono ──
                MoneyText(
                  amount: Money.fromCentimes(
                    transaction.amountCentimes,
                    currency: transaction.currency,
                  ),
                  size: MoneyTextSize.medium,
                  color: accent,
                  showSign: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
