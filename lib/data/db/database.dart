// ═══════════════════════════════════════════════════════════════
//  database.dart — فتح القاعدة + DAOs + مزوّدات Riverpod
//
//  ✅ drift_flutter.driftDatabase يفتح SQLite في مجلد التطبيق
//     الصحيح لكل منصة (Windows/Android) ويضمّن مكتبة sqlite3 الأصلية.
//  ✅ الاختبارات تحقن NativeDatabase.memory() عبر overrideWithValue.
//  ✅ الإصدار 1؛ أي تغيير مستقبلي = هجرة في migrationStrategy
//     مع نسخة احتياطية تلقائية قبل الترقية (سياسة صفر فقدان).
// ═══════════════════════════════════════════════════════════════
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables.dart';

part 'database.g.dart';

/// معرّف الملف الشخصي الافتراضي الوحيد في م2.1
const String kDefaultProfileId = 'profile-default';

@DriftDatabase(
  tables: <Type>[Profiles, CustomCategories, Transactions, Budgets],
)
class FalousnaDatabase extends _$FalousnaDatabase {
  FalousnaDatabase(super.executor);

  /// للبناء والاختبارات: قاعدة داخل الذاكرة بلا قرص
  FalousnaDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator migrator) async {
          await migrator.createAll();
          // الملف الافتراضي يوجد مع القاعدة — لا حركة بلا ملف
          await into(profiles).insert(
            ProfilesCompanion.insert(
              id: kDefaultProfileId,
              createdAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        },
        onUpgrade: (Migrator migrator, int from, int to) async {
          // ⭐ الهجرات مرقّمة ومتسلسلة: كل قفزة إصدار لها كتلتها،
          //    فيعمل التحديث من أي إصدار أقدم — لا فقدان بيانات أبداً.
          if (from < 2) {
            // م2.2: جدول السقوف يُضاف بلا لمس جداول 2.1
            await migrator.createTable(budgets);
          }
        },
      );
}

/// مزوّد القاعدة — يُغلق تلقائياً عند التخلص من الشجرة
final Provider<FalousnaDatabase> falousnaDatabaseProvider =
    Provider<FalousnaDatabase>(
  (Ref ref) {
    final FalousnaDatabase db = FalousnaDatabase(
      driftDatabase(name: 'falousna'),
    );
    ref.onDispose(db.close);
    return db;
  },
);
