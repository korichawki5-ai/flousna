/// ═══════════════════════════════════════════════════════════════
///  اختبار إعداد التسويق وقسم «تابعنا»
///
///  يحمي ثلاث قواعد لا تُكسر:
///    1) رابط فارغ أو غير صالح = قناة مخفية (صفر روابط ميتة)
///    2) بلا قنوات صالحة = القسم لا يشغل أي مساحة (SizedBox.shrink)
///    3) القنوات الصالحة تظهر مرتّبة بعدد صحيح وبتسمية اللغة الحالية
/// ═══════════════════════════════════════════════════════════════
library;
import 'package:falousna/core/config/marketing_config.dart';
import 'package:falousna/core/l10n/locale_controller.dart';
import 'package:falousna/core/widgets/social_links_section.dart';
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpSection(WidgetTester tester, MarketingConfig config) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        marketingConfigProvider.overrideWithValue(config),
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: kSupportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(body: SocialLinksSection()),
      ),
    ),
  );
}

void main() {
  group('MarketingConfig', () {
    test('بلا روابط: لا قنوات والقسم يعتبر فارغاً', () {
      const MarketingConfig config = MarketingConfig(urls: <MarketingChannel, String>{});
      expect(config.channels, isEmpty);
      expect(config.isEmpty, isTrue);
    });

    test('رابط فارغ ورابط غير صالح لا يدخلان قائمة العرض', () {
      const MarketingConfig config = MarketingConfig(
        urls: <MarketingChannel, String>{
          MarketingChannel.facebook: '',
          MarketingChannel.x: 'ليس رابطاً إطلاقاً',
          MarketingChannel.youtube: 'https://youtube.com/@falousna',
        },
      );
      expect(config.channels, <MarketingChannel>[MarketingChannel.youtube]);
      expect(config.isEmpty, isFalse);
      expect(config.uriFor(MarketingChannel.youtube)?.host, 'youtube.com');
      expect(config.uriFor(MarketingChannel.facebook), isNull);
    });

    test('ترتيب العرض يتبع التعداد لا ترتيب الإدخال', () {
      const MarketingConfig config = MarketingConfig(
        urls: <MarketingChannel, String>{
          MarketingChannel.whatsapp: 'https://whatsapp.com/channel/x',
          MarketingChannel.facebook: 'https://facebook.com/falousna',
        },
      );
      expect(
        config.channels,
        <MarketingChannel>[MarketingChannel.facebook, MarketingChannel.whatsapp],
      );
    });

    test('المساواة تعتمد المحتوى لا المرجع', () {
      const MarketingConfig a = MarketingConfig(
        urls: <MarketingChannel, String>{
          MarketingChannel.instagram: 'https://instagram.com/falousna',
        },
      );
      const MarketingConfig b = MarketingConfig(
        urls: <MarketingChannel, String>{
          MarketingChannel.instagram: 'https://instagram.com/falousna',
        },
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('SocialLinksSection', () {
    testWidgets('بلا قنوات: لا يشغل أي مساحة ولا يعرض أي سطر', (WidgetTester tester) async {
      await _pumpSection(tester, const MarketingConfig(urls: <MarketingChannel, String>{}));
      expect(find.byType(ListTile), findsNothing);
      expect(tester.getSize(find.byType(SocialLinksSection)), Size.zero);
    });

    testWidgets('بقناتين: سطران فقط وبالتسمية العربية', (WidgetTester tester) async {
      await _pumpSection(
        tester,
        const MarketingConfig(
          urls: <MarketingChannel, String>{
            MarketingChannel.facebook: 'https://facebook.com/falousna',
            MarketingChannel.tiktok: 'https://tiktok.com/@falousna',
          },
        ),
      );
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('فيسبوك'), findsOneWidget);
      expect(find.text('تيك توك'), findsOneWidget);
      // القناة غير المُعدَّة لا تظهر حتى لو كانت مدعومة
      expect(find.text('يوتيوب'), findsNothing);
    });

    testWidgets('رابط غير صالح: السطر معطّل ولا يفتح شيئاً', (WidgetTester tester) async {
      await _pumpSection(
        tester,
        const MarketingConfig(
          urls: <MarketingChannel, String>{
            MarketingChannel.telegram: 'رابط مكسور',
          },
        ),
      );
      // uriFor أعاد null ← القناة خرجت من القائمة أصلاً
      expect(find.byType(ListTile), findsNothing);
    });
  });
}
