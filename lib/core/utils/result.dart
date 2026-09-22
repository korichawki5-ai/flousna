/// ═══════════════════════════════════════════════════════════════
///  `Result<T, E>` — معالجة أخطاء صريحة بلا استثناءات طائرة
///
///  ✅ لماذا: الاستثناءات (throw) تُنسى بسهولة وتُسبب انهيار التطبيق.
///     Result يجبر المستدعي على التعامل مع حالة الفشل — المترجم
///     يرفض تجاهلها. هذا أساس سياسة Zero-Bugs.
///
///  ✅ مبني على sealed classes (Dart 3) — المطابقة شاملة وإلزامية،
///     فلا يمكن نسيان حالة الفشل.
///
///  الاستعمال:
///  ```dart
///  final Result<Money, AppError> r = Money.tryParse(input);
///  switch (r) {
///    case Ok<Money, AppError>(:final value):
///      use(value);
///    case Err<Money, AppError>(:final error):
///      show(error.userMessage(context));
///  }
///  ```
///
///  أو بالصيغة المختصرة:
///  ```dart
///  r.fold(onSuccess: use, onFailure: (e) => show(e.userMessage(context)));
///  ```
/// ═══════════════════════════════════════════════════════════════
library;

/// نتيجة عملية: إما [Ok] بقيمة أو [Err] بخطأ
sealed class Result<T, E extends Object> {
  const Result();

  /// نجاح بقيمة
  const factory Result.success(T value) = Ok<T, E>;

  /// فشل بخطأ
  const factory Result.failure(E error) = Err<T, E>;

  /// هل هي نجاح؟
  bool get isSuccess => this is Ok<T, E>;

  /// هل هي فشل؟
  bool get isFailure => this is Err<T, E>;

  /// القيمة أو `null` عند الفشل
  T? getOrNull() => switch (this) {
        Ok<T, E>(:final T value) => value,
        Err<T, E>() => null,
      };

  /// الخطأ أو `null` عند النجاح
  E? get errorOrNull => switch (this) {
        Ok<T, E>() => null,
        Err<T, E>(:final E error) => error,
      };

  /// القيمة أو قيمة افتراضية عند الفشل
  T getOrElse(T fallback) => getOrNull() ?? fallback;

  /// القيمة أو يرمي الخطأ — ⚠️ استعملها فقط حيث الفشل مستحيل منطقياً
  T get requireValue => switch (this) {
        Ok<T, E>(:final T value) => value,
        Err<T, E>(:final E error) => throw StateError('Result.requireValue on Err: $error'),
      };

  /// ينفّذ إجراءً حسب الحالة — بلا إرجاع
  void fold({
    required void Function(T value) onSuccess,
    required void Function(E error) onFailure,
  }) {
    switch (this) {
      case Ok<T, E>(:final T value):
        onSuccess(value);
      case Err<T, E>(:final E error):
        onFailure(error);
    }
  }

  /// يحوّل قيمة النجاح إلى نوع آخر (الفشل يمرّ كما هو)
  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T, E>(:final T value) => Result<R, E>.success(transform(value)),
        Err<T, E>(:final E error) => Result<R, E>.failure(error),
      };

  /// عملية متسلسلة تفشل سريعاً
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) => switch (this) {
        Ok<T, E>(:final T value) => transform(value),
        Err<T, E>(:final E error) => Result<R, E>.failure(error),
      };

  /// يحوّل الخطأ إلى نوع آخر (النجاح يمرّ كما هو)
  Result<T, F> mapError<F extends Object>(F Function(E error) transform) => switch (this) {
        Ok<T, E>(:final T value) => Result<T, F>.success(value),
        Err<T, E>(:final E error) => Result<T, F>.failure(transform(error)),
      };
}

/// حالة النجاح
final class Ok<T, E extends Object> extends Result<T, E> {
  const Ok(this.value);

  /// قيمة النجاح
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T, E> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

/// حالة الفشل
final class Err<T, E extends Object> extends Result<T, E> {
  const Err(this.error);

  /// خطأ الفشل
  final E error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Err<T, E> && other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Err($error)';
}
