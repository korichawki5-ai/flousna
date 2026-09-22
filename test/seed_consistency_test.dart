import 'dart:convert';
import 'dart:io';

import 'package:falousna/core/errors/app_error.dart';
import 'package:falousna/core/l10n/category_labels.dart';
import 'package:falousna/core/theme/seed_icons.dart';
import 'package:falousna/core/utils/result.dart';
import 'package:falousna/data/seed/seed_categories.dart';
import 'package:falousna/data/seed/seed_seasonal.dart';
import 'package:flutter_test/flutter_test.dart';

/// ═══════════════════════════════════════════════════════════════
///  اختبار اتساق البذور — الكتالوج في الكود = الكتالوج في JSON
///
///  ⭐ لماذا؟ التصنيفات موجودة في مكانين:
///     1. `SeedCategories` (كود) → تستعمله الواجهة الآن
///     2. `assets/seed/categories.json` → تزرع قاعدة البيانات (المرحلة 2)
///     بدون هذا الاختبار سيتباعدان بصمت، فيظهر تصنيف في الواجهة
///     ولا يُحفظ في القاعدة (أو العكس) — خطأ يظهر بعد أشهر.
///
///  يفحص أيضاً: كل labelKey موجود في الترجمتين ومغطى في الجسر،
///  وكل أيقونة معروفة، وكل مناسبة تشير إلى تصنيفات موجودة.
/// ═══════════════════════════════════════════════════════════════

const String _categoriesPath = 'assets/seed/categories.json';
const String _seasonalPath = 'assets/seed/seasonal_events.json';
const String _arPath = 'lib/l10n/ar.arb';
const String _frPath = 'lib/l10n/fr.arb';

Map<String, dynamic> _readJson(String path) {
  final File file = File(path);
  if (!file.existsSync()) {
    // ⚠️ لا نستعمل expect هنا: الدعاء يحدث زمن التصريح (قبل أي test)
    throw StateError('ملف مفقود: $path');
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('بذرة التصنيفات (JSON)', () {
    final Result<CategoryCatalog, AppError> parsed =
        CategoryCatalog.fromJson(_readJson(_categoriesPath));

    test('تُحلَّل بلا خطأ', () {
      expect(parsed.isSuccess, isTrue, reason: '${parsed.errorOrNull}');
    });

    test('إصدار البذرة في JSON يطابق إصدار الكود', () {
      expect(parsed.requireValue.version, SeedCategories.version);
    });

    test('⭐ نفس المعرّفات بنفس الترتيب في الكود وJSON', () {
      final CategoryCatalog json = parsed.requireValue;

      expect(
        json.expense.map((SeedCategory c) => c.id).toList(),
        SeedCategories.expense.map((SeedCategory c) => c.id).toList(),
      );
      expect(
        json.income.map((SeedCategory c) => c.id).toList(),
        SeedCategories.income.map((SeedCategory c) => c.id).toList(),
      );
    });

    test('كل الحقول متطابقة بين النسختين', () {
      final CategoryCatalog json = parsed.requireValue;

      for (final SeedCategory coded in SeedCategories.catalog.all) {
        final SeedCategory? fromJson = json.byId(coded.id);
        expect(fromJson, isNotNull, reason: 'مفقود في JSON: ${coded.id}');
        expect(fromJson!.kind, coded.kind);
        expect(fromJson.labelKey, coded.labelKey);
        expect(fromJson.icon, coded.icon);
        expect(fromJson.sortOrder, coded.sortOrder);
        expect(fromJson.seasonal, coded.seasonal);
      }
    });

    test('لا معرّفات مكررة ولا ترتيب مكرر', () {
      final List<String> ids =
          SeedCategories.catalog.all.map((SeedCategory c) => c.id).toList();
      expect(ids.toSet().length, ids.length);

      for (final SeedCategoryKind kind in SeedCategoryKind.values) {
        final List<int> orders = SeedCategories.catalog
            .ofKind(kind)
            .map((SeedCategory c) => c.sortOrder)
            .toList();
        expect(orders.toSet().length, orders.length);
      }
    });

    test('بنية تالفة تُرفض بدل أن تمرّ بصمت', () {
      expect(CategoryCatalog.fromJson(<String, dynamic>{}).isFailure, isTrue);
      expect(CategoryCatalog.fromJson('نص').isFailure, isTrue);
      expect(
        CategoryCatalog.fromJson(<String, dynamic>{
          'version': 1,
          'expense': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'a', 'kind': 'expense'},
          ],
          'income': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'b', 'kind': 'income'},
          ],
        }).isFailure,
        isTrue,
        reason: 'labelKey و icon و sortOrder ناقصة',
      );
      expect(
        CategoryCatalog.fromJson(<String, dynamic>{
          'version': 1,
          'expense': <Map<String, dynamic>>[],
          'income': <Map<String, dynamic>>[],
        }).isFailure,
        isTrue,
        reason: 'القوائم الفارغة مرفوضة',
      );
    });
  });

  group('الترجمة والأيقونات', () {
    final Map<String, dynamic> ar = _readJson(_arPath);
    final Map<String, dynamic> fr = _readJson(_frPath);

    test('كل labelKey موجود في العربية والفرنسية', () {
      for (final String key in SeedCategories.allLabelKeys) {
        expect(ar.containsKey(key), isTrue, reason: 'مفقود في ar.arb: $key');
        expect(fr.containsKey(key), isTrue, reason: 'مفقود في fr.arb: $key');
        expect((ar[key] as String).trim(), isNotEmpty, reason: key);
        expect((fr[key] as String).trim(), isNotEmpty, reason: key);
      }
    });

    test('كل labelKey مغطى في جسر CategoryLabels', () {
      for (final String key in SeedCategories.allLabelKeys) {
        expect(
          CategoryLabels.supportedKeys.contains(key),
          isTrue,
          reason: 'لا يوجد ربط ترجمة لـ: $key',
        );
      }
    });

    test('لا مفاتيح ترجمة يتيمة في الجسر', () {
      for (final String key in CategoryLabels.supportedKeys) {
        expect(
          SeedCategories.allLabelKeys.contains(key),
          isTrue,
          reason: 'مفتاح في الجسر ولا تصنيف يستعمله: $key',
        );
      }
    });

    test('كل اسم أيقونة معروف في جدول SeedIcons', () {
      for (final String name in SeedCategories.allIconNames) {
        expect(SeedIcons.isKnown(name), isTrue, reason: 'أيقونة مجهولة: $name');
      }
    });

    test('اسم مجهول يعيد الأيقونة الاحتياطية بدل الانهيار', () {
      expect(SeedIcons.fromName('لا_وجود_له'), SeedIcons.fallback);
      expect(SeedIcons.fromName(null), SeedIcons.fallback);
    });
  });

  group('بذرة المناسبات الموسمية', () {
    final Result<SeasonalCatalog, AppError> parsed =
        SeasonalCatalog.fromJson(_readJson(_seasonalPath));

    test('تُحلَّل بلا خطأ', () {
      expect(parsed.isSuccess, isTrue, reason: '${parsed.errorOrNull}');
    });

    test('تغطي التقويمين الهجري والميلادي والحالة اليدوية', () {
      final SeasonalCatalog catalog = parsed.requireValue;

      expect(
        catalog.events.where(
          (SeasonalEvent e) => e.calendar == SeasonalCalendar.hijri,
        ),
        isNotEmpty,
      );
      expect(
        catalog.events.where(
          (SeasonalEvent e) => e.calendar == SeasonalCalendar.gregorian,
        ),
        isNotEmpty,
      );
      expect(catalog.manual, isNotEmpty, reason: 'حول الزكاة يُحسب يدوياً');
    });

    test('كل مناسبة تشير إلى تصنيفات موجودة فعلاً', () {
      final SeasonalCatalog catalog = parsed.requireValue;
      final List<String> categoryIds = SeedCategories.allIds;

      for (final SeasonalEvent event in catalog.events) {
        expect(event.relatedCategoryIds, isNotEmpty, reason: event.id);
        for (final String id in event.relatedCategoryIds) {
          expect(
            categoryIds.contains(id),
            isTrue,
            reason: '${event.id} يشير إلى تصنيف غير موجود: $id',
          );
        }
      }
    });

    test('كل مناسبة لها اسم وتذكير باللغتين', () {
      for (final SeasonalEvent event in parsed.requireValue.events) {
        expect(event.labelFor('ar'), isNotEmpty, reason: event.id);
        expect(event.labelFor('fr'), isNotEmpty, reason: event.id);
        expect(event.reminderFor('ar'), isNotEmpty, reason: event.id);
        expect(event.reminderFor('fr'), isNotEmpty, reason: event.id);
        // لغة غير معروفة → ترجع إلى العربية (اللغة الأساسية)
        expect(event.labelFor('xx'), event.labelAr);
      }
    });

    test('التواريخ الثابتة ضمن الحدود والمنطقية', () {
      for (final SeasonalEvent event in parsed.requireValue.scheduled) {
        expect(event.month, inInclusiveRange(1, 12), reason: event.id);
        expect(event.day, inInclusiveRange(1, 31), reason: event.id);
        expect(event.durationDays, inInclusiveRange(1, 366), reason: event.id);
        expect(event.hasFixedDate, isTrue);
      }
    });

    test('رمضان شهر 9 وعيد الأضحى 10 ذي الحجة', () {
      final SeasonalCatalog catalog = parsed.requireValue;

      expect(catalog.byId('ramadan')?.month, 9);
      expect(catalog.byId('ramadan')?.calendar, SeasonalCalendar.hijri);
      expect(catalog.byId('eid_al_adha')?.month, 12);
      expect(catalog.byId('eid_al_adha')?.day, 10);
      expect(catalog.byId('eid_al_fitr')?.month, 10);
      expect(catalog.byId('eid_al_fitr')?.day, 1);
      expect(catalog.byId('rentree_scolaire')?.calendar, SeasonalCalendar.gregorian);
      expect(catalog.byId('rentree_scolaire')?.month, 9);
    });

    test('نسبة الرفع ضمن نطاق معقول', () {
      for (final SeasonalEvent event in parsed.requireValue.events) {
        expect(
          event.defaultBoostPercent,
          inInclusiveRange(0, 200),
          reason: event.id,
        );
      }
    });

    test('ترتيب الأثر يسمح بمقارنة المواسم', () {
      expect(SeasonalImpact.low.rank, lessThan(SeasonalImpact.high.rank));
      expect(
        SeasonalImpact.high.rank,
        lessThan(SeasonalImpact.veryHigh.rank),
      );
      expect(SeasonalImpact.fromName('very_high'), SeasonalImpact.veryHigh);
      expect(SeasonalImpact.fromName('غير معروف'), isNull);
    });

    test('معرّف مجهول يعيد null بدل استثناء', () {
      expect(parsed.requireValue.byId('لا_وجود_له'), isNull);
    });

    test('بنية تالفة تُرفض', () {
      expect(SeasonalCatalog.fromJson(<String, dynamic>{}).isFailure, isTrue);
      expect(
        SeasonalCatalog.fromJson(<String, dynamic>{
          'version': 1,
          'events': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'x', 'calendar': 'hijri'},
          ],
        }).isFailure,
        isTrue,
      );
    });
  });
}
