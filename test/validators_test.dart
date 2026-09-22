import 'package:falousna/core/config/constants.dart';
import 'package:falousna/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

/// ═══════════════════════════════════════════════════════════════
///  اختبارات Validators — الطبقة الأولى من التحقق المزدوج
///
///  ⭐ كل قاعدة تُعيد **مفتاح ترجمة** لا نصاً جاهزاً، لذلك نفحص
///     المفاتيح نفسها (لو تغيّر مفتاح دون تغيير .arb ينكسر النص
///     عند المستخدم → الاختبار يمسكها).
/// ═══════════════════════════════════════════════════════════════
void main() {
  group('المبلغ المالي', () {
    test('قيم صحيحة تمرّ', () {
      expect(Validators.amount('1500'), isNull);
      expect(Validators.amount('1.250,50'), isNull);
      expect(Validators.amount('0,50'), isNull);
      expect(Validators.amount('1500 دج'), isNull);
      expect(Validators.amount('-500'), isNull);
    });

    test('فارغ → مطلوب', () {
      expect(Validators.amount(''), 'validateAmountRequired');
      expect(Validators.amount(null), 'validateAmountRequired');
      expect(Validators.amount('   '), 'validateAmountRequired');
    });

    test('صفر → رفض (حركة بلا معنى)', () {
      expect(Validators.amount('0'), 'validateAmountZero');
    });

    test('أكثر من خانتين عشريتين → رفض', () {
      expect(Validators.amount('1,234'), 'validateAmountDecimals');
      expect(Validators.amount('10.555'), 'validateAmountDecimals');
    });

    test('محارف غير رقمية → رفض', () {
      expect(Validators.amount('abc'), 'validateAmountRequired');
      expect(Validators.amount('15oo'), 'validateAmountRequired');
    });

    test('مبلغ ضخم → رفض', () {
      expect(Validators.amount('1000000000'), 'validateAmountTooLarge');
      expect(Validators.amount('999999999'), isNull);
    });
  });

  group('البريد الإلكتروني', () {
    test('صيغ صحيحة', () {
      expect(Validators.email('user@mail.com'), isNull);
      expect(Validators.email('name+tag@sub.domain.co'), isNull);
      expect(Validators.email('  spaced@mail.com  '), isNull);
    });

    test('فارغ → مطلوب', () {
      expect(Validators.email(''), 'validateEmailRequired');
      expect(Validators.email(null), 'validateEmailRequired');
    });

    test('بلا @ أو بلا نقطة بعد @ → غير صالح', () {
      expect(Validators.email('usermail.com'), 'validateEmailInvalid');
      expect(Validators.email('user@mail'), 'validateEmailInvalid');
      expect(Validators.email('user @mail.com'), 'validateEmailInvalid');
    });

    test('أطول من الحد → رفض', () {
      final String longEmail =
          '${'a' * AppConstants.maxEmailLength}@mail.com';
      expect(Validators.email(longEmail), 'validateEmailTooLong');
    });
  });

  group('كلمة المرور', () {
    test('صالحة: 8 محارف مع رقم', () {
      expect(Validators.password('falous2026'), isNull);
      expect(Validators.password('pass1word'), isNull);
    });

    test('فارغة → مطلوبة', () {
      expect(Validators.password(''), 'validatePasswordRequired');
    });

    test('قصيرة → رفض', () {
      expect(Validators.password('ab1'), 'validatePasswordTooShort');
      expect(Validators.password('1234567'), 'validatePasswordTooShort');
    });

    test('بلا رقم → رفض (قاعدة مخفّفة عمداً)', () {
      expect(Validators.password('falousnaonly'), 'validatePasswordNoDigit');
    });

    test('طويلة جداً → رفض', () {
      final String long = '${'a' * AppConstants.maxPasswordLength}1';
      expect(Validators.password(long), 'validatePasswordTooLong');
    });

    test('التأكيد يجب أن يطابق', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
      expect(
        Validators.confirmPassword('abc12345', 'abc12346'),
        'validateConfirmMismatch',
      );
      expect(Validators.confirmPassword('', 'abc12345'), 'validatePasswordRequired');
    });
  });

  group('⭐ رقم الهاتف الجزائري (تحقق مزدوج)', () {
    test('الصيغ المحلية الصحيحة: 05 / 06 / 07', () {
      expect(Validators.algerianPhone('0555123456'), isNull);
      expect(Validators.algerianPhone('0661234567'), isNull);
      expect(Validators.algerianPhone('0770123456'), isNull);
    });

    test('الصيغة الدولية الصحيحة: +213', () {
      expect(Validators.algerianPhone('+213555123456'), isNull);
      expect(Validators.algerianPhone('+213770123456'), isNull);
    });

    test('المسافات والشرط والأقواس تُتجاهل', () {
      expect(Validators.algerianPhone('0555 12 34 56'), isNull);
      expect(Validators.algerianPhone('0555-12-34-56'), isNull);
      expect(Validators.algerianPhone('(0555) 12 34 56'), isNull);
    });

    test('🔴 بادئات غير جزائرية للجوال → رفض', () {
      expect(Validators.algerianPhone('0412345678'), 'validatePhoneAlgerian');
      expect(Validators.algerianPhone('0123456789'), 'validatePhoneAlgerian');
      expect(Validators.algerianPhone('0812345678'), 'validatePhoneAlgerian');
    });

    test('طول خاطئ → رفض', () {
      expect(Validators.algerianPhone('055512345'), 'validatePhoneAlgerian');
      expect(Validators.algerianPhone('05551234567'), 'validatePhoneAlgerian');
      expect(Validators.algerianPhone('555123456'), 'validatePhoneAlgerian');
    });

    test('فارغ → مقبول (الحقل اختياري)', () {
      expect(Validators.algerianPhone(''), isNull);
      expect(Validators.algerianPhone(null), isNull);
    });

    test('التطبيع إلى الصيغة الدولية', () {
      expect(
        Validators.normalizeAlgerianPhone('0555123456'),
        '+213555123456',
      );
      expect(
        Validators.normalizeAlgerianPhone('+213555123456'),
        '+213555123456',
      );
      expect(Validators.normalizeAlgerianPhone('0412345678'), isNull);
      expect(Validators.normalizeAlgerianPhone(''), isNull);
    });
  });

  group('الأسماء والملاحظات', () {
    test('اسم مطلوب', () {
      expect(Validators.requiredName('قِسط السيارة'), isNull);
      expect(Validators.requiredName(''), 'validateRequired');
      expect(Validators.requiredName('   '), 'validateRequired');
      expect(Validators.requiredName('ا' * 61), 'validateTooLong');
      expect(Validators.requiredName('ا' * 61, maxLength: 100), isNull);
    });

    test('اسم عرض اختياري — الطول فقط', () {
      expect(Validators.displayName(''), isNull);
      expect(
        Validators.displayName('ا' * (AppConstants.maxDisplayNameLength + 1)),
        'validateNameTooLong',
      );
    });

    test('ملاحظة ضمن الحد', () {
      expect(Validators.note('خضرة السوق'), isNull);
      expect(Validators.note(null), isNull);
      expect(
        Validators.note('ا' * (AppConstants.maxNoteLength + 1)),
        'validateNoteTooLong',
      );
      expect(
        Validators.note('ا' * 100, maxLength: 50),
        'validateNoteTooLong',
      );
    });

    test('طول اختياري بمفتاح خطأ مخصص', () {
      expect(Validators.optionalMaxLength('abc', 10, 'myKey'), isNull);
      expect(Validators.optionalMaxLength('abcdef', 3, 'myKey'), 'myKey');
    });
  });

  group('يوم بداية الشهر المالي', () {
    test('1 إلى 28 صالح', () {
      expect(Validators.isValidFiscalAnchorDay(1), isTrue);
      expect(Validators.isValidFiscalAnchorDay(15), isTrue);
      expect(Validators.isValidFiscalAnchorDay(28), isTrue);
    });

    test('🔴 29/30/31 مرفوضة (غير موجودة في كل الشهور)', () {
      expect(Validators.isValidFiscalAnchorDay(29), isFalse);
      expect(Validators.isValidFiscalAnchorDay(30), isFalse);
      expect(Validators.isValidFiscalAnchorDay(31), isFalse);
      expect(Validators.isValidFiscalAnchorDay(0), isFalse);
      expect(Validators.isValidFiscalAnchorDay(-1), isFalse);
    });
  });

  group('دمج القواعد', () {
    test('يعيد أول خطأ بالترتيب', () {
      final String? Function(String?) rule = Validators.compose(<String? Function(String?)>[
        Validators.requiredName,
        (String? value) =>
            value != null && value.contains('x') ? 'noLetterX' : null,
      ]);

      expect(rule(''), 'validateRequired');
      expect(rule('taxi'), 'noLetterX');
      expect(rule('سيارة'), isNull);
    });
  });
}
