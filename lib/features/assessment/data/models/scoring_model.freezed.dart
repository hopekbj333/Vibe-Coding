// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scoring_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuestionScore {
  String get questionId;
  ScoringResult get result;
  String? get memo; // 채점자 메모
  DateTime? get scoredAt; // 채점 시각
  String? get scoredBy; // 채점자 ID
  @JsonKey()
  dynamic get autoScoredData;

  /// Create a copy of QuestionScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuestionScoreCopyWith<QuestionScore> get copyWith =>
      _$QuestionScoreCopyWithImpl<QuestionScore>(
          this as QuestionScore, _$identity);

  /// Serializes this QuestionScore to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuestionScore &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.scoredAt, scoredAt) ||
                other.scoredAt == scoredAt) &&
            (identical(other.scoredBy, scoredBy) ||
                other.scoredBy == scoredBy) &&
            const DeepCollectionEquality()
                .equals(other.autoScoredData, autoScoredData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, questionId, result, memo,
      scoredAt, scoredBy, const DeepCollectionEquality().hash(autoScoredData));

  @override
  String toString() {
    return 'QuestionScore(questionId: $questionId, result: $result, memo: $memo, scoredAt: $scoredAt, scoredBy: $scoredBy, autoScoredData: $autoScoredData)';
  }
}

/// @nodoc
abstract mixin class $QuestionScoreCopyWith<$Res> {
  factory $QuestionScoreCopyWith(
          QuestionScore value, $Res Function(QuestionScore) _then) =
      _$QuestionScoreCopyWithImpl;
  @useResult
  $Res call(
      {String questionId,
      ScoringResult result,
      String? memo,
      DateTime? scoredAt,
      String? scoredBy,
      @JsonKey() dynamic autoScoredData});
}

/// @nodoc
class _$QuestionScoreCopyWithImpl<$Res>
    implements $QuestionScoreCopyWith<$Res> {
  _$QuestionScoreCopyWithImpl(this._self, this._then);

  final QuestionScore _self;
  final $Res Function(QuestionScore) _then;

  /// Create a copy of QuestionScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? result = null,
    Object? memo = freezed,
    Object? scoredAt = freezed,
    Object? scoredBy = freezed,
    Object? autoScoredData = freezed,
  }) {
    return _then(_self.copyWith(
      questionId: null == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      result: null == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as ScoringResult,
      memo: freezed == memo
          ? _self.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      scoredAt: freezed == scoredAt
          ? _self.scoredAt
          : scoredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scoredBy: freezed == scoredBy
          ? _self.scoredBy
          : scoredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      autoScoredData: freezed == autoScoredData
          ? _self.autoScoredData
          : autoScoredData // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// Adds pattern-matching-related methods to [QuestionScore].
extension QuestionScorePatterns on QuestionScore {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_QuestionScore value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuestionScore() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_QuestionScore value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuestionScore():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_QuestionScore value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuestionScore() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String questionId,
            ScoringResult result,
            String? memo,
            DateTime? scoredAt,
            String? scoredBy,
            @JsonKey() dynamic autoScoredData)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuestionScore() when $default != null:
        return $default(_that.questionId, _that.result, _that.memo,
            _that.scoredAt, _that.scoredBy, _that.autoScoredData);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String questionId,
            ScoringResult result,
            String? memo,
            DateTime? scoredAt,
            String? scoredBy,
            @JsonKey() dynamic autoScoredData)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuestionScore():
        return $default(_that.questionId, _that.result, _that.memo,
            _that.scoredAt, _that.scoredBy, _that.autoScoredData);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String questionId,
            ScoringResult result,
            String? memo,
            DateTime? scoredAt,
            String? scoredBy,
            @JsonKey() dynamic autoScoredData)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuestionScore() when $default != null:
        return $default(_that.questionId, _that.result, _that.memo,
            _that.scoredAt, _that.scoredBy, _that.autoScoredData);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _QuestionScore implements QuestionScore {
  const _QuestionScore(
      {required this.questionId,
      required this.result,
      this.memo,
      this.scoredAt,
      this.scoredBy,
      @JsonKey() this.autoScoredData});
  factory _QuestionScore.fromJson(Map<String, dynamic> json) =>
      _$QuestionScoreFromJson(json);

  @override
  final String questionId;
  @override
  final ScoringResult result;
  @override
  final String? memo;
// 채점자 메모
  @override
  final DateTime? scoredAt;
// 채점 시각
  @override
  final String? scoredBy;
// 채점자 ID
  @override
  @JsonKey()
  final dynamic autoScoredData;

  /// Create a copy of QuestionScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QuestionScoreCopyWith<_QuestionScore> get copyWith =>
      __$QuestionScoreCopyWithImpl<_QuestionScore>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuestionScoreToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QuestionScore &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.scoredAt, scoredAt) ||
                other.scoredAt == scoredAt) &&
            (identical(other.scoredBy, scoredBy) ||
                other.scoredBy == scoredBy) &&
            const DeepCollectionEquality()
                .equals(other.autoScoredData, autoScoredData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, questionId, result, memo,
      scoredAt, scoredBy, const DeepCollectionEquality().hash(autoScoredData));

  @override
  String toString() {
    return 'QuestionScore(questionId: $questionId, result: $result, memo: $memo, scoredAt: $scoredAt, scoredBy: $scoredBy, autoScoredData: $autoScoredData)';
  }
}

/// @nodoc
abstract mixin class _$QuestionScoreCopyWith<$Res>
    implements $QuestionScoreCopyWith<$Res> {
  factory _$QuestionScoreCopyWith(
          _QuestionScore value, $Res Function(_QuestionScore) _then) =
      __$QuestionScoreCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String questionId,
      ScoringResult result,
      String? memo,
      DateTime? scoredAt,
      String? scoredBy,
      @JsonKey() dynamic autoScoredData});
}

/// @nodoc
class __$QuestionScoreCopyWithImpl<$Res>
    implements _$QuestionScoreCopyWith<$Res> {
  __$QuestionScoreCopyWithImpl(this._self, this._then);

  final _QuestionScore _self;
  final $Res Function(_QuestionScore) _then;

  /// Create a copy of QuestionScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? questionId = null,
    Object? result = null,
    Object? memo = freezed,
    Object? scoredAt = freezed,
    Object? scoredBy = freezed,
    Object? autoScoredData = freezed,
  }) {
    return _then(_QuestionScore(
      questionId: null == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      result: null == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as ScoringResult,
      memo: freezed == memo
          ? _self.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      scoredAt: freezed == scoredAt
          ? _self.scoredAt
          : scoredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scoredBy: freezed == scoredBy
          ? _self.scoredBy
          : scoredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      autoScoredData: freezed == autoScoredData
          ? _self.autoScoredData
          : autoScoredData // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
mixin _$AssessmentResult {
  String get id;
  String get assessmentId;
  String get childId;
  DateTime get startedAt;
  DateTime? get completedAt;
  ScoringStatus get scoringStatus;
  List<QuestionScore> get scores; // 문항별 채점 결과
  int get totalQuestions;
  int get scoredQuestions;

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AssessmentResultCopyWith<AssessmentResult> get copyWith =>
      _$AssessmentResultCopyWithImpl<AssessmentResult>(
          this as AssessmentResult, _$identity);

  /// Serializes this AssessmentResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AssessmentResult &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.assessmentId, assessmentId) ||
                other.assessmentId == assessmentId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.scoringStatus, scoringStatus) ||
                other.scoringStatus == scoringStatus) &&
            const DeepCollectionEquality().equals(other.scores, scores) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.scoredQuestions, scoredQuestions) ||
                other.scoredQuestions == scoredQuestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      assessmentId,
      childId,
      startedAt,
      completedAt,
      scoringStatus,
      const DeepCollectionEquality().hash(scores),
      totalQuestions,
      scoredQuestions);

  @override
  String toString() {
    return 'AssessmentResult(id: $id, assessmentId: $assessmentId, childId: $childId, startedAt: $startedAt, completedAt: $completedAt, scoringStatus: $scoringStatus, scores: $scores, totalQuestions: $totalQuestions, scoredQuestions: $scoredQuestions)';
  }
}

/// @nodoc
abstract mixin class $AssessmentResultCopyWith<$Res> {
  factory $AssessmentResultCopyWith(
          AssessmentResult value, $Res Function(AssessmentResult) _then) =
      _$AssessmentResultCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String assessmentId,
      String childId,
      DateTime startedAt,
      DateTime? completedAt,
      ScoringStatus scoringStatus,
      List<QuestionScore> scores,
      int totalQuestions,
      int scoredQuestions});
}

/// @nodoc
class _$AssessmentResultCopyWithImpl<$Res>
    implements $AssessmentResultCopyWith<$Res> {
  _$AssessmentResultCopyWithImpl(this._self, this._then);

  final AssessmentResult _self;
  final $Res Function(AssessmentResult) _then;

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? assessmentId = null,
    Object? childId = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? scoringStatus = null,
    Object? scores = null,
    Object? totalQuestions = null,
    Object? scoredQuestions = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      assessmentId: null == assessmentId
          ? _self.assessmentId
          : assessmentId // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scoringStatus: null == scoringStatus
          ? _self.scoringStatus
          : scoringStatus // ignore: cast_nullable_to_non_nullable
              as ScoringStatus,
      scores: null == scores
          ? _self.scores
          : scores // ignore: cast_nullable_to_non_nullable
              as List<QuestionScore>,
      totalQuestions: null == totalQuestions
          ? _self.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      scoredQuestions: null == scoredQuestions
          ? _self.scoredQuestions
          : scoredQuestions // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [AssessmentResult].
extension AssessmentResultPatterns on AssessmentResult {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AssessmentResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AssessmentResult() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AssessmentResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssessmentResult():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AssessmentResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssessmentResult() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String assessmentId,
            String childId,
            DateTime startedAt,
            DateTime? completedAt,
            ScoringStatus scoringStatus,
            List<QuestionScore> scores,
            int totalQuestions,
            int scoredQuestions)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AssessmentResult() when $default != null:
        return $default(
            _that.id,
            _that.assessmentId,
            _that.childId,
            _that.startedAt,
            _that.completedAt,
            _that.scoringStatus,
            _that.scores,
            _that.totalQuestions,
            _that.scoredQuestions);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String assessmentId,
            String childId,
            DateTime startedAt,
            DateTime? completedAt,
            ScoringStatus scoringStatus,
            List<QuestionScore> scores,
            int totalQuestions,
            int scoredQuestions)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssessmentResult():
        return $default(
            _that.id,
            _that.assessmentId,
            _that.childId,
            _that.startedAt,
            _that.completedAt,
            _that.scoringStatus,
            _that.scores,
            _that.totalQuestions,
            _that.scoredQuestions);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String assessmentId,
            String childId,
            DateTime startedAt,
            DateTime? completedAt,
            ScoringStatus scoringStatus,
            List<QuestionScore> scores,
            int totalQuestions,
            int scoredQuestions)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssessmentResult() when $default != null:
        return $default(
            _that.id,
            _that.assessmentId,
            _that.childId,
            _that.startedAt,
            _that.completedAt,
            _that.scoringStatus,
            _that.scores,
            _that.totalQuestions,
            _that.scoredQuestions);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AssessmentResult extends AssessmentResult {
  const _AssessmentResult(
      {required this.id,
      required this.assessmentId,
      required this.childId,
      required this.startedAt,
      this.completedAt,
      required this.scoringStatus,
      required final List<QuestionScore> scores,
      required this.totalQuestions,
      required this.scoredQuestions})
      : _scores = scores,
        super._();
  factory _AssessmentResult.fromJson(Map<String, dynamic> json) =>
      _$AssessmentResultFromJson(json);

  @override
  final String id;
  @override
  final String assessmentId;
  @override
  final String childId;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  final ScoringStatus scoringStatus;
  final List<QuestionScore> _scores;
  @override
  List<QuestionScore> get scores {
    if (_scores is EqualUnmodifiableListView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scores);
  }

// 문항별 채점 결과
  @override
  final int totalQuestions;
  @override
  final int scoredQuestions;

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AssessmentResultCopyWith<_AssessmentResult> get copyWith =>
      __$AssessmentResultCopyWithImpl<_AssessmentResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AssessmentResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AssessmentResult &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.assessmentId, assessmentId) ||
                other.assessmentId == assessmentId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.scoringStatus, scoringStatus) ||
                other.scoringStatus == scoringStatus) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.scoredQuestions, scoredQuestions) ||
                other.scoredQuestions == scoredQuestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      assessmentId,
      childId,
      startedAt,
      completedAt,
      scoringStatus,
      const DeepCollectionEquality().hash(_scores),
      totalQuestions,
      scoredQuestions);

  @override
  String toString() {
    return 'AssessmentResult(id: $id, assessmentId: $assessmentId, childId: $childId, startedAt: $startedAt, completedAt: $completedAt, scoringStatus: $scoringStatus, scores: $scores, totalQuestions: $totalQuestions, scoredQuestions: $scoredQuestions)';
  }
}

/// @nodoc
abstract mixin class _$AssessmentResultCopyWith<$Res>
    implements $AssessmentResultCopyWith<$Res> {
  factory _$AssessmentResultCopyWith(
          _AssessmentResult value, $Res Function(_AssessmentResult) _then) =
      __$AssessmentResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String assessmentId,
      String childId,
      DateTime startedAt,
      DateTime? completedAt,
      ScoringStatus scoringStatus,
      List<QuestionScore> scores,
      int totalQuestions,
      int scoredQuestions});
}

/// @nodoc
class __$AssessmentResultCopyWithImpl<$Res>
    implements _$AssessmentResultCopyWith<$Res> {
  __$AssessmentResultCopyWithImpl(this._self, this._then);

  final _AssessmentResult _self;
  final $Res Function(_AssessmentResult) _then;

  /// Create a copy of AssessmentResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? assessmentId = null,
    Object? childId = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? scoringStatus = null,
    Object? scores = null,
    Object? totalQuestions = null,
    Object? scoredQuestions = null,
  }) {
    return _then(_AssessmentResult(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      assessmentId: null == assessmentId
          ? _self.assessmentId
          : assessmentId // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scoringStatus: null == scoringStatus
          ? _self.scoringStatus
          : scoringStatus // ignore: cast_nullable_to_non_nullable
              as ScoringStatus,
      scores: null == scores
          ? _self._scores
          : scores // ignore: cast_nullable_to_non_nullable
              as List<QuestionScore>,
      totalQuestions: null == totalQuestions
          ? _self.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      scoredQuestions: null == scoredQuestions
          ? _self.scoredQuestions
          : scoredQuestions // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
