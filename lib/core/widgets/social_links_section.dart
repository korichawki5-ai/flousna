/// ═══════════════════════════════════════════════════════════════
///  SocialLinksSection — قسم «تابعنا» التسويقي
///
///  🔴 صفر روابط ميتة: إن لم تُعدّ أي قناة (متغيرات البناء أو الإعداد
///     البعيد لاحقاً) يُرجع القسم SizedBox.shrink — لا يظهر أثر له.
///
///  ⭐ الصدق في الفتح: نستخدم ExternalLauncher.openOrCopy — إن فشل
///     فتح المتصفح (جهاز بلا متصفح مثلاً) نُسخ الرابط ويُخبَر المستخدم،
///     ولا ندّعي النجاح أبداً.
/// ═══════════════════════════════════════════════════════════════
library;
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/marketing_config.dart';
import '../l10n/marketing_labels.dart';
import '../theme/design_tokens.dart';
import '../theme/typography.dart';
import '../utils/external_launcher.dart';
import 'screen_scaffold.dart';

/// قسم قنوات التواصل — يوضع في «المزيد» و«حول التطبيق»
class SocialLinksSection extends ConsumerWidget {
  const SocialLinksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketingConfig config = ref.watch(marketingConfigProvider);

    // 🔴 بلا قنوات مُعدَّة لا يظهر القسم إطلاقاً (لا زر ميت)
    if (config.isEmpty) {
      return const SizedBox.shrink();
    }

    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeader(
          title: l10n.socialSectionTitle,
          subtitle: l10n.socialHint,
          icon: Icons.campaign_outlined,
        ),
        for (final MarketingChannel channel in config.channels)
          _SocialTile(
            channel: channel,
            label: MarketingLabels.of(l10n, channel),
            uri: config.uriFor(channel),
          ),
        const SizedBox(height: AppTokens.spaceMd),
      ],
    );
  }
}

/// سطر قناة واحدة: شعار حرفي محايد + الاسم + فتح/نسخ الرابط
class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.channel,
    required this.label,
    required this.uri,
  });

  final MarketingChannel channel;
  final String label;
  final Uri? uri;

  /// اختصار حرفي بخط Mono — محايد قانونياً (لا شعارات marques)
  static const Map<MarketingChannel, String> _marks = <MarketingChannel, String>{
    MarketingChannel.facebook: 'F',
    MarketingChannel.instagram: 'IG',
    MarketingChannel.tiktok: 'TT',
    MarketingChannel.x: 'X',
    MarketingChannel.youtube: 'YT',
    MarketingChannel.telegram: 'TG',
    MarketingChannel.whatsapp: 'WA',
  };

  /// ألوان تمييز هادئة — هوية بصرية لا شعارات
  static const Map<MarketingChannel, Color> _tints = <MarketingChannel, Color>{
    MarketingChannel.facebook: Color(0xFF1877F2),
    MarketingChannel.instagram: Color(0xFFC13584),
    MarketingChannel.tiktok: Color(0xFF69C9D0),
    MarketingChannel.x: Color(0xFF536471),
    MarketingChannel.youtube: Color(0xFFCD201F),
    MarketingChannel.telegram: Color(0xFF229ED9),
    MarketingChannel.whatsapp: Color(0xFF25D366),
  };

  Future<void> _open(BuildContext context) async {
    final Uri? target = uri;
    if (target == null) {
      return;
    }
    final LaunchOutcome outcome = await ExternalLauncher.openOrCopy(target);
    if (!context.mounted || outcome == LaunchOutcome.opened) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome == LaunchOutcome.copied
              ? l10n.legalCopied
              : l10n.legalCantOpenLink,
        ),
        duration: AppTokens.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppTokens.spaceMd,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: _tints[channel],
        child: Text(
          _marks[channel] ?? '?',
          style: AppTypography.monoLabel.copyWith(color: Colors.white),
        ),
      ),
      title: Text(label, style: AppTypography.textTheme.titleSmall),
      trailing: const Icon(Icons.open_in_new, size: 18),
      // 🔴 رابط غير صالح كـ URI ← الزر لا يُعرض أصلاً (لا فشل صامت)
      enabled: uri != null,
      onTap: uri == null ? null : () => _open(context),
    );
  }
}
