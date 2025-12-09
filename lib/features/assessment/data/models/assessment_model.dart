import 'package:equatable/equatable.dart';
import 'question_model.dart';

class AssessmentModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<QuestionModel> questions;
  final int totalQuestions;

  const AssessmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [id, title, description, questions, totalQuestions];

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalQuestions: json['totalQuestions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((e) => e.toJson()).toList(),
      'totalQuestions': totalQuestions,
    };
  }
}
