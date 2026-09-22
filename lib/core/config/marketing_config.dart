/// ═══════════════════════════════════════════════════════════════
///  MarketingConfig — قنوات التواصل الرسمية للتطبيق
///
///  🔴 مبدأ صفر روابط ميتة: القناة التي لا رابط لها **مخفية تماماً**
///     من الواجهة — لا زر ميت ولا «قريباً» في مكان تسويقي.
///
///  سلسلة مصادر الروابط (الأولوية من الأعلى):
///    1) الإعداد البعيد من لوحة الإدارة (المرحلة 4 فوق مزامنة المرحلة 3)
///       ← يضيفها المالك ويعدّلها **بدون لمس الكود ولا إعادة بناء**
///    2) النسخة المخبأة محلياً من آخر جلب ناجح (تعمل بدون إنترنت)
///    3) متغيرات البناء --dart-define (القيم الافتراضية للمالك الآن)
///    4) لا شيء ← القسم مخفي بالكامل
///
///  في المرحلة 1 نُطبّق المستويين 3 و4 فقط. المستويان 1 و2 يُبنيان مع
///  المزامنة ولوحة الإدارة **دون تغيير أي شاشة**: يُستبدل جسم المزوّد
///  [marketingConfigProvider] وحده، وتبقى الواجهة كما هي.
/// ═══════════════════════════════════════════════════════════════
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

/// القنوات المدعومة — ترتيب العرض هو ترتيب هذا التعداد
enum MarketingChannel {
  facebook,
  instagram,
  tiktok,
  x,
  youtube,
  telegram,
  whatsapp,
}

/// قيم قنوات التسويق الحالية + الوصول الآمن إليها
class MarketingConfig {
  const MarketingConfig({required this.urls});

  /// من متغيرات البناء (المستوى 3 في سلسلة المصادر)
  factory MarketingConfig.fromEnvironment() {
    return MarketingConfig(
      urls: <MarketingChannel, String>{
        if (AppConfig.socialFacebookUrl.isNotEmpty)
          MarketingChannel.facebook: AppConfig.socialFacebookUrl,
        if (AppConfig.socialInstagramUrl.isNotEmpty)
          MarketingChannel.instagram: AppConfig.socialInstagramUrl,
        if (AppConfig.socialTiktokUrl.isNotEmpty)
          MarketingChannel.tiktok: AppConfig.socialTiktokUrl,
        if (AppConfig.socialXUrl.isNotEmpty)
          MarketingChannel.x: AppConfig.socialXUrl,
        if (AppConfig.socialYoutubeUrl.isNotEmpty)
          MarketingChannel.youtube: AppConfig.socialYoutubeUrl,
        if (AppConfig.socialTelegramUrl.isNotEmpty)
          MarketingChannel.telegram: AppConfig.socialTelegramUrl,
        if (AppConfig.socialWhatsappUrl.isNotEmpty)
          MarketingChannel.whatsapp: AppConfig.socialWhatsappUrl,
      },
    );
  }

  /// الروابط المُعدَّة فقط — الفارغ لا يدخل هنا إطلاقاً
  final Map<MarketingChannel, String> urls;

  /// القنوات المرتّبة الجاهزة للعرض — رابط فارغ أو غير صالح = قناة مخفية
  List<MarketingChannel> get channels => <MarketingChannel>[
        for (final MarketingChannel channel in MarketingChannel.values)
          if (uriFor(channel) != null) channel,
      ];

  /// لا قنوات صالحة ← لا يظهر قسم التواصل إطلاقاً
  bool get isEmpty => channels.isEmpty;

  /// رابط آمن للعرض: يُشترط رابط مطلق http/https له مضيف حقيقي.
  ///
  /// أي نص آخر (فارغ، نسبي، بلا.scheme، بروتوكول غريب مثل file:)
  /// يُعيد null فتُحجب القناة بالكامل — لا زر ميت أبداً.
  Uri? uriFor(MarketingChannel channel) {
    final String? raw = urls[channel];
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final Uri? parsed = Uri.tryParse(raw.trim());
    if (parsed == null || !parsed.hasAuthority || parsed.host.isEmpty) {
      return null;
    }
    if (parsed.scheme != 'http' && parsed.scheme != 'https') {
      return null;
    }
    return parsed;
  }

  @override
  bool operator ==(Object other) =>
      other is MarketingConfig &&
      other.urls.length == urls.length &&
      urls.entries.every(
        (MapEntry<MarketingChannel, String> entry) =>
            other.urls[entry.key] == entry.value,
      );

  @override
  int get hashCode => Object.hashAll(
        urls.entries.map((MapEntry<MarketingChannel, String> entry) =>
            Object.hash(entry.key, entry.value)),
      );
}

/// المزوّد الوحيد للقنوات — تُستبدل مصادر البيانات من هنا فقط (م3/م4)
final Provider<MarketingConfig> marketingConfigProvider =
    Provider<MarketingConfig>(
  (Ref ref) => MarketingConfig.fromEnvironment(),
);
