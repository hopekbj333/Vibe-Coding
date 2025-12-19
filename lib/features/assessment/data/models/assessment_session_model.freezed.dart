// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assessment_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssessmentSession {

 String get sessionId;// 세션 고유 ID
 String get childId;// 아동 ID
 DateTime get startedAt;// 시작 시간
 DateTime? get completedAt;// 완료 시간
 AssessmentStatus get status;// 세션 상태
@JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson) List<AssessmentQuestion> get questions;// 전체 문항 (50개)
 List<AssessmentAnswer> get answers;// 답변 기록
 int get currentQuestionIndex;// 현재 문항 번호 (0-based)
 int get totalQuestions;
/// Create a copy of AssessmentSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssessmentSessionCopyWith<AssessmentSession> get copyWith => _$AssessmentSessionCopyWithImpl<AssessmentSession>(this as AssessmentSession, _$identity);

  /// Serializes this AssessmentSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssessmentSession&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.questions, questions)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.currentQuestionIndex, currentQuestionIndex) || other.currentQuestionIndex == currentQuestionIndex)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,childId,startedAt,completedAt,status,const DeepCollectionEquality().hash(questions),const DeepCollectionEquality().hash(answers),currentQuestionIndex,totalQuestions);

@override
String toString() {
  return 'AssessmentSession(sessionId: $sessionId, childId: $childId, startedAt: $startedAt, completedAt: $completedAt, status: $status, questions: $questions, answers: $answers, currentQuestionIndex: $currentQuestionIndex, totalQuestions: $totalQuestions)';
}


}

/// @nodoc
abstract mixin class $AssessmentSessionCopyWith<$Res>  {
  factory $AssessmentSessionCopyWith(AssessmentSession value, $Res Function(AssessmentSession) _then) = _$AssessmentSessionCopyWithImpl;
@useResult
$Res call({
 String sessionId, String childId, DateTime startedAt, DateTime? completedAt, AssessmentStatus status,@JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson) List<AssessmentQuestion> questions, List<AssessmentAnswer> answers, int currentQuestionIndex, int totalQuestions
});




}
/// @nodoc
class _$AssessmentSessionCopyWithImpl<$Res>
    implements $AssessmentSessionCopyWith<$Res> {
  _$AssessmentSessionCopyWithImpl(this._self, this._then);

  final AssessmentSession _self;
  final $Res Function(AssessmentSession) _then;

/// Create a copy of AssessmentSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? childId = null,Object? startedAt = null,Object? completedAt = freezed,Object? status = null,Object? questions = null,Object? answers = null,Object? currentQuestionIndex = null,Object? totalQuestions = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssessmentStatus,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<AssessmentQuestion>,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<AssessmentAnswer>,currentQuestionIndex: null == currentQuestionIndex ? _self.currentQuestionIndex : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AssessmentSession].
extension AssessmentSessionPatterns on AssessmentSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssessmentSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssessmentSession() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssessmentSession value)  $default,){
final _that = this;
switch (_that) {
case _AssessmentSession():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssessmentSession value)?  $default,){
final _that = this;
switch (_that) {
case _AssessmentSession() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String childId,  DateTime startedAt,  DateTime? completedAt,  AssessmentStatus status, @JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson)  List<AssessmentQuestion> questions,  List<AssessmentAnswer> answers,  int currentQuestionIndex,  int totalQuestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssessmentSession() when $default != null:
return $default(_that.sessionId,_that.childId,_that.startedAt,_that.completedAt,_that.status,_that.questions,_that.answers,_that.currentQuestionIndex,_that.totalQuestions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String childId,  DateTime startedAt,  DateTime? completedAt,  AssessmentStatus status, @JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson)  List<AssessmentQuestion> questions,  List<AssessmentAnswer> answers,  int currentQuestionIndex,  int totalQuestions)  $default,) {final _that = this;
switch (_that) {
case _AssessmentSession():
return $default(_that.sessionId,_that.childId,_that.startedAt,_that.completedAt,_that.status,_that.questions,_that.answers,_that.currentQuestionIndex,_that.totalQuestions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String childId,  DateTime startedAt,  DateTime? completedAt,  AssessmentStatus status, @JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson)  List<AssessmentQuestion> questions,  List<AssessmentAnswer> answers,  int currentQuestionIndex,  int totalQuestions)?  $default,) {final _that = this;
switch (_that) {
case _AssessmentSession() when $default != null:
return $default(_that.sessionId,_that.childId,_that.startedAt,_that.completedAt,_that.status,_that.questions,_that.answers,_that.currentQuestionIndex,_that.totalQuestions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssessmentSession extends AssessmentSession {
  const _AssessmentSession({required this.sessionId, required this.childId, required this.startedAt, this.completedAt, required this.status, @JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson) required final  List<AssessmentQuestion> questions, required final  List<AssessmentAnswer> answers, required this.currentQuestionIndex, required this.totalQuestions}): _questions = questions,_answers = answers,super._();
  factory _AssessmentSession.fromJson(Map<String, dynamic> json) => _$AssessmentSessionFromJson(json);

@override final  String sessionId;
// 세션 고유 ID
@override final  String childId;
// 아동 ID
@override final  DateTime startedAt;
// 시작 시간
@override final  DateTime? completedAt;
// 완료 시간
@override final  AssessmentStatus status;
// 세션 상태
 final  List<AssessmentQuestion> _questions;
// 세션 상태
@override@JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson) List<AssessmentQuestion> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

// 전체 문항 (50개)
 final  List<AssessmentAnswer> _answers;
// 전체 문항 (50개)
@override List<AssessmentAnswer> get answers {
  if (_answers is EqualUnmodifiableListView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answers);
}

// 답변 기록
@override final  int currentQuestionIndex;
// 현재 문항 번호 (0-based)
@override final  int totalQuestions;

/// Create a copy of AssessmentSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssessmentSessionCopyWith<_AssessmentSession> get copyWith => __$AssessmentSessionCopyWithImpl<_AssessmentSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssessmentSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssessmentSession&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._questions, _questions)&&const DeepCollectionEquality().equals(other._answers, _answers)&&(identical(other.currentQuestionIndex, currentQuestionIndex) || other.currentQuestionIndex == currentQuestionIndex)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionId,childId,startedAt,completedAt,status,const DeepCollectionEquality().hash(_questions),const DeepCollectionEquality().hash(_answers),currentQuestionIndex,totalQuestions);

@override
String toString() {
  return 'AssessmentSession(sessionId: $sessionId, childId: $childId, startedAt: $startedAt, completedAt: $completedAt, status: $status, questions: $questions, answers: $answers, currentQuestionIndex: $currentQuestionIndex, totalQuestions: $totalQuestions)';
}


}

/// @nodoc
abstract mixin class _$AssessmentSessionCopyWith<$Res> implements $AssessmentSessionCopyWith<$Res> {
  factory _$AssessmentSessionCopyWith(_AssessmentSession value, $Res Function(_AssessmentSession) _then) = __$AssessmentSessionCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String childId, DateTime startedAt, DateTime? completedAt, AssessmentStatus status,@JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson) List<AssessmentQuestion> questions, List<AssessmentAnswer> answers, int currentQuestionIndex, int totalQuestions
});




}
/// @nodoc
class __$AssessmentSessionCopyWithImpl<$Res>
    implements _$AssessmentSessionCopyWith<$Res> {
  __$AssessmentSessionCopyWithImpl(this._self, this._then);

  final _AssessmentSession _self;
  final $Res Function(_AssessmentSession) _then;

/// Create a copy of AssessmentSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? childId = null,Object? startedAt = null,Object? completedAt = freezed,Object? status = null,Object? questions = null,Object? answers = null,Object? currentQuestionIndex = null,Object? totalQuestions = null,}) {
  return _then(_AssessmentSession(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssessmentStatus,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<AssessmentQuestion>,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as List<AssessmentAnswer>,currentQuestionIndex: null == currentQuestionIndex ? _self.currentQuestionIndex : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AssessmentAnswer {

 int get questionIndex;// 문항 번호 (0-based)
 String get questionId;// 문항 ID (itemId)
 String get userAnswer;// 사용자 답변
 String get correctAnswer;// 정답
 bool get isCorrect;// 정답 여부
 int get responseTimeMs;// 응답 시간 (밀리초)
 DateTime get answeredAt;// 답변 시간
 Map<String, dynamic>? get metadata;
/// Create a copy of AssessmentAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssessmentAnswerCopyWith<AssessmentAnswer> get copyWith => _$AssessmentAnswerCopyWithImpl<AssessmentAnswer>(this as AssessmentAnswer, _$identity);

  /// Serializes this AssessmentAnswer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssessmentAnswer&&(identical(other.questionIndex, questionIndex) || other.questionIndex == questionIndex)&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.userAnswer, userAnswer) || other.userAnswer == userAnswer)&&(identical(other.correctAnswer, correctAnswer) || other.correctAnswer == correctAnswer)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect)&&(identical(other.responseTimeMs, responseTimeMs) || other.responseTimeMs == responseTimeMs)&&(identical(other.answeredAt, answeredAt) || other.answeredAt == answeredAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionIndex,questionId,userAnswer,correctAnswer,isCorrect,responseTimeMs,answeredAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'AssessmentAnswer(questionIndex: $questionIndex, questionId: $questionId, userAnswer: $userAnswer, correctAnswer: $correctAnswer, isCorrect: $isCorrect, responseTimeMs: $responseTimeMs, answeredAt: $answeredAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $AssessmentAnswerCopyWith<$Res>  {
  factory $AssessmentAnswerCopyWith(AssessmentAnswer value, $Res Function(AssessmentAnswer) _then) = _$AssessmentAnswerCopyWithImpl;
@useResult
$Res call({
 int questionIndex, String questionId, String userAnswer, String correctAnswer, bool isCorrect, int responseTimeMs, DateTime answeredAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$AssessmentAnswerCopyWithImpl<$Res>
    implements $AssessmentAnswerCopyWith<$Res> {
  _$AssessmentAnswerCopyWithImpl(this._self, this._then);

  final AssessmentAnswer _self;
  final $Res Function(AssessmentAnswer) _then;

/// Create a copy of AssessmentAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionIndex = null,Object? questionId = null,Object? userAnswer = null,Object? correctAnswer = null,Object? isCorrect = null,Object? responseTimeMs = null,Object? answeredAt = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
questionIndex: null == questionIndex ? _self.questionIndex : questionIndex // ignore: cast_nullable_to_non_nullable
as int,questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,userAnswer: null == userAnswer ? _self.userAnswer : userAnswer // ignore: cast_nullable_to_non_nullable
as String,correctAnswer: null == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as String,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,responseTimeMs: null == responseTimeMs ? _self.responseTimeMs : responseTimeMs // ignore: cast_nullable_to_non_nullable
as int,answeredAt: null == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssessmentAnswer].
extension AssessmentAnswerPatterns on AssessmentAnswer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssessmentAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssessmentAnswer() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssessmentAnswer value)  $default,){
final _that = this;
switch (_that) {
case _AssessmentAnswer():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssessmentAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _AssessmentAnswer() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int questionIndex,  String questionId,  String userAnswer,  String correctAnswer,  bool isCorrect,  int responseTimeMs,  DateTime answeredAt,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssessmentAnswer() when $default != null:
return $default(_that.questionIndex,_that.questionId,_that.userAnswer,_that.correctAnswer,_that.isCorrect,_that.responseTimeMs,_that.answeredAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int questionIndex,  String questionId,  String userAnswer,  String correctAnswer,  bool isCorrect,  int responseTimeMs,  DateTime answeredAt,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _AssessmentAnswer():
return $default(_that.questionIndex,_that.questionId,_that.userAnswer,_that.correctAnswer,_that.isCorrect,_that.responseTimeMs,_that.answeredAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int questionIndex,  String questionId,  String userAnswer,  String correctAnswer,  bool isCorrect,  int responseTimeMs,  DateTime answeredAt,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _AssessmentAnswer() when $default != null:
return $default(_that.questionIndex,_that.questionId,_that.userAnswer,_that.correctAnswer,_that.isCorrect,_that.responseTimeMs,_that.answeredAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssessmentAnswer implements AssessmentAnswer {
  const _AssessmentAnswer({required this.questionIndex, required this.questionId, required this.userAnswer, required this.correctAnswer, required this.isCorrect, required this.responseTimeMs, required this.answeredAt, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _AssessmentAnswer.fromJson(Map<String, dynamic> json) => _$AssessmentAnswerFromJson(json);

@override final  int questionIndex;
// 문항 번호 (0-based)
@override final  String questionId;
// 문항 ID (itemId)
@override final  String userAnswer;
// 사용자 답변
@override final  String correctAnswer;
// 정답
@override final  bool isCorrect;
// 정답 여부
@override final  int responseTimeMs;
// 응답 시간 (밀리초)
@override final  DateTime answeredAt;
// 답변 시간
 final  Map<String, dynamic>? _metadata;
// 답변 시간
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AssessmentAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssessmentAnswerCopyWith<_AssessmentAnswer> get copyWith => __$AssessmentAnswerCopyWithImpl<_AssessmentAnswer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssessmentAnswerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssessmentAnswer&&(identical(other.questionIndex, questionIndex) || other.questionIndex == questionIndex)&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.userAnswer, userAnswer) || other.userAnswer == userAnswer)&&(identical(other.correctAnswer, correctAnswer) || other.correctAnswer == correctAnswer)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect)&&(identical(other.responseTimeMs, responseTimeMs) || other.responseTimeMs == responseTimeMs)&&(identical(other.answeredAt, answeredAt) || other.answeredAt == answeredAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionIndex,questionId,userAnswer,correctAnswer,isCorrect,responseTimeMs,answeredAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'AssessmentAnswer(questionIndex: $questionIndex, questionId: $questionId, userAnswer: $userAnswer, correctAnswer: $correctAnswer, isCorrect: $isCorrect, responseTimeMs: $responseTimeMs, answeredAt: $answeredAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$AssessmentAnswerCopyWith<$Res> implements $AssessmentAnswerCopyWith<$Res> {
  factory _$AssessmentAnswerCopyWith(_AssessmentAnswer value, $Res Function(_AssessmentAnswer) _then) = __$AssessmentAnswerCopyWithImpl;
@override @useResult
$Res call({
 int questionIndex, String questionId, String userAnswer, String correctAnswer, bool isCorrect, int responseTimeMs, DateTime answeredAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$AssessmentAnswerCopyWithImpl<$Res>
    implements _$AssessmentAnswerCopyWith<$Res> {
  __$AssessmentAnswerCopyWithImpl(this._self, this._then);

  final _AssessmentAnswer _self;
  final $Res Function(_AssessmentAnswer) _then;

/// Create a copy of AssessmentAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionIndex = null,Object? questionId = null,Object? userAnswer = null,Object? correctAnswer = null,Object? isCorrect = null,Object? responseTimeMs = null,Object? answeredAt = null,Object? metadata = freezed,}) {
  return _then(_AssessmentAnswer(
questionIndex: null == questionIndex ? _self.questionIndex : questionIndex // ignore: cast_nullable_to_non_nullable
as int,questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,userAnswer: null == userAnswer ? _self.userAnswer : userAnswer // ignore: cast_nullable_to_non_nullable
as String,correctAnswer: null == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as String,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,responseTimeMs: null == responseTimeMs ? _self.responseTimeMs : responseTimeMs // ignore: cast_nullable_to_non_nullable
as int,answeredAt: null == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
