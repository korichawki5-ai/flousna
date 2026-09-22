/// ═══════════════════════════════════════════════════════════════
///  MarketingLabels — جسر أسماء القنوات إلى الترجمة
///
///  نفس نمط CategoryLabels: لا نص في الكود، والمفاتيح في ar.arb/fr.arb.
///  أسماء القنوات نفسها علامات تجارية تُكتب كما هي في اللغتين.
/// ═══════════════════════════════════════════════════════════════
library;
import 'package:falousna/l10n/app_localizations.dart';

import '../config/marketing_config.dart';

/// اسم القناة الظاهر للمستخدم حسب لغة الواجهة
abstract final class MarketingLabels {
  static String of(AppLocalizations l10n, MarketingChannel channel) =>
      switch (channel) {
        MarketingChannel.facebook => l10n.channelFacebook,
        MarketingChannel.instagram => l10n.channelInstagram,
        MarketingChannel.tiktok => l10n.channelTiktok,
        MarketingChannel.x => l10n.channelX,
        MarketingChannel.youtube => l10n.channelYoutube,
        MarketingChannel.telegram => l10n.channelTelegram,
        MarketingChannel.whatsapp => l10n.channelWhatsapp,
      };
}
