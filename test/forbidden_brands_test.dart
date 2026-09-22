import 'dart:io';

import 'package:falousna/core/config/forbidden_brands.dart';
import 'package:flutter_test/flutter_test.dart';

/// ═══════════════════════════════════════════════════════════════
///  اختبار حظر أسماء المؤسسات — 🔴 شرط قانوني وتسويقي
///
///  القرار (موثّق في وثيقة 04): لا يُذكر أي اسم بنك أو مؤسسة
///  بريدية أو متعامل هاتف أو شركة مرافق داخل التطبيق — لا في
///  الواجهة ولا في الترجمة ولا في البيانات الأولية ولا في الموقع.
///
///  هذا الاختبار يفحص **المحتوى المشحون فعلياً**، لا العينات فقط:
///    - كل ملفات lib/**.dart (عدا قائمة الحظر نفسها)
///    - كل ملفات الترجمة lib/l10n/*.arb
///    - كل بذور البيانات assets/seed/*.json
/// ═══════════════════════════════════════════════════════════════

/// ملفات يُسمح أن تحتوي الأسماء (لأنها *تعريف* الحظر)
const Set<String> _exemptPaths = <String>{
  'lib/core/config/forbidden_brands.dart',
};

void main() {
  group('الكاشف نفسه يعمل', () {
    test('يلتقط أسماء لاتينية ككلمة كاملة', () {
      expect(ForbiddenBrands.scan('Pay with BaridiMob please'), contains('baridimob'));
      expect(ForbiddenBrands.scan('transfer to CCP account'), contains('ccp'));
      expect(ForbiddenBrands.scan('Edahabia card'), contains('edahabia'));
      expect(ForbiddenBrands.scan('Sonelgaz bill'), contains('sonelgaz'));
    });

    test('يلتقط أسماء عربية (بلا حدود كلمات)', () {
      expect(ForbiddenBrands.scan('فاتورة سونلغاز'), contains('سونلغاز'));
      expect(ForbiddenBrands.scan('رصيد بريدي موب'), contains('بريدي موب'));
      expect(ForbiddenBrands.scan('تحويل من البنك الوطني'), contains('البنك الوطني'));
    });

    test('يتجاهل التشكيل واختلاف الألف والتاء المربوطة', () {
      expect(ForbiddenBrands.isClean('سونلغاز'), isFalse);
      expect(ForbiddenBrands.isClean('سُونَلْغاز'), isFalse);
      expect(ForbiddenBrands.isClean('BARIDIMOB'), isFalse);
      expect(ForbiddenBrands.isClean('BaridiMob'), isFalse);
    });

    test('⭐ لا إنذارات كاذبة على كلمات تحتوي الاسم جزئياً', () {
      // «ccp» داخل كلمة أطول ليست اسم مؤسسة
      expect(ForbiddenBrands.isClean('accept payment'), isTrue);
      expect(ForbiddenBrands.isClean('recipient'), isTrue);
      // «badr» اسم شخص شائع — يُلتقط ككلمة كاملة فقط (قرار موثّق)
      expect(ForbiddenBrands.isClean('badroom'), isTrue);
      expect(ForbiddenBrands.isClean('تحويل بريدي'), isTrue);
      expect(ForbiddenBrands.isClean('بطاقة بنكية'), isTrue);
      expect(ForbiddenBrands.isClean('الكهرباء والغاز'), isTrue);
    });

    test('النصوص المحايدة المستعملة في التطبيق نظيفة', () {
      const List<String> neutral = <String>[
        'تحويل بريدي',
        'بطاقة بنكية',
        'الكهرباء والغاز',
        'المياه',
        'الإنترنت والهاتف',
        'اشتراك الهاتف',
        'أجرة يومية',
        'مساعدة عائلية',
        'الزكاة والصدقة',
      ];
      for (final String text in neutral) {
        expect(
          ForbiddenBrands.isClean(text),
          isTrue,
          reason: 'يفترض أن يكون نظيفاً: $text',
        );
      }
    });

    test('كل بديل محايد له معنى في الخريطة', () {
      expect(ForbiddenBrands.neutralReplacements, isNotEmpty);
      for (final MapEntry<String, String> entry
          in ForbiddenBrands.neutralReplacements.entries) {
        expect(entry.value, isNotEmpty);
        expect(ForbiddenBrands.isClean(entry.key), isTrue);
      }
    });
  });

  group('🔴 المحتوى المشحون خالٍ من أسماء المؤسسات', () {
    test('ملفات lib/ نظيفة', () {
      final List<String> violations = _scanDirectory(
        Directory('lib'),
        extensions: <String>{'.dart'},
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('ملفات الترجمة AR و FR نظيفة', () {
      final List<String> violations = _scanDirectory(
        Directory('lib/l10n'),
        extensions: <String>{'.arb'},
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('بذور البيانات نظيفة', () {
      final List<String> violations = _scanDirectory(
        Directory('assets/seed'),
        extensions: <String>{'.json'},
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('ملفات الإعداد والجذر نظيفة', () {
      final List<String> violations = <String>[];
      for (final String name in <String>[
        'pubspec.yaml',
        'README_AR.md',
        '.env.example',
      ]) {
        final File file = File(name);
        if (!file.existsSync()) continue;
        final List<String> found = ForbiddenBrands.scan(file.readAsStringSync());
        if (found.isNotEmpty) {
          violations.add('$name → $found');
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });
}

/// يفحص كل ملفات مجلد ويعيد قائمة الانتهاكات بصيغة «الملف → الأسماء»
List<String> _scanDirectory(Directory dir, {required Set<String> extensions}) {
  final List<String> violations = <String>[];
  if (!dir.existsSync()) return violations;

  for (final FileSystemEntity entity in dir.listSync(recursive: true)) {
    if (entity is! File) continue;

    final String path = entity.path.replaceAll(r'\', '/');
    final bool wantedExtension =
        extensions.any(path.endsWith);
    if (!wantedExtension) continue;
    if (_exemptPaths.any(path.endsWith)) continue;

    final List<String> found = ForbiddenBrands.scan(entity.readAsStringSync());
    if (found.isNotEmpty) {
      violations.add('$path → $found');
    }
  }

  return violations;
}
