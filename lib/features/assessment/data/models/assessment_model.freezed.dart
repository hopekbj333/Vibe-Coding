// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assessment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssessmentModel {

 String get id; String get title; String get description; List<QuestionModel> get questions; int get totalQuestions;
/// Create a copy of AssessmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssessmentModelCopyWith<AssessmentModel> get copyWith => _$AssessmentModelCopyWithImpl<AssessmentModel>(this as AssessmentModel, _$identity);

  /// Serializes this AssessmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssessmentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(questions),totalQuestions);

@override
String toString() {
  return 'AssessmentModel(id: $id, title: $title, description: $description, questions: $questions, totalQuestions: $totalQuestions)';
}


}

/// @nodoc
abstract mixin class $AssessmentModelCopyWith<$Res>  {
  factory $AssessmentModelCopyWith(AssessmentModel value, $Res Function(AssessmentModel) _then) = _$AssessmentModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, List<QuestionModel> questions, int totalQuestions
});




}
/// @nodoc
class _$AssessmentModelCopyWithImpl<$Res>
    implements $AssessmentModelCopyWith<$Res> {
  _$AssessmentModelCopyWithImpl(this._self, this._then);

  final AssessmentModel _self;
  final $Res Function(AssessmentModel) _then;

/// Create a copy of AssessmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? questions = null,Object? totalQuestions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<QuestionModel>,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AssessmentModel].
extension AssessmentModelPatterns on AssessmentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssessmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssessmentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssessmentModel value)  $default,){
final _that = this;
switch (_that) {
case _AssessmentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssessmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _AssessmentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  List<QuestionModel> questions,  int totalQuestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssessmentModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.questions,_that.totalQuestions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  List<QuestionModel> questions,  int totalQuestions)  $default,) {final _that = this;
switch (_that) {
case _AssessmentModel():
return $default(_that.id,_that.title,_that.description,_that.questions,_that.totalQuestions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  List<QuestionModel> questions,  int totalQuestions)?  $default,) {final _that = this;
switch (_that) {
case _AssessmentModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.questions,_that.totalQuestions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssessmentModel implements AssessmentModel {
  const _AssessmentModel({required this.id, required this.title, required this.description, required final  List<QuestionModel> questions, required this.totalQuestions}): _questions = questions;
  factory _AssessmentModel.fromJson(Map<String, dynamic> json) => _$AssessmentModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
 final  List<QuestionModel> _questions;
@override List<QuestionModel> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override final  int totalQuestions;

/// Create a copy of AssessmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssessmentModelCopyWith<_AssessmentModel> get copyWith => __$AssessmentModelCopyWithImpl<_AssessmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssessmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssessmentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,const DeepCollectionEquality().hash(_questions),totalQuestions);

@override
String toString() {
  return 'AssessmentModel(id: $id, title: $title, description: $description, questions: $questions, totalQuestions: $totalQuestions)';
}


}

/// @nodoc
abstract mixin class _$AssessmentModelCopyWith<$Res> implements $AssessmentModelCopyWith<$Res> {
  factory _$AssessmentModelCopyWith(_AssessmentModel value, $Res Function(_AssessmentModel) _then) = __$AssessmentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, List<QuestionModel> questions, int totalQuestions
});




}
/// @nodoc
class __$AssessmentModelCopyWithImpl<$Res>
    implements _$AssessmentModelCopyWith<$Res> {
  __$AssessmentModelCopyWithImpl(this._self, this._then);

  final _AssessmentModel _self;
  final $Res Function(_AssessmentModel) _then;

/// Create a copy of AssessmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? questions = null,Object? totalQuestions = null,}) {
  return _then(_AssessmentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<QuestionModel>,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
