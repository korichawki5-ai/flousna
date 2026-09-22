// ═══════════════════════════════════════════════════════════════
//  add_flow_test — رحلة المال من الإصبع إلى قاعدة البيانات والعودة
//
//  ⭐ هذا الاختبار يحرس أهم عطل ممكن في تطبيق مالي:
//     «أضفتُ مصروفاً والرصيد لم يتغيّر!»
//
//  المسار المُختبَر كاملاً داخل التطبيق الحقيقي:
//     الرئيسية ← زر الإضافة ← مبلغ + ملاحظة ← حفظ
//     ← صفّ حقيقي في SQLite ← الرئيسية تُعيد القراءة تلقائياً
//     ← آخر الحركات يعرض الحركة الجديدة دون إعادة تشغيل.
//
//  قاعدة البيانات ذاكرة (NativeDatabase.memory) — لا لمس للقرص.
// ═══════════════════════════════════════════════════════════════
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:falousna/app.dart';
import 'package:falousna/core/config/constants.dart';
import 'package:falousna/core/errors/app_error.dart';
import 'package:falousna/core/l10n/locale_controller.dart';
import 'package:falousna/core/utils/clock_guard.dart';
import 'package:falousna/core/utils/result.dart';
import 'package:falousna/core/widgets/app_button.dart';
import 'package:falousna/data/db/db.dart';
import 'package:falousna/data/local/local_store.dart';
import 'package:falousna/features/transactions/add_transaction_screen.dart';
import 'package:falousna/features/transactions/tx_tile.dart';
import 'package:falousna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// جلسة اختبار: قاعدة ذاكرة + مزوّدات مُستبدلة + التطبيق الحقيقي
class _Harness {
  _Harness(this.db, this.clock);

  final FalousnaDatabase db;
  final ClockGuard clock;
}

Future<_Harness> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    AppConstants.keyOnboardingDone: true,
    AppConstants.keyConsentGranted: true,
    AppConstants.keyConsentVersion: AppConstants.privacyPolicyVersion,
    AppConstants.keyConsentHash: 'a' * 64,
    AppConstants.keyGuestMode: true,
    AppConstants.keySetupDone: true,
  });

  final LocalStore store = await LocalStore.init();
  final ClockGuard clock = await ClockGuard.create();
  final FalousnaDatabase db =
      FalousnaDatabase.forTesting(NativeDatabase.memory());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(store),
        clockGuardProvider.overrideWithValue(clock),
        falousnaDatabaseProvider.overrideWithValue(db),
        transactionRepositoryProvider
            .overrideWithValue(TransactionRepository(db, clock)),
      ],
      child: const FalousnaApp(),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(db, clock);
}

/// نصوص الواجهة تأتي من الترجمة نفسها — لا نصّ مكتوب يدوياً في الاختبار
Future<AppLocalizations> _l10n() async =>
    AppLocalizations.delegate.load(kDefaultLocale);

void main() {
  testWidgets('⭐ إضافة مصروف: تُكتب في القاعدة وتظهر في الرئيسية فوراً',
      (WidgetTester tester) async {
    final _Harness harness = await _pumpApp(tester);
    addTearDown(harness.db.close);
    final AppLocalizations l10n = await _l10n();

    // ── 1. من الرئيسية إلى نموذج الإضافة ──
    expect(find.byType(TransactionTile), findsNothing,
        reason: 'قاعدة فارغة: لا حركات بعد');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);

    // ── 2. تعبئة المبلغ والملاحظة (المصروف هو الافتراضي) ──
    await tester.enterText(find.byType(TextField).first, '1500');
    await tester.enterText(find.byType(TextField).last, 'قهوة الصباح');
    await tester.pumpAndSettle();

    // ── 3. الحفظ ──
    await tester.tap(find.widgetWithText(AppButton, l10n.actionSave));

    // انتظار انتهاء الكتابة على القرص/الذاكرة (لا صفر ثابت هشّ)
    await tester.pumpAndSettle();
    for (int i = 0;
        i < 20 && (await harness.db.select(harness.db.transactions).get()).isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // ── 4. صفّ حقيقي في قاعدة البيانات ──
    final List<Transaction> rows =
        await harness.db.select(harness.db.transactions).get();
    expect(rows.length, 1, reason: 'الحركة لم تُحفظ في القاعدة');
    final Transaction row = rows.single;
    expect(row.amountCentimes, 150000,
        reason: 'المبلغ يجب أن يُخزَّن بالسنتمات (1500 دج = 150000)');
    expect(row.kind, 'expense');
    expect(row.note, 'قهوة الصباح');
    expect(row.deletedAtMs, isNull, reason: 'حركة جديدة ليست محذوفة');
    expect(row.profileId, isNotEmpty);

    // ── 5. عاد للنموذج؟ لا: الشاشة تُغلق بعد الحفظ ──
    expect(find.byType(AddTransactionScreen), findsNothing,
        reason: 'شاشة الإضافة بقيت مفتوحة بعد الحفظ');

    // ── 6. 🔴 الجوهر: الرئيسية أظهرت الحركة بلا إعادة تشغيل ──
    expect(
      find.byType(TransactionTile),
      findsOneWidget,
      reason: 'الرئيسية لم تُحدّث نفسها بعد الكتابة — عطل «الرصيد لا يتغيّر»',
    );
    expect(find.text('قهوة الصباح'), findsOneWidget,
        reason: 'ملاحظة الحركة غير معروضة في آخر الحركات');
  });

  testWidgets('⭐ حذف ناعم من نفس القاعدة يُخفى من الرئيسية فوراً',
      (WidgetTester tester) async {
    final _Harness harness = await _pumpApp(tester);
    addTearDown(harness.db.close);

    // نُدخل حركة مباشرة في القاعدة (بذرة الاختبار) ثم نفتح التطبيق
    await harness.db.into(harness.db.transactions).insert(
          TransactionsCompanion.insert(
            id: 'seed-tx-1',
            profileId: (await harness.db.select(harness.db.profiles).get()).first.id,
            kind: 'expense',
            amountCentimes: const Value<int>(25000),
            note: const Value<String>('خبز'),
            categoryId: 'expense_food',
            occurredOn: harness.clock.trustedNow(),
            createdAtMs: harness.clock.trustedNow().millisecondsSinceEpoch,
            updatedAtMs: harness.clock.trustedNow().millisecondsSinceEpoch,
          ),
        );
    await tester.pumpAndSettle();
    expect(find.byType(TransactionTile), findsOneWidget);

    // حذف ناعم عبر المستودع الحقيقي
    final TransactionRepository repo =
        TransactionRepository(harness.db, harness.clock);
    final Result<void, AppError> deleted = await repo.softDelete('seed-tx-1');
    expect(deleted.isSuccess, isTrue);
    await tester.pumpAndSettle();

    expect(
      find.byType(TransactionTile),
      findsNothing,
      reason: 'المحذوف ناعماً بقي ظاهراً — الرئيسية لم تقرأ الكتابة الجديدة',
    );
  });
}
