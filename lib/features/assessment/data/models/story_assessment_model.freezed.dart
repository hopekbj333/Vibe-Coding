// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_assessment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoryAssessmentSession {
  String get sessionId;
  String get childId;
  StoryTheme get theme;
  DateTime get startedAt;
  DateTime? get completedAt;
  StoryProgressStatus get status;
  List<StoryChapter> get chapters;
  int get currentChapterIndex;
  int get currentQuestionIndex;
  StoryProgress get progress;

  /// Create a copy of StoryAssessmentSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StoryAssessmentSessionCopyWith<StoryAssessmentSession> get copyWith =>
      _$StoryAssessmentSessionCopyWithImpl<StoryAssessmentSession>(
          this as StoryAssessmentSession, _$identity);

  /// Serializes this StoryAssessmentSession to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StoryAssessmentSession &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.chapters, chapters) &&
            (identical(other.currentChapterIndex, currentChapterIndex) ||
                other.currentChapterIndex == currentChapterIndex) &&
            (identical(other.currentQuestionIndex, currentQuestionIndex) ||
                other.currentQuestionIndex == currentQuestionIndex) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      childId,
      theme,
      startedAt,
      completedAt,
      status,
      const DeepCollectionEquality().hash(chapters),
      currentChapterIndex,
      currentQuestionIndex,
      progress);

  @override
  String toString() {
    return 'StoryAssessmentSession(sessionId: $sessionId, childId: $childId, theme: $theme, startedAt: $startedAt, completedAt: $completedAt, status: $status, chapters: $chapters, currentChapterIndex: $currentChapterIndex, currentQuestionIndex: $currentQuestionIndex, progress: $progress)';
  }
}

/// @nodoc
abstract mixin class $StoryAssessmentSessionCopyWith<$Res> {
  factory $StoryAssessmentSessionCopyWith(StoryAssessmentSession value,
          $Res Function(StoryAssessmentSession) _then) =
      _$StoryAssessmentSessionCopyWithImpl;
  @useResult
  $Res call(
      {String sessionId,
      String childId,
      StoryTheme theme,
      DateTime startedAt,
      DateTime? completedAt,
      StoryProgressStatus status,
      List<StoryChapter> chapters,
      int currentChapterIndex,
      int currentQuestionIndex,
      StoryProgress progress});

  $StoryProgressCopyWith<$Res> get progress;
}

/// @nodoc
class _$StoryAssessmentSessionCopyWithImpl<$Res>
    implements $StoryAssessmentSessionCopyWith<$Res> {
  _$StoryAssessmentSessionCopyWithImpl(this._self, this._then);

  final StoryAssessmentSession _self;
  final $Res Function(StoryAssessmentSession) _then;

  /// Create a copy of StoryAssessmentSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? childId = null,
    Object? theme = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? status = null,
    Object? chapters = null,
    Object? currentChapterIndex = null,
    Object? currentQuestionIndex = null,
    Object? progress = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as StoryTheme,
      startedAt: null == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as StoryProgressStatus,
      chapters: null == chapters
          ? _self.chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<StoryChapter>,
      currentChapterIndex: null == currentChapterIndex
          ? _self.currentChapterIndex
          : currentChapterIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentQuestionIndex: null == currentQuestionIndex
          ? _self.currentQuestionIndex
          : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as StoryProgress,
    ));
  }

  /// Create a copy of StoryAssessmentSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StoryProgressCopyWith<$Res> get progress {
    return $StoryProgressCopyWith<$Res>(_self.progress, (value) {
      return _then(_self.copyWith(progress: value));
    });
  }
}

/// Adds pattern-matching-related methods to [StoryAssessmentSession].
extension StoryAssessmentSessionPatterns on StoryAssessmentSession {
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
    TResult Function(_StoryAssessmentSession value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryAssessmentSession() when $default != null:
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
    TResult Function(_StoryAssessmentSession value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryAssessmentSession():
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
    TResult? Function(_StoryAssessmentSession value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryAssessmentSession() when $default != null:
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
            String sessionId,
            String childId,
            StoryTheme theme,
            DateTime startedAt,
            DateTime? completedAt,
            StoryProgressStatus status,
            List<StoryChapter> chapters,
            int currentChapterIndex,
            int currentQuestionIndex,
            StoryProgress progress)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryAssessmentSession() when $default != null:
        return $default(
            _that.sessionId,
            _that.childId,
            _that.theme,
            _that.startedAt,
            _that.completedAt,
            _that.status,
            _that.chapters,
            _that.currentChapterIndex,
            _that.currentQuestionIndex,
            _that.progress);
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
            String sessionId,
            String childId,
            StoryTheme theme,
            DateTime startedAt,
            DateTime? completedAt,
            StoryProgressStatus status,
            List<StoryChapter> chapters,
            int currentChapterIndex,
            int currentQuestionIndex,
            StoryProgress progress)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryAssessmentSession():
        return $default(
            _that.sessionId,
            _that.childId,
            _that.theme,
            _that.startedAt,
            _that.completedAt,
            _that.status,
            _that.chapters,
            _that.currentChapterIndex,
            _that.currentQuestionIndex,
            _that.progress);
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
            String sessionId,
            String childId,
            StoryTheme theme,
            DateTime startedAt,
            DateTime? completedAt,
            StoryProgressStatus status,
            List<StoryChapter> chapters,
            int currentChapterIndex,
            int currentQuestionIndex,
            StoryProgress progress)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryAssessmentSession() when $default != null:
        return $default(
            _that.sessionId,
            _that.childId,
            _that.theme,
            _that.startedAt,
            _that.completedAt,
            _that.status,
            _that.chapters,
            _that.currentChapterIndex,
            _that.currentQuestionIndex,
            _that.progress);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StoryAssessmentSession extends StoryAssessmentSession {
  const _StoryAssessmentSession(
      {required this.sessionId,
      required this.childId,
      required this.theme,
      required this.startedAt,
      this.completedAt,
      required this.status,
      required final List<StoryChapter> chapters,
      required this.currentChapterIndex,
      required this.currentQuestionIndex,
      required this.progress})
      : _chapters = chapters,
        super._();
  factory _StoryAssessmentSession.fromJson(Map<String, dynamic> json) =>
      _$StoryAssessmentSessionFromJson(json);

  @override
  final String sessionId;
  @override
  final String childId;
  @override
  final StoryTheme theme;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  final StoryProgressStatus status;
  final List<StoryChapter> _chapters;
  @override
  List<StoryChapter> get chapters {
    if (_chapters is EqualUnmodifiableListView) return _chapters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chapters);
  }

  @override
  final int currentChapterIndex;
  @override
  final int currentQuestionIndex;
  @override
  final StoryProgress progress;

  /// Create a copy of StoryAssessmentSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StoryAssessmentSessionCopyWith<_StoryAssessmentSession> get copyWith =>
      __$StoryAssessmentSessionCopyWithImpl<_StoryAssessmentSession>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StoryAssessmentSessionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StoryAssessmentSession &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._chapters, _chapters) &&
            (identical(other.currentChapterIndex, currentChapterIndex) ||
                other.currentChapterIndex == currentChapterIndex) &&
            (identical(other.currentQuestionIndex, currentQuestionIndex) ||
                other.currentQuestionIndex == currentQuestionIndex) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      childId,
      theme,
      startedAt,
      completedAt,
      status,
      const DeepCollectionEquality().hash(_chapters),
      currentChapterIndex,
      currentQuestionIndex,
      progress);

  @override
  String toString() {
    return 'StoryAssessmentSession(sessionId: $sessionId, childId: $childId, theme: $theme, startedAt: $startedAt, completedAt: $completedAt, status: $status, chapters: $chapters, currentChapterIndex: $currentChapterIndex, currentQuestionIndex: $currentQuestionIndex, progress: $progress)';
  }
}

/// @nodoc
abstract mixin class _$StoryAssessmentSessionCopyWith<$Res>
    implements $StoryAssessmentSessionCopyWith<$Res> {
  factory _$StoryAssessmentSessionCopyWith(_StoryAssessmentSession value,
          $Res Function(_StoryAssessmentSession) _then) =
      __$StoryAssessmentSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String sessionId,
      String childId,
      StoryTheme theme,
      DateTime startedAt,
      DateTime? completedAt,
      StoryProgressStatus status,
      List<StoryChapter> chapters,
      int currentChapterIndex,
      int currentQuestionIndex,
      StoryProgress progress});

  @override
  $StoryProgressCopyWith<$Res> get progress;
}

/// @nodoc
class __$StoryAssessmentSessionCopyWithImpl<$Res>
    implements _$StoryAssessmentSessionCopyWith<$Res> {
  __$StoryAssessmentSessionCopyWithImpl(this._self, this._then);

  final _StoryAssessmentSession _self;
  final $Res Function(_StoryAssessmentSession) _then;

  /// Create a copy of StoryAssessmentSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? childId = null,
    Object? theme = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? status = null,
    Object? chapters = null,
    Object? currentChapterIndex = null,
    Object? currentQuestionIndex = null,
    Object? progress = null,
  }) {
    return _then(_StoryAssessmentSession(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _self.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as StoryTheme,
      startedAt: null == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as StoryProgressStatus,
      chapters: null == chapters
          ? _self._chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<StoryChapter>,
      currentChapterIndex: null == currentChapterIndex
          ? _self.currentChapterIndex
          : currentChapterIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentQuestionIndex: null == currentQuestionIndex
          ? _self.currentQuestionIndex
          : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as StoryProgress,
    ));
  }

  /// Create a copy of StoryAssessmentSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StoryProgressCopyWith<$Res> get progress {
    return $StoryProgressCopyWith<$Res>(_self.progress, (value) {
      return _then(_self.copyWith(progress: value));
    });
  }
}

/// @nodoc
mixin _$StoryChapter {
  String get chapterId;
  String get title; // "소리 섬", "기억 바다" 등
  String get description;
  StoryChapterType get type;
  List<StoryQuestion> get questions;
  String get introDialogue; // 한글 캐릭터의 인트로 대사
  String get completeDialogue; // 챕터 완료 대사
  StoryReward get reward;

  /// Create a copy of StoryChapter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StoryChapterCopyWith<StoryChapter> get copyWith =>
      _$StoryChapterCopyWithImpl<StoryChapter>(
          this as StoryChapter, _$identity);

  /// Serializes this StoryChapter to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StoryChapter &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.questions, questions) &&
            (identical(other.introDialogue, introDialogue) ||
                other.introDialogue == introDialogue) &&
            (identical(other.completeDialogue, completeDialogue) ||
                other.completeDialogue == completeDialogue) &&
            (identical(other.reward, reward) || other.reward == reward));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      chapterId,
      title,
      description,
      type,
      const DeepCollectionEquality().hash(questions),
      introDialogue,
      completeDialogue,
      reward);

  @override
  String toString() {
    return 'StoryChapter(chapterId: $chapterId, title: $title, description: $description, type: $type, questions: $questions, introDialogue: $introDialogue, completeDialogue: $completeDialogue, reward: $reward)';
  }
}

/// @nodoc
abstract mixin class $StoryChapterCopyWith<$Res> {
  factory $StoryChapterCopyWith(
          StoryChapter value, $Res Function(StoryChapter) _then) =
      _$StoryChapterCopyWithImpl;
  @useResult
  $Res call(
      {String chapterId,
      String title,
      String description,
      StoryChapterType type,
      List<StoryQuestion> questions,
      String introDialogue,
      String completeDialogue,
      StoryReward reward});

  $StoryRewardCopyWith<$Res> get reward;
}

/// @nodoc
class _$StoryChapterCopyWithImpl<$Res> implements $StoryChapterCopyWith<$Res> {
  _$StoryChapterCopyWithImpl(this._self, this._then);

  final StoryChapter _self;
  final $Res Function(StoryChapter) _then;

  /// Create a copy of StoryChapter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapterId = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? questions = null,
    Object? introDialogue = null,
    Object? completeDialogue = null,
    Object? reward = null,
  }) {
    return _then(_self.copyWith(
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryChapterType,
      questions: null == questions
          ? _self.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<StoryQuestion>,
      introDialogue: null == introDialogue
          ? _self.introDialogue
          : introDialogue // ignore: cast_nullable_to_non_nullable
              as String,
      completeDialogue: null == completeDialogue
          ? _self.completeDialogue
          : completeDialogue // ignore: cast_nullable_to_non_nullable
              as String,
      reward: null == reward
          ? _self.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as StoryReward,
    ));
  }

  /// Create a copy of StoryChapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StoryRewardCopyWith<$Res> get reward {
    return $StoryRewardCopyWith<$Res>(_self.reward, (value) {
      return _then(_self.copyWith(reward: value));
    });
  }
}

/// Adds pattern-matching-related methods to [StoryChapter].
extension StoryChapterPatterns on StoryChapter {
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
    TResult Function(_StoryChapter value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryChapter() when $default != null:
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
    TResult Function(_StoryChapter value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryChapter():
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
    TResult? Function(_StoryChapter value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryChapter() when $default != null:
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
            String chapterId,
            String title,
            String description,
            StoryChapterType type,
            List<StoryQuestion> questions,
            String introDialogue,
            String completeDialogue,
            StoryReward reward)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryChapter() when $default != null:
        return $default(
            _that.chapterId,
            _that.title,
            _that.description,
            _that.type,
            _that.questions,
            _that.introDialogue,
            _that.completeDialogue,
            _that.reward);
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
            String chapterId,
            String title,
            String description,
            StoryChapterType type,
            List<StoryQuestion> questions,
            String introDialogue,
            String completeDialogue,
            StoryReward reward)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryChapter():
        return $default(
            _that.chapterId,
            _that.title,
            _that.description,
            _that.type,
            _that.questions,
            _that.introDialogue,
            _that.completeDialogue,
            _that.reward);
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
            String chapterId,
            String title,
            String description,
            StoryChapterType type,
            List<StoryQuestion> questions,
            String introDialogue,
            String completeDialogue,
            StoryReward reward)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryChapter() when $default != null:
        return $default(
            _that.chapterId,
            _that.title,
            _that.description,
            _that.type,
            _that.questions,
            _that.introDialogue,
            _that.completeDialogue,
            _that.reward);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StoryChapter extends StoryChapter {
  const _StoryChapter(
      {required this.chapterId,
      required this.title,
      required this.description,
      required this.type,
      required final List<StoryQuestion> questions,
      required this.introDialogue,
      required this.completeDialogue,
      required this.reward})
      : _questions = questions,
        super._();
  factory _StoryChapter.fromJson(Map<String, dynamic> json) =>
      _$StoryChapterFromJson(json);

  @override
  final String chapterId;
  @override
  final String title;
// "소리 섬", "기억 바다" 등
  @override
  final String description;
  @override
  final StoryChapterType type;
  final List<StoryQuestion> _questions;
  @override
  List<StoryQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  final String introDialogue;
// 한글 캐릭터의 인트로 대사
  @override
  final String completeDialogue;
// 챕터 완료 대사
  @override
  final StoryReward reward;

  /// Create a copy of StoryChapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StoryChapterCopyWith<_StoryChapter> get copyWith =>
      __$StoryChapterCopyWithImpl<_StoryChapter>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StoryChapterToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StoryChapter &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            (identical(other.introDialogue, introDialogue) ||
                other.introDialogue == introDialogue) &&
            (identical(other.completeDialogue, completeDialogue) ||
                other.completeDialogue == completeDialogue) &&
            (identical(other.reward, reward) || other.reward == reward));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      chapterId,
      title,
      description,
      type,
      const DeepCollectionEquality().hash(_questions),
      introDialogue,
      completeDialogue,
      reward);

  @override
  String toString() {
    return 'StoryChapter(chapterId: $chapterId, title: $title, description: $description, type: $type, questions: $questions, introDialogue: $introDialogue, completeDialogue: $completeDialogue, reward: $reward)';
  }
}

/// @nodoc
abstract mixin class _$StoryChapterCopyWith<$Res>
    implements $StoryChapterCopyWith<$Res> {
  factory _$StoryChapterCopyWith(
          _StoryChapter value, $Res Function(_StoryChapter) _then) =
      __$StoryChapterCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String chapterId,
      String title,
      String description,
      StoryChapterType type,
      List<StoryQuestion> questions,
      String introDialogue,
      String completeDialogue,
      StoryReward reward});

  @override
  $StoryRewardCopyWith<$Res> get reward;
}

/// @nodoc
class __$StoryChapterCopyWithImpl<$Res>
    implements _$StoryChapterCopyWith<$Res> {
  __$StoryChapterCopyWithImpl(this._self, this._then);

  final _StoryChapter _self;
  final $Res Function(_StoryChapter) _then;

  /// Create a copy of StoryChapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chapterId = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? questions = null,
    Object? introDialogue = null,
    Object? completeDialogue = null,
    Object? reward = null,
  }) {
    return _then(_StoryChapter(
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryChapterType,
      questions: null == questions
          ? _self._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<StoryQuestion>,
      introDialogue: null == introDialogue
          ? _self.introDialogue
          : introDialogue // ignore: cast_nullable_to_non_nullable
              as String,
      completeDialogue: null == completeDialogue
          ? _self.completeDialogue
          : completeDialogue // ignore: cast_nullable_to_non_nullable
              as String,
      reward: null == reward
          ? _self.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as StoryReward,
    ));
  }

  /// Create a copy of StoryChapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StoryRewardCopyWith<$Res> get reward {
    return $StoryRewardCopyWith<$Res>(_self.reward, (value) {
      return _then(_self.copyWith(reward: value));
    });
  }
}

/// @nodoc
mixin _$StoryQuestion {
  String get questionId;
  String get abilityId; // 35개 능력 중 하나 (예: "0.1", "1.1")
  String get abilityName; // 능력명
  String get storyContext; // 스토리 맥락 설명
  String get characterDialogue; // 캐릭터 대사
  @JsonKey(
      toJson: _assessmentQuestionToJson, fromJson: _assessmentQuestionFromJson)
  AssessmentQuestion get question; // 실제 검사 문항
  String? get stageTitle; // Stage 제목 (예: "Stage 1-1: 기초 청각 능력")
  String? get questionAudioPath;

  /// Create a copy of StoryQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StoryQuestionCopyWith<StoryQuestion> get copyWith =>
      _$StoryQuestionCopyWithImpl<StoryQuestion>(
          this as StoryQuestion, _$identity);

  /// Serializes this StoryQuestion to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StoryQuestion &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.abilityId, abilityId) ||
                other.abilityId == abilityId) &&
            (identical(other.abilityName, abilityName) ||
                other.abilityName == abilityName) &&
            (identical(other.storyContext, storyContext) ||
                other.storyContext == storyContext) &&
            (identical(other.characterDialogue, characterDialogue) ||
                other.characterDialogue == characterDialogue) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.stageTitle, stageTitle) ||
                other.stageTitle == stageTitle) &&
            (identical(other.questionAudioPath, questionAudioPath) ||
                other.questionAudioPath == questionAudioPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionId,
      abilityId,
      abilityName,
      storyContext,
      characterDialogue,
      question,
      stageTitle,
      questionAudioPath);

  @override
  String toString() {
    return 'StoryQuestion(questionId: $questionId, abilityId: $abilityId, abilityName: $abilityName, storyContext: $storyContext, characterDialogue: $characterDialogue, question: $question, stageTitle: $stageTitle, questionAudioPath: $questionAudioPath)';
  }
}

/// @nodoc
abstract mixin class $StoryQuestionCopyWith<$Res> {
  factory $StoryQuestionCopyWith(
          StoryQuestion value, $Res Function(StoryQuestion) _then) =
      _$StoryQuestionCopyWithImpl;
  @useResult
  $Res call(
      {String questionId,
      String abilityId,
      String abilityName,
      String storyContext,
      String characterDialogue,
      @JsonKey(
          toJson: _assessmentQuestionToJson,
          fromJson: _assessmentQuestionFromJson)
      AssessmentQuestion question,
      String? stageTitle,
      String? questionAudioPath});

  $AssessmentQuestionCopyWith<$Res> get question;
}

/// @nodoc
class _$StoryQuestionCopyWithImpl<$Res>
    implements $StoryQuestionCopyWith<$Res> {
  _$StoryQuestionCopyWithImpl(this._self, this._then);

  final StoryQuestion _self;
  final $Res Function(StoryQuestion) _then;

  /// Create a copy of StoryQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? abilityId = null,
    Object? abilityName = null,
    Object? storyContext = null,
    Object? characterDialogue = null,
    Object? question = null,
    Object? stageTitle = freezed,
    Object? questionAudioPath = freezed,
  }) {
    return _then(_self.copyWith(
      questionId: null == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      abilityId: null == abilityId
          ? _self.abilityId
          : abilityId // ignore: cast_nullable_to_non_nullable
              as String,
      abilityName: null == abilityName
          ? _self.abilityName
          : abilityName // ignore: cast_nullable_to_non_nullable
              as String,
      storyContext: null == storyContext
          ? _self.storyContext
          : storyContext // ignore: cast_nullable_to_non_nullable
              as String,
      characterDialogue: null == characterDialogue
          ? _self.characterDialogue
          : characterDialogue // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as AssessmentQuestion,
      stageTitle: freezed == stageTitle
          ? _self.stageTitle
          : stageTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      questionAudioPath: freezed == questionAudioPath
          ? _self.questionAudioPath
          : questionAudioPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of StoryQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssessmentQuestionCopyWith<$Res> get question {
    return $AssessmentQuestionCopyWith<$Res>(_self.question, (value) {
      return _then(_self.copyWith(question: value));
    });
  }
}

/// Adds pattern-matching-related methods to [StoryQuestion].
extension StoryQuestionPatterns on StoryQuestion {
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
    TResult Function(_StoryQuestion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryQuestion() when $default != null:
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
    TResult Function(_StoryQuestion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryQuestion():
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
    TResult? Function(_StoryQuestion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryQuestion() when $default != null:
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
            String abilityId,
            String abilityName,
            String storyContext,
            String characterDialogue,
            @JsonKey(
                toJson: _assessmentQuestionToJson,
                fromJson: _assessmentQuestionFromJson)
            AssessmentQuestion question,
            String? stageTitle,
            String? questionAudioPath)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryQuestion() when $default != null:
        return $default(
            _that.questionId,
            _that.abilityId,
            _that.abilityName,
            _that.storyContext,
            _that.characterDialogue,
            _that.question,
            _that.stageTitle,
            _that.questionAudioPath);
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
            String abilityId,
            String abilityName,
            String storyContext,
            String characterDialogue,
            @JsonKey(
                toJson: _assessmentQuestionToJson,
                fromJson: _assessmentQuestionFromJson)
            AssessmentQuestion question,
            String? stageTitle,
            String? questionAudioPath)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryQuestion():
        return $default(
            _that.questionId,
            _that.abilityId,
            _that.abilityName,
            _that.storyContext,
            _that.characterDialogue,
            _that.question,
            _that.stageTitle,
            _that.questionAudioPath);
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
            String abilityId,
            String abilityName,
            String storyContext,
            String characterDialogue,
            @JsonKey(
                toJson: _assessmentQuestionToJson,
                fromJson: _assessmentQuestionFromJson)
            AssessmentQuestion question,
            String? stageTitle,
            String? questionAudioPath)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryQuestion() when $default != null:
        return $default(
            _that.questionId,
            _that.abilityId,
            _that.abilityName,
            _that.storyContext,
            _that.characterDialogue,
            _that.question,
            _that.stageTitle,
            _that.questionAudioPath);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StoryQuestion implements StoryQuestion {
  const _StoryQuestion(
      {required this.questionId,
      required this.abilityId,
      required this.abilityName,
      required this.storyContext,
      required this.characterDialogue,
      @JsonKey(
          toJson: _assessmentQuestionToJson,
          fromJson: _assessmentQuestionFromJson)
      required this.question,
      this.stageTitle,
      this.questionAudioPath});
  factory _StoryQuestion.fromJson(Map<String, dynamic> json) =>
      _$StoryQuestionFromJson(json);

  @override
  final String questionId;
  @override
  final String abilityId;
// 35개 능력 중 하나 (예: "0.1", "1.1")
  @override
  final String abilityName;
// 능력명
  @override
  final String storyContext;
// 스토리 맥락 설명
  @override
  final String characterDialogue;
// 캐릭터 대사
  @override
  @JsonKey(
      toJson: _assessmentQuestionToJson, fromJson: _assessmentQuestionFromJson)
  final AssessmentQuestion question;
// 실제 검사 문항
  @override
  final String? stageTitle;
// Stage 제목 (예: "Stage 1-1: 기초 청각 능력")
  @override
  final String? questionAudioPath;

  /// Create a copy of StoryQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StoryQuestionCopyWith<_StoryQuestion> get copyWith =>
      __$StoryQuestionCopyWithImpl<_StoryQuestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StoryQuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StoryQuestion &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.abilityId, abilityId) ||
                other.abilityId == abilityId) &&
            (identical(other.abilityName, abilityName) ||
                other.abilityName == abilityName) &&
            (identical(other.storyContext, storyContext) ||
                other.storyContext == storyContext) &&
            (identical(other.characterDialogue, characterDialogue) ||
                other.characterDialogue == characterDialogue) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.stageTitle, stageTitle) ||
                other.stageTitle == stageTitle) &&
            (identical(other.questionAudioPath, questionAudioPath) ||
                other.questionAudioPath == questionAudioPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      questionId,
      abilityId,
      abilityName,
      storyContext,
      characterDialogue,
      question,
      stageTitle,
      questionAudioPath);

  @override
  String toString() {
    return 'StoryQuestion(questionId: $questionId, abilityId: $abilityId, abilityName: $abilityName, storyContext: $storyContext, characterDialogue: $characterDialogue, question: $question, stageTitle: $stageTitle, questionAudioPath: $questionAudioPath)';
  }
}

/// @nodoc
abstract mixin class _$StoryQuestionCopyWith<$Res>
    implements $StoryQuestionCopyWith<$Res> {
  factory _$StoryQuestionCopyWith(
          _StoryQuestion value, $Res Function(_StoryQuestion) _then) =
      __$StoryQuestionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String questionId,
      String abilityId,
      String abilityName,
      String storyContext,
      String characterDialogue,
      @JsonKey(
          toJson: _assessmentQuestionToJson,
          fromJson: _assessmentQuestionFromJson)
      AssessmentQuestion question,
      String? stageTitle,
      String? questionAudioPath});

  @override
  $AssessmentQuestionCopyWith<$Res> get question;
}

/// @nodoc
class __$StoryQuestionCopyWithImpl<$Res>
    implements _$StoryQuestionCopyWith<$Res> {
  __$StoryQuestionCopyWithImpl(this._self, this._then);

  final _StoryQuestion _self;
  final $Res Function(_StoryQuestion) _then;

  /// Create a copy of StoryQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? questionId = null,
    Object? abilityId = null,
    Object? abilityName = null,
    Object? storyContext = null,
    Object? characterDialogue = null,
    Object? question = null,
    Object? stageTitle = freezed,
    Object? questionAudioPath = freezed,
  }) {
    return _then(_StoryQuestion(
      questionId: null == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      abilityId: null == abilityId
          ? _self.abilityId
          : abilityId // ignore: cast_nullable_to_non_nullable
              as String,
      abilityName: null == abilityName
          ? _self.abilityName
          : abilityName // ignore: cast_nullable_to_non_nullable
              as String,
      storyContext: null == storyContext
          ? _self.storyContext
          : storyContext // ignore: cast_nullable_to_non_nullable
              as String,
      characterDialogue: null == characterDialogue
          ? _self.characterDialogue
          : characterDialogue // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as AssessmentQuestion,
      stageTitle: freezed == stageTitle
          ? _self.stageTitle
          : stageTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      questionAudioPath: freezed == questionAudioPath
          ? _self.questionAudioPath
          : questionAudioPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of StoryQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssessmentQuestionCopyWith<$Res> get question {
    return $AssessmentQuestionCopyWith<$Res>(_self.question, (value) {
      return _then(_self.copyWith(question: value));
    });
  }
}

/// @nodoc
mixin _$StoryReward {
  int get stars; // 별 개수
  String? get badge; // 배지 이름 (선택)
  String get message;

  /// Create a copy of StoryReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StoryRewardCopyWith<StoryReward> get copyWith =>
      _$StoryRewardCopyWithImpl<StoryReward>(this as StoryReward, _$identity);

  /// Serializes this StoryReward to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StoryReward &&
            (identical(other.stars, stars) || other.stars == stars) &&
            (identical(other.badge, badge) || other.badge == badge) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stars, badge, message);

  @override
  String toString() {
    return 'StoryReward(stars: $stars, badge: $badge, message: $message)';
  }
}

/// @nodoc
abstract mixin class $StoryRewardCopyWith<$Res> {
  factory $StoryRewardCopyWith(
          StoryReward value, $Res Function(StoryReward) _then) =
      _$StoryRewardCopyWithImpl;
  @useResult
  $Res call({int stars, String? badge, String message});
}

/// @nodoc
class _$StoryRewardCopyWithImpl<$Res> implements $StoryRewardCopyWith<$Res> {
  _$StoryRewardCopyWithImpl(this._self, this._then);

  final StoryReward _self;
  final $Res Function(StoryReward) _then;

  /// Create a copy of StoryReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stars = null,
    Object? badge = freezed,
    Object? message = null,
  }) {
    return _then(_self.copyWith(
      stars: null == stars
          ? _self.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as int,
      badge: freezed == badge
          ? _self.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [StoryReward].
extension StoryRewardPatterns on StoryReward {
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
    TResult Function(_StoryReward value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryReward() when $default != null:
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
    TResult Function(_StoryReward value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryReward():
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
    TResult? Function(_StoryReward value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryReward() when $default != null:
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
    TResult Function(int stars, String? badge, String message)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryReward() when $default != null:
        return $default(_that.stars, _that.badge, _that.message);
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
    TResult Function(int stars, String? badge, String message) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryReward():
        return $default(_that.stars, _that.badge, _that.message);
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
    TResult? Function(int stars, String? badge, String message)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryReward() when $default != null:
        return $default(_that.stars, _that.badge, _that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StoryReward implements StoryReward {
  const _StoryReward({required this.stars, this.badge, required this.message});
  factory _StoryReward.fromJson(Map<String, dynamic> json) =>
      _$StoryRewardFromJson(json);

  @override
  final int stars;
// 별 개수
  @override
  final String? badge;
// 배지 이름 (선택)
  @override
  final String message;

  /// Create a copy of StoryReward
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StoryRewardCopyWith<_StoryReward> get copyWith =>
      __$StoryRewardCopyWithImpl<_StoryReward>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StoryRewardToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StoryReward &&
            (identical(other.stars, stars) || other.stars == stars) &&
            (identical(other.badge, badge) || other.badge == badge) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stars, badge, message);

  @override
  String toString() {
    return 'StoryReward(stars: $stars, badge: $badge, message: $message)';
  }
}

/// @nodoc
abstract mixin class _$StoryRewardCopyWith<$Res>
    implements $StoryRewardCopyWith<$Res> {
  factory _$StoryRewardCopyWith(
          _StoryReward value, $Res Function(_StoryReward) _then) =
      __$StoryRewardCopyWithImpl;
  @override
  @useResult
  $Res call({int stars, String? badge, String message});
}

/// @nodoc
class __$StoryRewardCopyWithImpl<$Res> implements _$StoryRewardCopyWith<$Res> {
  __$StoryRewardCopyWithImpl(this._self, this._then);

  final _StoryReward _self;
  final $Res Function(_StoryReward) _then;

  /// Create a copy of StoryReward
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? stars = null,
    Object? badge = freezed,
    Object? message = null,
  }) {
    return _then(_StoryReward(
      stars: null == stars
          ? _self.stars
          : stars // ignore: cast_nullable_to_non_nullable
              as int,
      badge: freezed == badge
          ? _self.badge
          : badge // ignore: cast_nullable_to_non_nullable
              as String?,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$StoryProgress {
  List<String> get completedQuestions; // 완료한 문항 ID 리스트
  Map<String, bool> get questionResults; // 문항별 정답 여부
  Map<String, int> get questionResponseTimes; // 문항별 응답 시간 (ms)
  List<String> get completedChapters; // 완료한 챕터 ID 리스트
  int get totalStars;

  /// Create a copy of StoryProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StoryProgressCopyWith<StoryProgress> get copyWith =>
      _$StoryProgressCopyWithImpl<StoryProgress>(
          this as StoryProgress, _$identity);

  /// Serializes this StoryProgress to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StoryProgress &&
            const DeepCollectionEquality()
                .equals(other.completedQuestions, completedQuestions) &&
            const DeepCollectionEquality()
                .equals(other.questionResults, questionResults) &&
            const DeepCollectionEquality()
                .equals(other.questionResponseTimes, questionResponseTimes) &&
            const DeepCollectionEquality()
                .equals(other.completedChapters, completedChapters) &&
            (identical(other.totalStars, totalStars) ||
                other.totalStars == totalStars));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(completedQuestions),
      const DeepCollectionEquality().hash(questionResults),
      const DeepCollectionEquality().hash(questionResponseTimes),
      const DeepCollectionEquality().hash(completedChapters),
      totalStars);

  @override
  String toString() {
    return 'StoryProgress(completedQuestions: $completedQuestions, questionResults: $questionResults, questionResponseTimes: $questionResponseTimes, completedChapters: $completedChapters, totalStars: $totalStars)';
  }
}

/// @nodoc
abstract mixin class $StoryProgressCopyWith<$Res> {
  factory $StoryProgressCopyWith(
          StoryProgress value, $Res Function(StoryProgress) _then) =
      _$StoryProgressCopyWithImpl;
  @useResult
  $Res call(
      {List<String> completedQuestions,
      Map<String, bool> questionResults,
      Map<String, int> questionResponseTimes,
      List<String> completedChapters,
      int totalStars});
}

/// @nodoc
class _$StoryProgressCopyWithImpl<$Res>
    implements $StoryProgressCopyWith<$Res> {
  _$StoryProgressCopyWithImpl(this._self, this._then);

  final StoryProgress _self;
  final $Res Function(StoryProgress) _then;

  /// Create a copy of StoryProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedQuestions = null,
    Object? questionResults = null,
    Object? questionResponseTimes = null,
    Object? completedChapters = null,
    Object? totalStars = null,
  }) {
    return _then(_self.copyWith(
      completedQuestions: null == completedQuestions
          ? _self.completedQuestions
          : completedQuestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      questionResults: null == questionResults
          ? _self.questionResults
          : questionResults // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      questionResponseTimes: null == questionResponseTimes
          ? _self.questionResponseTimes
          : questionResponseTimes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      completedChapters: null == completedChapters
          ? _self.completedChapters
          : completedChapters // ignore: cast_nullable_to_non_nullable
              as List<String>,
      totalStars: null == totalStars
          ? _self.totalStars
          : totalStars // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [StoryProgress].
extension StoryProgressPatterns on StoryProgress {
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
    TResult Function(_StoryProgress value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryProgress() when $default != null:
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
    TResult Function(_StoryProgress value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryProgress():
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
    TResult? Function(_StoryProgress value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryProgress() when $default != null:
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
            List<String> completedQuestions,
            Map<String, bool> questionResults,
            Map<String, int> questionResponseTimes,
            List<String> completedChapters,
            int totalStars)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StoryProgress() when $default != null:
        return $default(
            _that.completedQuestions,
            _that.questionResults,
            _that.questionResponseTimes,
            _that.completedChapters,
            _that.totalStars);
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
            List<String> completedQuestions,
            Map<String, bool> questionResults,
            Map<String, int> questionResponseTimes,
            List<String> completedChapters,
            int totalStars)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryProgress():
        return $default(
            _that.completedQuestions,
            _that.questionResults,
            _that.questionResponseTimes,
            _that.completedChapters,
            _that.totalStars);
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
            List<String> completedQuestions,
            Map<String, bool> questionResults,
            Map<String, int> questionResponseTimes,
            List<String> completedChapters,
            int totalStars)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StoryProgress() when $default != null:
        return $default(
            _that.completedQuestions,
            _that.questionResults,
            _that.questionResponseTimes,
            _that.completedChapters,
            _that.totalStars);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StoryProgress extends StoryProgress {
  const _StoryProgress(
      {required final List<String> completedQuestions,
      required final Map<String, bool> questionResults,
      required final Map<String, int> questionResponseTimes,
      required final List<String> completedChapters,
      required this.totalStars})
      : _completedQuestions = completedQuestions,
        _questionResults = questionResults,
        _questionResponseTimes = questionResponseTimes,
        _completedChapters = completedChapters,
        super._();
  factory _StoryProgress.fromJson(Map<String, dynamic> json) =>
      _$StoryProgressFromJson(json);

  final List<String> _completedQuestions;
  @override
  List<String> get completedQuestions {
    if (_completedQuestions is EqualUnmodifiableListView)
      return _completedQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedQuestions);
  }

// 완료한 문항 ID 리스트
  final Map<String, bool> _questionResults;
// 완료한 문항 ID 리스트
  @override
  Map<String, bool> get questionResults {
    if (_questionResults is EqualUnmodifiableMapView) return _questionResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_questionResults);
  }

// 문항별 정답 여부
  final Map<String, int> _questionResponseTimes;
// 문항별 정답 여부
  @override
  Map<String, int> get questionResponseTimes {
    if (_questionResponseTimes is EqualUnmodifiableMapView)
      return _questionResponseTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_questionResponseTimes);
  }

// 문항별 응답 시간 (ms)
  final List<String> _completedChapters;
// 문항별 응답 시간 (ms)
  @override
  List<String> get completedChapters {
    if (_completedChapters is EqualUnmodifiableListView)
      return _completedChapters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedChapters);
  }

// 완료한 챕터 ID 리스트
  @override
  final int totalStars;

  /// Create a copy of StoryProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StoryProgressCopyWith<_StoryProgress> get copyWith =>
      __$StoryProgressCopyWithImpl<_StoryProgress>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StoryProgressToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StoryProgress &&
            const DeepCollectionEquality()
                .equals(other._completedQuestions, _completedQuestions) &&
            const DeepCollectionEquality()
                .equals(other._questionResults, _questionResults) &&
            const DeepCollectionEquality()
                .equals(other._questionResponseTimes, _questionResponseTimes) &&
            const DeepCollectionEquality()
                .equals(other._completedChapters, _completedChapters) &&
            (identical(other.totalStars, totalStars) ||
                other.totalStars == totalStars));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_completedQuestions),
      const DeepCollectionEquality().hash(_questionResults),
      const DeepCollectionEquality().hash(_questionResponseTimes),
      const DeepCollectionEquality().hash(_completedChapters),
      totalStars);

  @override
  String toString() {
    return 'StoryProgress(completedQuestions: $completedQuestions, questionResults: $questionResults, questionResponseTimes: $questionResponseTimes, completedChapters: $completedChapters, totalStars: $totalStars)';
  }
}

/// @nodoc
abstract mixin class _$StoryProgressCopyWith<$Res>
    implements $StoryProgressCopyWith<$Res> {
  factory _$StoryProgressCopyWith(
          _StoryProgress value, $Res Function(_StoryProgress) _then) =
      __$StoryProgressCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<String> completedQuestions,
      Map<String, bool> questionResults,
      Map<String, int> questionResponseTimes,
      List<String> completedChapters,
      int totalStars});
}

/// @nodoc
class __$StoryProgressCopyWithImpl<$Res>
    implements _$StoryProgressCopyWith<$Res> {
  __$StoryProgressCopyWithImpl(this._self, this._then);

  final _StoryProgress _self;
  final $Res Function(_StoryProgress) _then;

  /// Create a copy of StoryProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? completedQuestions = null,
    Object? questionResults = null,
    Object? questionResponseTimes = null,
    Object? completedChapters = null,
    Object? totalStars = null,
  }) {
    return _then(_StoryProgress(
      completedQuestions: null == completedQuestions
          ? _self._completedQuestions
          : completedQuestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      questionResults: null == questionResults
          ? _self._questionResults
          : questionResults // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      questionResponseTimes: null == questionResponseTimes
          ? _self._questionResponseTimes
          : questionResponseTimes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      completedChapters: null == completedChapters
          ? _self._completedChapters
          : completedChapters // ignore: cast_nullable_to_non_nullable
              as List<String>,
      totalStars: null == totalStars
          ? _self.totalStars
          : totalStars // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
