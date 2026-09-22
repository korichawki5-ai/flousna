import '../../core/errors/app_error.dart';
import '../../core/utils/result.dart';

/// ═══════════════════════════════════════════════════════════════
///  SeedSeasonal — تحليل بذرة المناسبات الموسمية
///
///  ⭐ المنطق الكامل للمواسم (الحساب الهجري والمقارنة بين
///     المواسم) يُبنى في المرحلة 6. هنا في المرحلة 1 نضمن أن
///     **الملف صالح وقابل للقراءة** — وهذا يُختبر في
///     `seed_consistency_test.dart`، فلا نكتشف ملفاً تالفاً بعد
///     ستة أشهر من البناء.
///
///  أنواع التقويم:
///     - hijri     → شهر ويوم بالتقويم الهجري (±يوم حسب الرؤية)
///     - gregorian → تاريخ ميلادي ثابت
///     - manual    → لا تاريخ ثابت: يُحسب من بيانات المستخدم
///                     (مثال: حول الزكاة من أول ادخار بلغ النصاب)
/// ═══════════════════════════════════════════════════════════════

/// التقويم المستعمل لتحديد الموسم
enum SeasonalCalendar {
  hijri,
  gregorian,

  /// بلا تاريخ ثابت — يُحسب من بيانات المستخدم
  manual;

  static SeasonalCalendar? fromName(String? name) => switch (name) {
        'hijri' => SeasonalCalendar.hijri,
        'gregorian' => SeasonalCalendar.gregorian,
        'manual' => SeasonalCalendar.manual,
        _ => null,
      };
}

/// حجم الأثر على الميزانية
enum SeasonalImpact {
  low,
  medium,
  high,
  veryHigh;

  static SeasonalImpact? fromName(String? name) => switch (name) {
        'low' => SeasonalImpact.low,
        'medium' => SeasonalImpact.medium,
        'high' => SeasonalImpact.high,
        'very_high' => SeasonalImpact.veryHigh,
        _ => null,
      };

  /// ترتيب رقمي للمقارنة
  int get rank => index;
}

/// مناسبة موسمية واحدة
class SeasonalEvent {
  const SeasonalEvent({
    required this.id,
    required this.labelAr,
    required this.labelFr,
    required this.calendar,
    required this.impact,
    required this.defaultBoostPercent,
    required this.relatedCategoryIds,
    required this.reminderAr,
    required this.reminderFr,
    this.month,
    this.day,
    this.durationDays,
  });

  final String id;
  final String labelAr;
  final String labelFr;
  final SeasonalCalendar calendar;
  final SeasonalImpact impact;

  /// نسبة الرفع الافتراضية المقترحة على سقف الميزانية (0–200)
  final int defaultBoostPercent;

  /// تصنيفات ترتبط بهذا الموسم
  final List<String> relatedCategoryIds;

  final String reminderAr;
  final String reminderFr;

  /// رقم الشهر (1–12) — `null` للتقويم اليدوي
  final int? month;

  /// رقم اليوم — `null` للتقويم اليدوي
  final int? day;

  /// طول الموسم بالأيام — `null` للتقويم اليدوي
  final int? durationDays;

  /// يعيد الاسم حسب اللغة
  String labelFor(String languageCode) =>
      languageCode == 'fr' ? labelFr : labelAr;

  /// يعيد التذكير حسب اللغة
  String reminderFor(String languageCode) =>
      languageCode == 'fr' ? reminderFr : reminderAr;

  /// هل التاريخ مكتمل؟ (manual لا يحتاج تاريخاً)
  bool get hasFixedDate =>
      calendar != SeasonalCalendar.manual && month != null && day != null;

  /// تحليل مناسبة واحدة مع تحقق صارم
  static Result<SeasonalEvent, AppError> fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return Result<SeasonalEvent, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'event is not an object'),
      );
    }

    final String? id = raw['id'] as String?;
    if (id == null || id.isEmpty) {
      return Result<SeasonalEvent, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'event.id missing'),
      );
    }

    final Object? labelsRaw = raw['labels'];
    final Object? reminderRaw = raw['reminder'];
    if (labelsRaw is! Map<String, dynamic> || reminderRaw is! Map<String, dynamic>) {
      return Result<SeasonalEvent, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'event[$id] labels/reminder missing'),
      );
    }

    final String labelAr = _text(labelsRaw['ar']);
    final String labelFr = _text(labelsRaw['fr']);
    final String reminderAr = _text(reminderRaw['ar']);
    final String reminderFr = _text(reminderRaw['fr']);
    if (labelAr.isEmpty || labelFr.isEmpty || reminderAr.isEmpty || reminderFr.isEmpty) {
      return Result<SeasonalEvent, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'event[$id] needs ar+fr text'),
      );
    }

    final SeasonalCalendar? calendar =
        SeasonalCalendar.fromName(raw['calendar'] as String?);
    if (calendar == null) {
      return Result<SeasonalEvent, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'event[$id] calendar invalid'),
      );
    }

    final SeasonalImpact? impact = SeasonalImpact.fromName(raw['impact'] as String?);
    if (impact == null) {
      return Result<SeasonalEvent, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'event[$id] impact invalid'),
      );
    }

    final int? boost = _int(raw['defaultBoostPercent']);
    if (boost == null || boost < 0 || boost > 200) {
      return Result<SeasonalEvent, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'event[$id] boost out of range'),
      );
    }

    final Object? catsRaw = raw['relatedCategoryIds'];
    if (catsRaw is! List<dynamic> || catsRaw.isEmpty) {
      return Result<SeasonalEvent, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'event[$id] categories missing'),
      );
    }
    final List<String> categoryIds = <String>[];
    for (final Object? item in catsRaw) {
      final String value = _text(item);
      if (value.isEmpty) {
        return Result<SeasonalEvent, AppError>.failure(
          AppError.validation('errorGenericBody', details: 'event[$id] empty category id'),
        );
      }
      categoryIds.add(value);
    }

    final int? month = _int(raw['month']);
    final int? day = _int(raw['day']);
    final int? duration = _int(raw['durationDays']);

    if (calendar != SeasonalCalendar.manual) {
      final int maxMonth = 12;
      final int maxDay = calendar == SeasonalCalendar.hijri ? 30 : 31;
      if (month == null || month < 1 || month > maxMonth) {
        return Result<SeasonalEvent, AppError>.failure(
          AppError.validation('errorGenericBody', details: 'event[$id] month invalid'),
        );
      }
      if (day == null || day < 1 || day > maxDay) {
        return Result<SeasonalEvent, AppError>.failure(
          AppError.validation('errorGenericBody', details: 'event[$id] day invalid'),
        );
      }
      if (duration == null || duration < 1 || duration > 366) {
        return Result<SeasonalEvent, AppError>.failure(
          AppError.validation('errorGenericBody', details: 'event[$id] duration invalid'),
        );
      }
    }

    return Result<SeasonalEvent, AppError>.success(
      SeasonalEvent(
        id: id,
        labelAr: labelAr,
        labelFr: labelFr,
        calendar: calendar,
        impact: impact,
        defaultBoostPercent: boost,
        relatedCategoryIds: categoryIds,
        reminderAr: reminderAr,
        reminderFr: reminderFr,
        month: month,
        day: day,
        durationDays: duration,
      ),
    );
  }

  static String _text(Object? value) => value is String ? value.trim() : '';

  static int? _int(Object? value) => switch (value) {
        int() => value,
        String() => int.tryParse(value),
        _ => null,
      };
}

/// مجموعة المناسبات كاملة
class SeasonalCatalog {
  const SeasonalCatalog({required this.version, required this.events});

  final int version;
  final List<SeasonalEvent> events;

  SeasonalEvent? byId(String id) {
    for (final SeasonalEvent event in events) {
      if (event.id == id) return event;
    }
    return null;
  }

  /// الأحداث ذات التاريخ الثابت (تُستعمل للتنبيهات المجدولة)
  List<SeasonalEvent> get scheduled =>
      events.where((SeasonalEvent event) => event.hasFixedDate).toList();

  /// الأحداث التي تُحسب من بيانات المستخدم
  List<SeasonalEvent> get manual => events
      .where((SeasonalEvent event) => event.calendar == SeasonalCalendar.manual)
      .toList();

  static Result<SeasonalCatalog, AppError> fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      return Result<SeasonalCatalog, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'seasonal root is not an object'),
      );
    }

    final int? version = _version(raw['version']);
    if (version == null || version <= 0) {
      return Result<SeasonalCatalog, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'seasonal version invalid'),
      );
    }

    final Object? eventsRaw = raw['events'];
    if (eventsRaw is! List<dynamic> || eventsRaw.isEmpty) {
      return Result<SeasonalCatalog, AppError>.failure(
        AppError.validation('errorGenericBody', details: 'seasonal events missing'),
      );
    }

    final List<SeasonalEvent> events = <SeasonalEvent>[];
    final Set<String> ids = <String>{};
    for (final Object? item in eventsRaw) {
      final Result<SeasonalEvent, AppError> parsed = SeasonalEvent.fromJson(item);
      if (parsed.isFailure) {
        return Result<SeasonalCatalog, AppError>.failure(parsed.errorOrNull!);
      }
      final SeasonalEvent event = parsed.requireValue;
      if (!ids.add(event.id)) {
        return Result<SeasonalCatalog, AppError>.failure(
          AppError.validation(
            'errorGenericBody',
            details: 'duplicate event id: ${event.id}',
          ),
        );
      }
      events.add(event);
    }

    return Result<SeasonalCatalog, AppError>.success(
      SeasonalCatalog(version: version, events: events),
    );
  }

  static int? _version(Object? value) => switch (value) {
        int() => value,
        String() => int.tryParse(value),
        _ => null,
      };
}
