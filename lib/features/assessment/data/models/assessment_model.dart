import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_model.dart';

part 'assessment_model.freezed.dart';
part 'assessment_model.g.dart';

@freezed
class AssessmentModel with _$AssessmentModel {
  const factory AssessmentModel({
    required String id,
    required String title,
    required String description,
    required List<QuestionModel> questions,
    required int totalQuestions,
  }) = _AssessmentModel;

  factory AssessmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentModelFromJson(json);
}
