// ═══════════════════════════════════════════════════════════════
//  tables.dart — مخطط قاعدة بيانات فلوسنا (Drift/SQLite)
//
//  م2.1 — ثلاثة جداول، وكل عمود له سبب:
//    profiles        ← أساس م2.3 (العائلة)؛ صف واحد افتراضي الآن
//    custom_categories ← فئات المستخدم بجانب بذرة الفئات الجزائرية
//    transactions    ← الحركة المالية: كل مبلغ عدد صحيح بالسنتيم
//  م2.2 — جدول رابع:
//    budgets         ← سقف الصرف لكل فئة أو سقف عام + نسبة التنبيه
//
//  ✅ offline-first: لا عمود خادم واحد هنا — المزامنة (م3) تضيف
//     أعمدة التحديث البعيد عبر هجرة مرقّمة لا تكسر البيانات.
//  ✅ حذف ناعم (deletedAtMs): التراجع ممكن، والمزامنة ترى الحذف.
// ═══════════════════════════════════════════════════════════════
import 'package:drift/drift.dart';

/// الملف الشخصي (فرد العائلة) — م2.1: صف افتراضي واحد فقط
class Profiles extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();
  TextColumn get name => text().withLength(max: 60).withDefault(const Constant(''))();

  /// owner | member — يُستعمل في م2.3 لصلاحيات الملخص
  TextColumn get role => text().withDefault(const Constant('owner'))();
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
  IntColumn get createdAtMs => integer()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => <Column>{id};
}

/// فئة يضيفها المستخدم — تكمّل البذرة ولا تعدّلها أبداً
class CustomCategories extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  /// expense | income — نفس قيم SeedCategoryKind.name
  TextColumn get kind => text().withLength(min: 1, max: 16)();
  TextColumn get nameAr => text().withLength(min: 1, max: 40)();
  TextColumn get nameFr => text().withLength(min: 1, max: 40)();

  /// اسم أيقونة من قائمة SeedIcons المغلقة (لا أيقونات حرة)
  TextColumn get icon => text().withLength(min: 1, max: 40)();
  BoolColumn get seasonal => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtMs => integer()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => <Column>{id};
}

/// الحركة المالية — قلب التطبيق
class Transactions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();
  TextColumn get profileId =>
      text().withLength(min: 1, max: 64).references(Profiles, #id)();

  /// expense | income
  TextColumn get kind => text().withLength(min: 1, max: 16)();

  /// ⭐ مبلغ موجب دائماً بالسنتيم؛ الإشارة يستنتجها النوع kind
  IntColumn get amountCentimes => integer().withDefault(const Constant(0))();
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('DZD'))();

  /// معرّف فئة: بذرة (exp_*/inc_*) أو مخصصة (cc-*)
  TextColumn get categoryId => text().withLength(min: 1, max: 64)();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// يوم الحركة مقتطعاً للساعة صفر — الفترات تقارن بهذه القيمة
  DateTimeColumn get occurredOn => dateTime()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => <Column>{id};
}

/// سقف الصرف (الميزانية) — كيف نمنع المال من النفاد قبل نهاية الفترة
///
/// ⭐ قواعد محسومة:
///   - `categoryId = null` ← **سقف عام** لكل المصاريف في الفترة.
///   - سقف واحد فعّال لكل فئة (الاستبدال بدل التكرار — انظر المستودع).
///   - السقوف للمصاريف فقط: الدخل يُتَابع في الرئيسية لا يُسقَّف هنا.
///   - `alertPercent` نسبة التنبيه (50..100): «نبّهني عند 80٪».
///   - حذف ناعم: حذف السقف لا يمسّ حركاته إطلاقاً.
class Budgets extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();
  TextColumn get profileId =>
      text().withLength(min: 1, max: 64).references(Profiles, #id)();

  /// null = السقف العام على كل المصاريف
  TextColumn get categoryId => text().withLength(min: 1, max: 64).nullable()();

  /// سقف الصرف بالسنتيم (موجب دائماً)
  IntColumn get amountCentimes => integer().withDefault(const Constant(0))();

  /// نسبة التنبيه من السقف (50..100)
  IntColumn get alertPercent => integer().withDefault(const Constant(80))();

  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => <Column>{id};
}
