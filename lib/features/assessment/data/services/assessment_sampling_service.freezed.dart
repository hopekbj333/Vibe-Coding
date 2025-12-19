// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assessment_sampling_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssessmentQuestion {
  int get questionNumber; // 1~50
  String get gameId; // 'same_sound'
  String get gameTitle; // '같은 소리 찾기'
  String get contentId;
  TrainingContentType get type;
  GamePattern get pattern;
  String get itemId;
  String get question;
  List<ContentOption> get options;
  String get correctAnswer;
  DifficultyParams? get difficulty;

  /// Create a copy of AssessmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AssessmentQuestionCopyWith<AssessmentQuestion> get copyWith =>
      _$AssessmentQuestionCopyWithImpl<AssessmentQuestion>(
          this as AssessmentQuestion, _$identity);

  /// Serializes this AssessmentQuestion to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AssessmentQuestion &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.gameTitle, gameTitle) ||
                other.gameTitle == gameTitle) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other.options, options) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionNumber,
      gameId,
      gameTitle,
      contentId,
      type,
      pattern,
      itemId,
      question,
      const DeepCollectionEquality().hash(options),
      correctAnswer,
      difficulty);

  @override
  String toString() {
    return 'AssessmentQuestion(questionNumber: $questionNumber, gameId: $gameId, gameTitle: $gameTitle, contentId: $contentId, type: $type, pattern: $pattern, itemId: $itemId, question: $question, options: $options, correctAnswer: $correctAnswer, difficulty: $difficulty)';
  }
}

/// @nodoc
abstract mixin class $AssessmentQuestionCopyWith<$Res> {
  factory $AssessmentQuestionCopyWith(
          AssessmentQuestion value, $Res Function(AssessmentQuestion) _then) =
      _$AssessmentQuestionCopyWithImpl;
  @useResult
  $Res call(
      {int questionNumber,
      String gameId,
      String gameTitle,
      String contentId,
      TrainingContentType type,
      GamePattern pattern,
      String itemId,
      String question,
      List<ContentOption> options,
      String correctAnswer,
      DifficultyParams? difficulty});
}

/// @nodoc
class _$AssessmentQuestionCopyWithImpl<$Res>
    implements $AssessmentQuestionCopyWith<$Res> {
  _$AssessmentQuestionCopyWithImpl(this._self, this._then);

  final AssessmentQuestion _self;
  final $Res Function(AssessmentQuestion) _then;

  /// Create a copy of AssessmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionNumber = null,
    Object? gameId = null,
    Object? gameTitle = null,
    Object? contentId = null,
    Object? type = null,
    Object? pattern = null,
    Object? itemId = null,
    Object? question = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? difficulty = freezed,
  }) {
    return _then(_self.copyWith(
      questionNumber: null == questionNumber
          ? _self.questionNumber
          : questionNumber // ignore: cast_nullable_to_non_nullable
              as int,
      gameId: null == gameId
          ? _self.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      gameTitle: null == gameTitle
          ? _self.gameTitle
          : gameTitle // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _self.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TrainingContentType,
      pattern: null == pattern
          ? _self.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as GamePattern,
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _self.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<ContentOption>,
      correctAnswer: null == correctAnswer
          ? _self.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: freezed == difficulty
          ? _self.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as DifficultyParams?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AssessmentQuestion].
extension AssessmentQuestionPatterns on AssessmentQuestion {
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
    TResult Function(_AssessmentQuestion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AssessmentQuestion() when $default != null:
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
    TResult Function(_AssessmentQuestion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssessmentQuestion():
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
    TResult? Function(_AssessmentQuestion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssessmentQuestion() when $default != null:
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
            int questionNumber,
            String gameId,
            String gameTitle,
            String contentId,
            TrainingContentType type,
            GamePattern pattern,
            String itemId,
            String question,
            List<ContentOption> options,
            String correctAnswer,
            DifficultyParams? difficulty)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AssessmentQuestion() when $default != null:
        return $default(
            _that.questionNumber,
            _that.gameId,
            _that.gameTitle,
            _that.contentId,
            _that.type,
            _that.pattern,
            _that.itemId,
            _that.question,
            _that.options,
            _that.correctAnswer,
            _that.difficulty);
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
            int questionNumber,
            String gameId,
            String gameTitle,
            String contentId,
            TrainingContentType type,
            GamePattern pattern,
            String itemId,
            String question,
            List<ContentOption> options,
            String correctAnswer,
            DifficultyParams? difficulty)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssessmentQuestion():
        return $default(
            _that.questionNumber,
            _that.gameId,
            _that.gameTitle,
            _that.contentId,
            _that.type,
            _that.pattern,
            _that.itemId,
            _that.question,
            _that.options,
            _that.correctAnswer,
            _that.difficulty);
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
            int questionNumber,
            String gameId,
            String gameTitle,
            String contentId,
            TrainingContentType type,
            GamePattern pattern,
            String itemId,
            String question,
            List<ContentOption> options,
            String correctAnswer,
            DifficultyParams? difficulty)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AssessmentQuestion() when $default != null:
        return $default(
            _that.questionNumber,
            _that.gameId,
            _that.gameTitle,
            _that.contentId,
            _that.type,
            _that.pattern,
            _that.itemId,
            _that.question,
            _that.options,
            _that.correctAnswer,
            _that.difficulty);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AssessmentQuestion implements AssessmentQuestion {
  const _AssessmentQuestion(
      {required this.questionNumber,
      required this.gameId,
      required this.gameTitle,
      required this.contentId,
      required this.type,
      required this.pattern,
      required this.itemId,
      required this.question,
      required final List<ContentOption> options,
      required this.correctAnswer,
      this.difficulty})
      : _options = options;
  factory _AssessmentQuestion.fromJson(Map<String, dynamic> json) =>
      _$AssessmentQuestionFromJson(json);

  @override
  final int questionNumber;
// 1~50
  @override
  final String gameId;
// 'same_sound'
  @override
  final String gameTitle;
// '같은 소리 찾기'
  @override
  final String contentId;
  @override
  final TrainingContentType type;
  @override
  final GamePattern pattern;
  @override
  final String itemId;
  @override
  final String question;
  final List<ContentOption> _options;
  @override
  List<ContentOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final String correctAnswer;
  @override
  final DifficultyParams? difficulty;

  /// Create a copy of AssessmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AssessmentQuestionCopyWith<_AssessmentQuestion> get copyWith =>
      __$AssessmentQuestionCopyWithImpl<_AssessmentQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AssessmentQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AssessmentQuestion &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.gameTitle, gameTitle) ||
                other.gameTitle == gameTitle) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionNumber,
      gameId,
      gameTitle,
      contentId,
      type,
      pattern,
      itemId,
      question,
      const DeepCollectionEquality().hash(_options),
      correctAnswer,
      difficulty);

  @override
  String toString() {
    return 'AssessmentQuestion(questionNumber: $questionNumber, gameId: $gameId, gameTitle: $gameTitle, contentId: $contentId, type: $type, pattern: $pattern, itemId: $itemId, question: $question, options: $options, correctAnswer: $correctAnswer, difficulty: $difficulty)';
  }
}

/// @nodoc
abstract mixin class _$AssessmentQuestionCopyWith<$Res>
    implements $AssessmentQuestionCopyWith<$Res> {
  factory _$AssessmentQuestionCopyWith(
          _AssessmentQuestion value, $Res Function(_AssessmentQuestion) _then) =
      __$AssessmentQuestionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int questionNumber,
      String gameId,
      String gameTitle,
      String contentId,
      TrainingContentType type,
      GamePattern pattern,
      String itemId,
      String question,
      List<ContentOption> options,
      String correctAnswer,
      DifficultyParams? difficulty});
}

/// @nodoc
class __$AssessmentQuestionCopyWithImpl<$Res>
    implements _$AssessmentQuestionCopyWith<$Res> {
  __$AssessmentQuestionCopyWithImpl(this._self, this._then);

  final _AssessmentQuestion _self;
  final $Res Function(_AssessmentQuestion) _then;

  /// Create a copy of AssessmentQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? questionNumber = null,
    Object? gameId = null,
    Object? gameTitle = null,
    Object? contentId = null,
    Object? type = null,
    Object? pattern = null,
    Object? itemId = null,
    Object? question = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? difficulty = freezed,
  }) {
    return _then(_AssessmentQuestion(
      questionNumber: null == questionNumber
          ? _self.questionNumber
          : questionNumber // ignore: cast_nullable_to_non_nullable
              as int,
      gameId: null == gameId
          ? _self.gameId
          : gameId // ignore: cast_nullable_to_non_nullable
              as String,
      gameTitle: null == gameTitle
          ? _self.gameTitle
          : gameTitle // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _self.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TrainingContentType,
      pattern: null == pattern
          ? _self.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as GamePattern,
      itemId: null == itemId
          ? _self.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _self._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<ContentOption>,
      correctAnswer: null == correctAnswer
          ? _self.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: freezed == difficulty
          ? _self.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as DifficultyParams?,
    ));
  }
}

// dart format on
