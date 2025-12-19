// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuestionModel {
  String get id;
  QuestionType get type;
  String get promptText; // 질문 텍스트 (성우 대본용)
  String get promptAudioUrl; // 질문 오디오 URL
  List<String> get optionsImageUrl; // 보기 이미지 URL 목록
  List<String> get optionsText; // 보기 텍스트 (접근성용)
  @JsonKey()
  dynamic get correctAnswer; // 정답 (인덱스 or 텍스트)
  int get timeLimitSeconds; // 제한 시간
// S 1.4.1: 소리 식별용 추가 필드
  List<String> get soundUrls; // 재생할 소리 URL 목록
  List<String> get soundLabels;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuestionModelCopyWith<QuestionModel> get copyWith =>
      _$QuestionModelCopyWithImpl<QuestionModel>(
          this as QuestionModel, _$identity);

  /// Serializes this QuestionModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuestionModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.promptText, promptText) ||
                other.promptText == promptText) &&
            (identical(other.promptAudioUrl, promptAudioUrl) ||
                other.promptAudioUrl == promptAudioUrl) &&
            const DeepCollectionEquality()
                .equals(other.optionsImageUrl, optionsImageUrl) &&
            const DeepCollectionEquality()
                .equals(other.optionsText, optionsText) &&
            const DeepCollectionEquality()
                .equals(other.correctAnswer, correctAnswer) &&
            (identical(other.timeLimitSeconds, timeLimitSeconds) ||
                other.timeLimitSeconds == timeLimitSeconds) &&
            const DeepCollectionEquality().equals(other.soundUrls, soundUrls) &&
            const DeepCollectionEquality()
                .equals(other.soundLabels, soundLabels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      promptText,
      promptAudioUrl,
      const DeepCollectionEquality().hash(optionsImageUrl),
      const DeepCollectionEquality().hash(optionsText),
      const DeepCollectionEquality().hash(correctAnswer),
      timeLimitSeconds,
      const DeepCollectionEquality().hash(soundUrls),
      const DeepCollectionEquality().hash(soundLabels));

  @override
  String toString() {
    return 'QuestionModel(id: $id, type: $type, promptText: $promptText, promptAudioUrl: $promptAudioUrl, optionsImageUrl: $optionsImageUrl, optionsText: $optionsText, correctAnswer: $correctAnswer, timeLimitSeconds: $timeLimitSeconds, soundUrls: $soundUrls, soundLabels: $soundLabels)';
  }
}

/// @nodoc
abstract mixin class $QuestionModelCopyWith<$Res> {
  factory $QuestionModelCopyWith(
          QuestionModel value, $Res Function(QuestionModel) _then) =
      _$QuestionModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      QuestionType type,
      String promptText,
      String promptAudioUrl,
      List<String> optionsImageUrl,
      List<String> optionsText,
      @JsonKey() dynamic correctAnswer,
      int timeLimitSeconds,
      List<String> soundUrls,
      List<String> soundLabels});
}

/// @nodoc
class _$QuestionModelCopyWithImpl<$Res>
    implements $QuestionModelCopyWith<$Res> {
  _$QuestionModelCopyWithImpl(this._self, this._then);

  final QuestionModel _self;
  final $Res Function(QuestionModel) _then;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? promptText = null,
    Object? promptAudioUrl = null,
    Object? optionsImageUrl = null,
    Object? optionsText = null,
    Object? correctAnswer = freezed,
    Object? timeLimitSeconds = null,
    Object? soundUrls = null,
    Object? soundLabels = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as QuestionType,
      promptText: null == promptText
          ? _self.promptText
          : promptText // ignore: cast_nullable_to_non_nullable
              as String,
      promptAudioUrl: null == promptAudioUrl
          ? _self.promptAudioUrl
          : promptAudioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      optionsImageUrl: null == optionsImageUrl
          ? _self.optionsImageUrl
          : optionsImageUrl // ignore: cast_nullable_to_non_nullable
              as List<String>,
      optionsText: null == optionsText
          ? _self.optionsText
          : optionsText // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctAnswer: freezed == correctAnswer
          ? _self.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as dynamic,
      timeLimitSeconds: null == timeLimitSeconds
          ? _self.timeLimitSeconds
          : timeLimitSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      soundUrls: null == soundUrls
          ? _self.soundUrls
          : soundUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      soundLabels: null == soundLabels
          ? _self.soundLabels
          : soundLabels // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [QuestionModel].
extension QuestionModelPatterns on QuestionModel {
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
    TResult Function(_QuestionModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuestionModel() when $default != null:
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
    TResult Function(_QuestionModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuestionModel():
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
    TResult? Function(_QuestionModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuestionModel() when $default != null:
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
            QuestionType type,
            String promptText,
            String promptAudioUrl,
            List<String> optionsImageUrl,
            List<String> optionsText,
            @JsonKey() dynamic correctAnswer,
            int timeLimitSeconds,
            List<String> soundUrls,
            List<String> soundLabels)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuestionModel() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.promptText,
            _that.promptAudioUrl,
            _that.optionsImageUrl,
            _that.optionsText,
            _that.correctAnswer,
            _that.timeLimitSeconds,
            _that.soundUrls,
            _that.soundLabels);
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
            QuestionType type,
            String promptText,
            String promptAudioUrl,
            List<String> optionsImageUrl,
            List<String> optionsText,
            @JsonKey() dynamic correctAnswer,
            int timeLimitSeconds,
            List<String> soundUrls,
            List<String> soundLabels)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuestionModel():
        return $default(
            _that.id,
            _that.type,
            _that.promptText,
            _that.promptAudioUrl,
            _that.optionsImageUrl,
            _that.optionsText,
            _that.correctAnswer,
            _that.timeLimitSeconds,
            _that.soundUrls,
            _that.soundLabels);
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
            QuestionType type,
            String promptText,
            String promptAudioUrl,
            List<String> optionsImageUrl,
            List<String> optionsText,
            @JsonKey() dynamic correctAnswer,
            int timeLimitSeconds,
            List<String> soundUrls,
            List<String> soundLabels)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuestionModel() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.promptText,
            _that.promptAudioUrl,
            _that.optionsImageUrl,
            _that.optionsText,
            _that.correctAnswer,
            _that.timeLimitSeconds,
            _that.soundUrls,
            _that.soundLabels);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _QuestionModel implements QuestionModel {
  const _QuestionModel(
      {required this.id,
      required this.type,
      required this.promptText,
      required this.promptAudioUrl,
      final List<String> optionsImageUrl = const [],
      final List<String> optionsText = const [],
      @JsonKey() required this.correctAnswer,
      this.timeLimitSeconds = 10,
      final List<String> soundUrls = const [],
      final List<String> soundLabels = const []})
      : _optionsImageUrl = optionsImageUrl,
        _optionsText = optionsText,
        _soundUrls = soundUrls,
        _soundLabels = soundLabels;
  factory _QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  @override
  final String id;
  @override
  final QuestionType type;
  @override
  final String promptText;
// 질문 텍스트 (성우 대본용)
  @override
  final String promptAudioUrl;
// 질문 오디오 URL
  final List<String> _optionsImageUrl;
// 질문 오디오 URL
  @override
  @JsonKey()
  List<String> get optionsImageUrl {
    if (_optionsImageUrl is EqualUnmodifiableListView) return _optionsImageUrl;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optionsImageUrl);
  }

// 보기 이미지 URL 목록
  final List<String> _optionsText;
// 보기 이미지 URL 목록
  @override
  @JsonKey()
  List<String> get optionsText {
    if (_optionsText is EqualUnmodifiableListView) return _optionsText;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optionsText);
  }

// 보기 텍스트 (접근성용)
  @override
  @JsonKey()
  final dynamic correctAnswer;
// 정답 (인덱스 or 텍스트)
  @override
  @JsonKey()
  final int timeLimitSeconds;
// 제한 시간
// S 1.4.1: 소리 식별용 추가 필드
  final List<String> _soundUrls;
// 제한 시간
// S 1.4.1: 소리 식별용 추가 필드
  @override
  @JsonKey()
  List<String> get soundUrls {
    if (_soundUrls is EqualUnmodifiableListView) return _soundUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_soundUrls);
  }

// 재생할 소리 URL 목록
  final List<String> _soundLabels;
// 재생할 소리 URL 목록
  @override
  @JsonKey()
  List<String> get soundLabels {
    if (_soundLabels is EqualUnmodifiableListView) return _soundLabels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_soundLabels);
  }

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QuestionModelCopyWith<_QuestionModel> get copyWith =>
      __$QuestionModelCopyWithImpl<_QuestionModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuestionModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QuestionModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.promptText, promptText) ||
                other.promptText == promptText) &&
            (identical(other.promptAudioUrl, promptAudioUrl) ||
                other.promptAudioUrl == promptAudioUrl) &&
            const DeepCollectionEquality()
                .equals(other._optionsImageUrl, _optionsImageUrl) &&
            const DeepCollectionEquality()
                .equals(other._optionsText, _optionsText) &&
            const DeepCollectionEquality()
                .equals(other.correctAnswer, correctAnswer) &&
            (identical(other.timeLimitSeconds, timeLimitSeconds) ||
                other.timeLimitSeconds == timeLimitSeconds) &&
            const DeepCollectionEquality()
                .equals(other._soundUrls, _soundUrls) &&
            const DeepCollectionEquality()
                .equals(other._soundLabels, _soundLabels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      promptText,
      promptAudioUrl,
      const DeepCollectionEquality().hash(_optionsImageUrl),
      const DeepCollectionEquality().hash(_optionsText),
      const DeepCollectionEquality().hash(correctAnswer),
      timeLimitSeconds,
      const DeepCollectionEquality().hash(_soundUrls),
      const DeepCollectionEquality().hash(_soundLabels));

  @override
  String toString() {
    return 'QuestionModel(id: $id, type: $type, promptText: $promptText, promptAudioUrl: $promptAudioUrl, optionsImageUrl: $optionsImageUrl, optionsText: $optionsText, correctAnswer: $correctAnswer, timeLimitSeconds: $timeLimitSeconds, soundUrls: $soundUrls, soundLabels: $soundLabels)';
  }
}

/// @nodoc
abstract mixin class _$QuestionModelCopyWith<$Res>
    implements $QuestionModelCopyWith<$Res> {
  factory _$QuestionModelCopyWith(
          _QuestionModel value, $Res Function(_QuestionModel) _then) =
      __$QuestionModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      QuestionType type,
      String promptText,
      String promptAudioUrl,
      List<String> optionsImageUrl,
      List<String> optionsText,
      @JsonKey() dynamic correctAnswer,
      int timeLimitSeconds,
      List<String> soundUrls,
      List<String> soundLabels});
}

/// @nodoc
class __$QuestionModelCopyWithImpl<$Res>
    implements _$QuestionModelCopyWith<$Res> {
  __$QuestionModelCopyWithImpl(this._self, this._then);

  final _QuestionModel _self;
  final $Res Function(_QuestionModel) _then;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? promptText = null,
    Object? promptAudioUrl = null,
    Object? optionsImageUrl = null,
    Object? optionsText = null,
    Object? correctAnswer = freezed,
    Object? timeLimitSeconds = null,
    Object? soundUrls = null,
    Object? soundLabels = null,
  }) {
    return _then(_QuestionModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as QuestionType,
      promptText: null == promptText
          ? _self.promptText
          : promptText // ignore: cast_nullable_to_non_nullable
              as String,
      promptAudioUrl: null == promptAudioUrl
          ? _self.promptAudioUrl
          : promptAudioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      optionsImageUrl: null == optionsImageUrl
          ? _self._optionsImageUrl
          : optionsImageUrl // ignore: cast_nullable_to_non_nullable
              as List<String>,
      optionsText: null == optionsText
          ? _self._optionsText
          : optionsText // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctAnswer: freezed == correctAnswer
          ? _self.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as dynamic,
      timeLimitSeconds: null == timeLimitSeconds
          ? _self.timeLimitSeconds
          : timeLimitSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      soundUrls: null == soundUrls
          ? _self._soundUrls
          : soundUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      soundLabels: null == soundLabels
          ? _self._soundLabels
          : soundLabels // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$AnswerData {
  String get questionId;
  @JsonKey()
  dynamic get selectedAnswer; // 선택한 인덱스 또는 텍스트
  int get reactionTimeMs; // 반응 시간 (밀리초)
  DateTime get answeredAt; // 답변 시각
  String? get recordingPath;

  /// Create a copy of AnswerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnswerDataCopyWith<AnswerData> get copyWith =>
      _$AnswerDataCopyWithImpl<AnswerData>(this as AnswerData, _$identity);

  /// Serializes this AnswerData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnswerData &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            const DeepCollectionEquality()
                .equals(other.selectedAnswer, selectedAnswer) &&
            (identical(other.reactionTimeMs, reactionTimeMs) ||
                other.reactionTimeMs == reactionTimeMs) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt) &&
            (identical(other.recordingPath, recordingPath) ||
                other.recordingPath == recordingPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionId,
      const DeepCollectionEquality().hash(selectedAnswer),
      reactionTimeMs,
      answeredAt,
      recordingPath);

  @override
  String toString() {
    return 'AnswerData(questionId: $questionId, selectedAnswer: $selectedAnswer, reactionTimeMs: $reactionTimeMs, answeredAt: $answeredAt, recordingPath: $recordingPath)';
  }
}

/// @nodoc
abstract mixin class $AnswerDataCopyWith<$Res> {
  factory $AnswerDataCopyWith(
          AnswerData value, $Res Function(AnswerData) _then) =
      _$AnswerDataCopyWithImpl;
  @useResult
  $Res call(
      {String questionId,
      @JsonKey() dynamic selectedAnswer,
      int reactionTimeMs,
      DateTime answeredAt,
      String? recordingPath});
}

/// @nodoc
class _$AnswerDataCopyWithImpl<$Res> implements $AnswerDataCopyWith<$Res> {
  _$AnswerDataCopyWithImpl(this._self, this._then);

  final AnswerData _self;
  final $Res Function(AnswerData) _then;

  /// Create a copy of AnswerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? selectedAnswer = freezed,
    Object? reactionTimeMs = null,
    Object? answeredAt = null,
    Object? recordingPath = freezed,
  }) {
    return _then(_self.copyWith(
      questionId: null == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      selectedAnswer: freezed == selectedAnswer
          ? _self.selectedAnswer
          : selectedAnswer // ignore: cast_nullable_to_non_nullable
              as dynamic,
      reactionTimeMs: null == reactionTimeMs
          ? _self.reactionTimeMs
          : reactionTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      answeredAt: null == answeredAt
          ? _self.answeredAt
          : answeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recordingPath: freezed == recordingPath
          ? _self.recordingPath
          : recordingPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AnswerData].
extension AnswerDataPatterns on AnswerData {
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
    TResult Function(_AnswerData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnswerData() when $default != null:
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
    TResult Function(_AnswerData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnswerData():
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
    TResult? Function(_AnswerData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnswerData() when $default != null:
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
    TResult Function(String questionId, @JsonKey() dynamic selectedAnswer,
            int reactionTimeMs, DateTime answeredAt, String? recordingPath)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnswerData() when $default != null:
        return $default(_that.questionId, _that.selectedAnswer,
            _that.reactionTimeMs, _that.answeredAt, _that.recordingPath);
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
    TResult Function(String questionId, @JsonKey() dynamic selectedAnswer,
            int reactionTimeMs, DateTime answeredAt, String? recordingPath)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnswerData():
        return $default(_that.questionId, _that.selectedAnswer,
            _that.reactionTimeMs, _that.answeredAt, _that.recordingPath);
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
    TResult? Function(String questionId, @JsonKey() dynamic selectedAnswer,
            int reactionTimeMs, DateTime answeredAt, String? recordingPath)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnswerData() when $default != null:
        return $default(_that.questionId, _that.selectedAnswer,
            _that.reactionTimeMs, _that.answeredAt, _that.recordingPath);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AnswerData implements AnswerData {
  const _AnswerData(
      {required this.questionId,
      @JsonKey() required this.selectedAnswer,
      required this.reactionTimeMs,
      required this.answeredAt,
      this.recordingPath});
  factory _AnswerData.fromJson(Map<String, dynamic> json) =>
      _$AnswerDataFromJson(json);

  @override
  final String questionId;
  @override
  @JsonKey()
  final dynamic selectedAnswer;
// 선택한 인덱스 또는 텍스트
  @override
  final int reactionTimeMs;
// 반응 시간 (밀리초)
  @override
  final DateTime answeredAt;
// 답변 시각
  @override
  final String? recordingPath;

  /// Create a copy of AnswerData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnswerDataCopyWith<_AnswerData> get copyWith =>
      __$AnswerDataCopyWithImpl<_AnswerData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AnswerDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnswerData &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            const DeepCollectionEquality()
                .equals(other.selectedAnswer, selectedAnswer) &&
            (identical(other.reactionTimeMs, reactionTimeMs) ||
                other.reactionTimeMs == reactionTimeMs) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt) &&
            (identical(other.recordingPath, recordingPath) ||
                other.recordingPath == recordingPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionId,
      const DeepCollectionEquality().hash(selectedAnswer),
      reactionTimeMs,
      answeredAt,
      recordingPath);

  @override
  String toString() {
    return 'AnswerData(questionId: $questionId, selectedAnswer: $selectedAnswer, reactionTimeMs: $reactionTimeMs, answeredAt: $answeredAt, recordingPath: $recordingPath)';
  }
}

/// @nodoc
abstract mixin class _$AnswerDataCopyWith<$Res>
    implements $AnswerDataCopyWith<$Res> {
  factory _$AnswerDataCopyWith(
          _AnswerData value, $Res Function(_AnswerData) _then) =
      __$AnswerDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String questionId,
      @JsonKey() dynamic selectedAnswer,
      int reactionTimeMs,
      DateTime answeredAt,
      String? recordingPath});
}

/// @nodoc
class __$AnswerDataCopyWithImpl<$Res> implements _$AnswerDataCopyWith<$Res> {
  __$AnswerDataCopyWithImpl(this._self, this._then);

  final _AnswerData _self;
  final $Res Function(_AnswerData) _then;

  /// Create a copy of AnswerData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? questionId = null,
    Object? selectedAnswer = freezed,
    Object? reactionTimeMs = null,
    Object? answeredAt = null,
    Object? recordingPath = freezed,
  }) {
    return _then(_AnswerData(
      questionId: null == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      selectedAnswer: freezed == selectedAnswer
          ? _self.selectedAnswer
          : selectedAnswer // ignore: cast_nullable_to_non_nullable
              as dynamic,
      reactionTimeMs: null == reactionTimeMs
          ? _self.reactionTimeMs
          : reactionTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      answeredAt: null == answeredAt
          ? _self.answeredAt
          : answeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recordingPath: freezed == recordingPath
          ? _self.recordingPath
          : recordingPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
